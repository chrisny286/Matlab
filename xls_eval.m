% misc and cleaning 
clear all;close all;
id='curvefit:prepareFittingData:removingNaNAndInf';
warning('off',id);

%% locations
addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script'))
addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script\resistance models'))
%addpath(genpath('C:\Users\hartz\Documents\MATLAB'))

file='2018-06-21_M12-170-3_TLM_30...180_um.xls';
sample_name='M12-0170-3';
structure = 'TLM';  % choose 'TLM' or 'Area'
xmax=0.9;       	% specify your fit range in mA
save = true;        % saving figures, fit result data...

% some standard parameters:
sheet={'Data' , 'Append1' , 'Append2' , 'Append3' , 'Append4' , 'Append5'};
%circ = [0.4 , 0.6 , 0.8 , 1.2, 1.6, 2.0];
%A =[0.01,0.0225,0.04,0.09,0.16,0.25];
x_label='U (V)';
y_label='I (A)';
xmin=-1*xmax;
x_range=[xmin, xmax];
%% data import, set axis labels according to measured structure
I=[];
V=[];
legendx1={};
if strcmp(structure, 'Areas')
    % pad circumference in mm, pas area in mm²
    x1 = [0.4 , 0.6 , 0.8 , 1.2, 1.6, 2.0];
    x1_unit = 'mm';
    x2 = [0.01,0.0225,0.04,0.09,0.16,0.25];
    x2_unit = 'mm²';
elseif strcmp(structure, 'TLM')
    %legendx1={};
    x1=[30:30:180];
    x1_unit = '\mum';
else
    disp('no valid structure was selected. Choose <TLM> or <Area>');
end

for i=1:length(sheet)
        [Ii,Vi] =importfile(file,char(sheet(i)));
        I=[I,Ii];
        V=[V,Vi];
        if strcmp(structure, 'Areas')
            legendx1=[legendx1,char(strcat(string(x1(i)),{' '},x1_unit,', ',string(x2(i)),x2_unit))];
        elseif strcmp(structure, 'TLM')
            legendx1=[legendx1,char(strcat(string(x1(i)),{' '},x1_unit))];
        disp(char(strcat('sheet ',string(i),' imported =)')));
        end
end

%% plot data
close all;
bool=exist('fits');
if bool==0&&bool~=7
    mkdir('fits');
end

fig1=figure('Name','Raw Data','DefaultAxesFontSize',12,'Units','normalized','OuterPosition',[0 0 1 1]);
plot(V , I,'LineWidth',2);
grid on
xlabel=x_label;
ylabel=y_label;
legend(legendx1,'Location','southeast');

fig.PaperPositionMode = 'auto';
print(char(strcat('Overview','.png')),'-dpng','-r300')
movefile(char(strcat('Overview','.png')),'fits');

%% Fits for R
%close all;
R=zeros(length(sheet),1);

figure( 'Name','Linear Fit','Units','normalized','OuterPosition',[0 0 1 1]);

for i=1:length(sheet)
    % Fit: 'Linear Fit'.
    [xData, yData] = prepareCurveData( V(:,i), I(:,i) );
    
    %define interval to be fitted 
    %outliers = excludedata(xdata,ydata,MethodName,MethodValue)
    outliers = excludedata(xData,yData,'domain',[xmin xmax]);
    
    % Set up fittype and options.
    ft = fittype( 'poly1' );
    opts = fitoptions( 'Method', 'LinearLeastSquares','Exclude',outliers );
    opts.Robust = 'Bisquare';
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    results{i}=fitresult;
	R(i)=1/fitresult.p1;
    
    % Plot fit with data.
    subplot( 4, 3, i );
    h = plot( fitresult, xData, yData );
    title(char(strcat('Lin. Fit Area',{' '},string(i), {' '},'(',string(x1(i)),'\mum)')));
    axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
    axis 'auto y'
    % Label axes, title
    if strcmp(structure, 'Areas')
        title(char(strcat('Lin. Fit',{' '},string(i), {' '},'(Area circumference:', {' '},string(x1(i)),'mm)')));
    else
        title(char(strcat('Lin. Fit',{' '},string(i), {' '},'(TLM distance :', {' '},string(x1(i)),'\mum)')));
    end
    legend( h, 'I vs. U', char(strcat('R=',string(R(i)),'\Omega')), 'Location', 'SouthEast' );
    xlabel= x_label;
    ylabel= x_label;
	grid on

    % Plot residuals.
    subplot( 4, 3, i+6 );
    h = plot( fitresult, xData, yData, 'residuals' );
    if strcmp(structure, 'Areas')
        title(char(strcat('Residuals',{' '},string(i), {' '},'(Area circumference:', {' '},string(x1(i)),'mm)')));
    else
        title(char(strcat('Residuals',{' '},string(i), {' '},'(TLM distance :', {' '},string(x1(i)),'\mum)')));
    end
    axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
    axis 'auto y'
    legend( h, 'Linear Fit - residuals', 'Zero Line', 'Location', 'SouthEast' );
    % Label axes
    xlabel= x_label;
    ylabel= x_label;
    grid on
end

    %save plot
    fig.PaperPositionMode = 'auto';
    print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng','-r300')
    movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');

% % plot A,U dependency 
% %close all;
% 
% fig2=figure('DefaultAxesFontSize',12,'Units','normalized','OuterPosition',[0 0.4 0.7 0.6]);
% title('Resistance vs. circumference and area');
% subplot( 1, 2, 1 );
% plot(U,1./R,'LineWidth',2);
% % Label axes, title
% title('Conductivity vs. Circumference');
% xlabel('U (mm)');
% ylabel('G (\Omega^{-1})');
% 
% subplot( 1, 2, 2 );
% % Label axes, title
% plot(x1,1./R,'LineWidth',2);
% title('Conductivity vs. Area');
% xlabel('A (mm^2)');
% ylabel('G (\Omega^{-1})');
% 
% print(char(strcat('R_vs_A_and_U')),'-dpng','-r300');
% movefile(char(strcat('R_vs_A_and_U','.png')),'fits');
% 
% %% compare with drude 
% %close all;
% 
% l=0.02;
% w=[0.01,0.015,0.02,0.03,0.04,0.05];
% t=0.0001;
% mu=200;
% n=1e19;
% 
% R_drude=zeros(length(w),1);
% for i=1:length(w)
%     R_drude(i)=drude_resistance(l,w(i),t,mu,n);
% end
% 
% fig3=figure('DefaultAxesFontSize',12,'Units','normalized','OuterPosition',[0 0.4 0.7 0.6]);
% 
% subplot( 1, 2, 2 );
% plot(U,1./R,U,1./R_drude,'LineWidth',2);
% % Label axes, title
% xlabel(x_label)
% ylabel(y_label)
% xlabel('U (mm)');
% ylabel('G (\Omega^{-1})');
% 
% subplot( 1, 2, 1 );
% plot(x1,1./R,x1,1./R_drude,'LineWidth',2);
% % Label axes, title
% xlabel('A (mm^2)');
% ylabel('G (\Omega^{-1})');
% grid on
% 
% print(char(strcat('Areas_Drude_comparison')),'-dpng','-r300');
% movefile(char(strcat('Areas_Drude_comparison','.png')),'fits');