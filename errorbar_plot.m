function [p, status] = fit_errorbar_plot(x_data_set, y_data_set, x_max, fit_opts, varargin)
% x, y, y_err: 1D data arrays
% try to keep it as general as possibe, however here raw x data is always U, y is I
%
% fit_options are transfered as a struct with f(1:3)
% 1 - required: fit_type, i.e. 'poly1'
% 2 - required: 'method', option (i.e. 'LinearLeastSquares')
%define interval to be fitted 
%outliers = excludedata(xdata,ydata,MethodName,MethodValue)
% 3 - required: 'method' i.e. 'exclude'


% create input parser
p = inputParser;

% add required vars
addRequired(p, 'x_data_set', @(x) isfloat(x));
addRequired(p, 'y_data_set', @(x) isfloat(x));
addRequired(p, 'fit_opts');
addRequired(p, 'x_max', @isfloat);

% add optional vars
addParameter(p, 'legend', @isstring);
addParameter(p, 'title', @(t) isstring(t));
addParameter(p,'fig_number', @isnumeric);
addParameter(p, 'xlabel', x_label, ...
            @(x) isstring(x) &&(x=='circumference (mm)'||x=='distance (\mum)'));
addParameter(p, 'ylabel', ...
            @(y) isstring(y) && (y=='resistance (\Omega)' || y=='conductance (1/\Omega' || y=='barrier height (eV)'));

% parse inputs
parse(p, x_data_set, y_data_set, y_err, varargin{:});
status = 'data plotted with errorbars';


fit_opts=p.Results.fit_opts; 

xmax=p.Results.x_max;
xmin=-1*xmax;
param1_fit_rev=zeros(length(sheet),1);

figure( 'Name', p.Results.title ,'Units','normalized', ...
        'OuterPosition',[0 0 1 1]);
dparam1_local=[0 0; 0 0; 0 0; 0 0; 0 0; 0 0];
for i=1:6% Todo: integrate: length(sheet)
    % Fit: 'Linear Fit'.
    % todo: rename x to x_data
    [xData, yData] = prepareCurveData(x_data_set(:,i), y_data_set(:,i) );
    
    if fit_opts(3, 1)=='exclude'
        outliers = excludedata(xData,yData,'domain',[xmin xmax]);
    else
        disp('please check specifications of range settings in matlab figure.')
    end
    
    % Set up fittype and options.
    ft = fittype( fit_opts(1) );
    opts = fitoptions( fit_opts(2), 'exclude', outliers);
    opts.Robust = 'Bisquare';
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    % coeffs = coeffvalues(fitresult);
    ci= confint(fitresult);
    param1=fitresult.p1;
    ci_param1(i)=ci(1);
    results{i}=fitresult;
    param1_fit_rev(i)=1/param1;
    % dR(i)=fitresult.p1;
    
    % calculate errors manually using the 95% coinfidence interval
    dparam1_lower =-(param1-ci(1,1))/param1^2;
    dparam1_upper =-(param1-ci(2,1))/param1^2;
    dparam1=[dparam1_lower, dparam1_upper];
    
    ci_param1 = -1*param1/param1^2;
    dparam1_local(i, :) = abs(dparam1);
    % ci_param1_local = ci_param1;
    
    
     % Plot fit with data.
     subplot( 4, 3, i );
     h = plot( fitresult, xData, yData );
     title(char(strcat('Lin. Fit Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     legend( h, 'I vs. U', char(strcat('R=',string(param1_fit_rev(i)),'\Omega')), 'Location', 'SouthEast' );
     % Label axes
     xlabel 'U (V)'
     ylabel 'I (A)'
     grid on
    
     % Plot residuals.
     subplot( 4, 3, i+6 );
     h = plot( fitresult, xData, yData, 'residuals' );
     title(char(strcat('Residuals Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     legend( h, 'Linear Fit - residuals', 'Zero Line', 'Location', 'SouthEast' );
     % Label axes
     xlabel 'U (V)'
     ylabel 'I (A)'
     grid on
     
end
    %save plot
     fig.PaperPositionMode = 'auto';
     print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng','-r300')
     movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');

end