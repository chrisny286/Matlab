function [p, status] = fit_model_errorbar_plot(x_data_set, y_data_set, A, U, x_max, fit_opts, varargin)
% x, y, y_err: 1D data arrays
% try to keep it as general as possibe, however here raw x data is always U, y is I
%
% fit_options are transfered as a struct with f(1:3)
% 1 - required: fit_type, i.e. 'poly1'
% 2 - required: 'method', option (i.e. 'LinearLeastSquares')
%define interval to be fitted 
%outliers = excludedata(xdata,ydata,MethodName,MethodValue)
% 3 - required: 'method' i.e. 'exclude'
p = inputParser;
% add required vars
addRequired(p, 'x_data_set', @(x) isfloat(x));
addRequired(p, 'y_data_set', @(x) isfloat(x));
addRequired(p, 'A', @(x) isfloat(x));
addRequired(p, 'U', @(x) isfloat(x));
addRequired(p, 'x_max', @isfloat);
addRequired(p, 'fit_opts');

% add optional vars
addParameter(p, 'save', 1, @isnumeric); % default: saving figure
addParameter(p, 'legend', @isstring);
addParameter(p, 'title', @(t) isstring(t));
addParameter(p,'fig_number', @isnumeric);
% addParameter(p, 'x_label', 'U (V)', ...            @(x) isstring(x));% ToDo, workaround ....(x=='U (V)'|| x=='circumference (mm)'|| x=='area (mm^2)'|| x=='distance (\mum)'));
addParameter(p, 'y_label', 'resistance (\Omega)', ...
            @(y) isstring(y) && (y=='conductance (1/\Omega' || y=='barrier height (eV)'));
addParameter(p, 'fit_model', 'linear', ...
            @(x) (x=='linear'|| x== 'diode model'));

% parse inputs and assign them to readable variables
parse(p,x_data_set,y_data_set,A,U,x_max,fit_opts,varargin{:});
% status to handle when function completes:
status = 'data plottetd with errorbars';

fontsize=24;
x_label = 'U (V)'; % todo: p.Results.x_label;
y_label = 'R (Ohm)'; %  p.Results.y_label;
fit_opts=p.Results.fit_opts; 
xmax=p.Results.x_max;
xmin=-1*xmax;
fit_model = p.Results.fit_model;
% todo: integrate zeros(length(sheet),1)

%% linear fit to data, compare to drude model
figure( 'Name', p.Results.title ,'Units','normalized', ...
        'OuterPosition',[0 0 1 1]);
    
% local data storage for aquiring all fit results
param1_inv_local=zeros(6,1);
param1_local = zeros(6,1);
dparam1_local= [0 0;0 0;0 0];
dparam1_inv_local=[0 0;0 0;0 0];
for i=1:6% Todo: integrate: length(sheet)
    % Fit: 'Linear Fit'.
    % todo: rename x to x_data
    [xData, yData] = prepareCurveData(x_data_set(:,i), y_data_set(:,i) );
    
    if string(fit_opts(3, 1))=='exclude'
        outliers = excludedata(xData,yData,'domain',[xmin xmax]);
    else
        disp('please check specifications of range settings in matlab figure.')
    end
    
    % Set up fittype and options.
    switch fit_model
        case 'linear'
            ft = fittype('poly1');
        case 'diode model'
            ft = fittype(@(I0n,An,I0p,Ap,in) VImodel(in,3,[I0n,An,I0p,Ap]),'independent',{'in'},'coefficients',{'I0n','An','I0p','Ap'});
        otherwise
            disp('please coose a valid fit model.')
    end
    
    opts = fitoptions( 'Method', 'LinearLeastSquares','Exclude',outliers );
    opts.Robust = 'Bisquare';
    
%     % todo:
%     fittype(fit_opts(1,1));
%     opts = fitoptions( string(fit_opts(2,:)), string(fit_opts(3,1)), outliers);
%     opts.Robust = 'Bisquare';
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    % coeffs = coeffvalues(fitresult); param1_fit_inv = slope inverse (conductivity)
    ci= confint(fitresult);
    param1=fitresult.p1;
    
    % save parameters to local data storage
    param1_local(i)=param1;
    param1_inv_local(i)=1/param1;

    % set the lower and upper error values
    % calculate errors manually using the 95% coinfidence interval

    % param1 is slope, dparam1 is error on slope
    dparam1_lower = param1-ci(1,1);
    dparam1_upper = param1-ci(2,1);
    dparam1 = [dparam1_lower, dparam1_upper];
    dparam1_local(i,:)=abs(dparam1);

    dparam1_inv_lower =-(param1-ci(1,1))/param1^2;
    dparam1_inv_upper =-(param1-ci(2,1))/param1^2;
    dparam1_inv=[dparam1_inv_lower, dparam1_inv_upper];
    dparam1_inv_local(i, :) = abs(dparam1_inv);

    %ci_param1 = -1*param1/param1^2;
   
    %ci_param1_local = ci_param1;
    
    
     % Plot fit with data.
     subplot( 4, 3, i );
     h = plot( fitresult, xData, yData );
     % todo: Legends & titles
     title(char(strcat('Lin. Fit Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     
     %legend( h, 'I vs. U', char(strcat('R=',string(param1_fit_rev(i)),'\Omega')), 'Location', 'SouthEast' );
     % Label axes
     xlabel(x_label);
     ylabel(y_label);
     grid on
    
     % Plot residuals.
     subplot( 4, 3, i+6 );
     h = plot( fitresult, xData, yData, 'residuals' );
     title(char(strcat('Residuals Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     legend( h, 'Linear Fit - residuals', 'Zero Line', 'Location', 'SouthEast' );
     % Label axes
     xlabel(x_label);
     ylabel(y_label);
     grid on     
end

% drude model
l=0.02; % contact spacing in um for square structure
w=U/4;
t=0.0001;
mu=200;
n=1e19;
R_drude=zeros(length(w),1);
for i=1:length(w)
    R_drude(i)=drude_resistance(l,w(i),t,mu,n);
end

%% plotting data with error bars and compare to drude model
figure('DefaultAxesFontSize',fontsize,'Units','normalized','OuterPosition',[0 0 1 1]);
title('data vs drude model');
col= 2, row =3;
subplot(row, col, 1);
% plot(U,1./R,'LineWidth',2); % plotting without errors
errorbar(U, param1_inv_local, dparam1_inv_local(:,1), dparam1_inv_local(:,2)); 
title('Resistance vs. Circumference');
xlabel('circumference (mm)');
ylabel('R (\Omega)');

subplot(row, col, 2);
% plot(U,1./R,'LineWidth',2); % plotting without errors
errorbar(A, param1_inv_local, dparam1_inv_local(:,1), dparam1_inv_local(:,2)); 
title('Resistance vs. Area');
xlabel('circumference (mm)');
ylabel('R (\Omega)');


subplot(row, col, 3);
% plot(A, param1 ,'LineWidth',2); % plotting without errors
errorbar(U, param1_local, dparam1_local(:,1), dparam1_local(:,2));
title('Conductivity vs. Circumference');
xlabel('circumference (mm)');
ylabel('G (\Omega^{-1})');

subplot(row, col, 4);
% plot(A, param1 ,'LineWidth',2); % plotting without errors
errorbar(A, param1_local, dparam1_local(:,1), dparam1_local(:,2));
title('Conductivity vs. Area');
xlabel('A (mm^2)');
ylabel('G (\Omega^{-1})');

subplot(row, col, 5);
% plot(A, param1 ,'LineWidth',2); % plotting without errors
errorbar(U, param1_local, dparam1_local(:,1), dparam1_local(:,2)); hold on;
errorbar(U,1./R_drude, zeros(6,1), 'LineWidth',2);
title('Conductivity vs. Circumference');
xlabel('circumference (mm)');
ylabel('G (\Omega^{-1})');

subplot(row, col, 6);
% plot(A, param1 ,'LineWidth',2); % plotting without errors
errorbar(A, param1_local, dparam1_local(:,1), dparam1_local(:,2)); hold on;
errorbar(A, 1./R_drude, zeros(6,1), 'LineWidth',2);
title('Conductivity vs. Area');
xlabel('A (mm^2)');
ylabel('G (\Omega^{-1})');

% todo print, move and save plot
% print(char(strcat('R_vs_A_and_U')),'-dpng','-r300');
% movefile(char(strcat('R_vs_A_and_U','.png')),'fits');
% if p.Results.save  
%     fig.PaperPositionMode = 'auto';
%     print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng','-r300')
%     movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');
% end
end