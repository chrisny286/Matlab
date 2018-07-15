function [SMU1I,VDIFF] = square_analyzer(sheetin,xmax,Xmax)
id='curvefit:prepareFittingData:removingNaNAndInf';
warning('off',id);

%% locations
addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script\resistance models'))

filestruct=dir('*.xls');
file={filestruct.name};
sheet=sheetin;
% sheet={'Data' , 'Append1' , 'Append2' , 'Append3' , 'Append4' , 'Append5'}; 
% for debugging

fontsize=24;
C = regexp(char(file), '_', 'split');
sample_name=char(C{1});

%% data import
% import all data, including alternative x-axes like A and U
[I, V, legendL, A, U] = data_import(sheet, file);

%% plot data
bool=exist('fits');
if bool==0&&bool~=7
    mkdir('fits');
end

fig1=figure('DefaultAxesFontSize',fontsize,'Units','normalized','OuterPosition',[0 0 1 1]);
plot(V , I,'LineWidth',2);
grid on
xlabel('U (V)');
ylabel('I (A)');
legend(legendL,'Location','southeast');

print(char(strcat('Overview','.png')),'-dpng','-r300')
movefile(char(strcat('Overview','.png')),'fits');
%% Fits for R
% to be plotted with fit_errorbar_plot
xmin=-1*xmax;
param1_fit_rev=zeros(length(sheet),1);

% figure( 'Name', 'Linear Fit','Units','normalized','OuterPosition',[0 0 1 1]);
dparam1_local=[0 0; 0 0; 0 0; 0 0; 0 0; 0 0];

% the following section runs nicely
% fit_options={'poly1', '';
%     'method', 'LinearLeastSquares';
%     'exclude', ' '};
% data_legend = 'ToDo: legend';
% my_title = 'linear fit analysis';
% x_label = 'U (V)';
% fit_model_errorbar_plot(V,I,A,U,xmax,fit_options, 'legend', legend, 'title', my_title);%  'x_label', x_label

fit_options={'poly1', '';
    'method', 'LinearLeastSquares';
    'exclude', ' '};
data_legend = 'ToDo: legend';
my_title = 'linear fit analysis';
x_label = 'U (V)';
model = 'diode model';
fit_model_errorbar_plot(V,I,A,U,xmax,fit_options, 'legend', legend, 'title', my_title, 'fit_model', model);
%save plot
%  fig.PaperPositionMode = 'auto';
%  print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng','-r300')
%  movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');
%  disp('linear fit analysis completed.');
%  disp('data saved.');
% 
% print(char(strcat('R_vs_A_and_U')),'-dpng','-r300');
% movefile(char(strcat('R_vs_A_and_U','.png')),'fits');

%% Fit exponential model to data curves
% to be plotted with fit_errorbar_plot
Xmin=-1*Xmax;
In0=zeros(length(sheet),1);
A_n=zeros(length(sheet),1);
Ip0=zeros(length(sheet),1);
A_p=zeros(length(sheet),1);

modelname= 'Diode Fit';

fig4=figure( 'Name', modelname ,'Units','normalized','OuterPosition',[0 0 1 1]);
for i=1:length(sheet)
    % Fit: 'Linear Fit'.
    [xData, yData] = prepareCurveData( V(:,i), I(:,i) );
    
    %define interval to be fitted 
    %outliers = excludedata(xdata,ydata,MethodName,MethodValue)
    outliers = excludedata(xData,yData,'domain',[Xmin Xmax]);
    
    % Set up fittype and options.
    ft =fittype(@(I0n,An,I0p,Ap,in) VImodel(in,3,[I0n,An,I0p,Ap]),'independent',{'in'},'coefficients',{'I0n','An','I0p','Ap'});
    opts = fitoptions( 'Method', 'NonlinearLeastSquares','Exclude',outliers,'Robust','Bisquare','StartPoint', [0.02,1.5, 0.02, 1.5] );
    opts.Robust = 'Bisquare';
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    results{i}=fitresult;
    In0(i)=fitresult.I0n;
    A_n(i)=fitresult.An;
    Ip0(i)=fitresult.I0p;
    A_p(i)=fitresult.Ap;
    
     % Plot fit with data.
     subplot( 4, 3, i );
     h = plot( fitresult, xData, yData );
     title(char(strcat('Diode Fit Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([Xmin-0.1*abs(Xmin) Xmax+0.1*abs(Xmax) -1 1])
     axis 'auto y'
     legend( h, 'I vs. U', char(strcat(modelname)), 'Location', 'SouthEast' );
     % Label axes
     xlabel 'U (V)'
     ylabel 'I (A)'
     grid on
    
     % Plot residuals.
     subplot( 4, 3, i+6 );
     h = plot( fitresult, xData, yData, 'residuals' );
     title(char(strcat('Residuals Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([Xmin-0.1*abs(Xmin) Xmax+0.1*abs(Xmax) -1 1])
     axis 'auto y'
     legend( h, 'Diode Fit - residuals', 'Zero Line', 'Location', 'SouthEast' );
     % Label axes
     xlabel 'U (V)'
     ylabel 'I (A)'
     grid on
     
end
    %save plot
     fig.PaperPositionMode = 'auto';
     print(char(strcat('diodefit_',string(Xmin),'V_',string(Xmax),'V_Areas','.png')),'-dpng','-r300')
     movefile(char(strcat('diodefit_',string(Xmin),'V_',string(Xmax),'V_Areas','.png')),'fits');

 %% Calulate Barrier and n from Fit
 
 k_B=1.3806503e-23;
 T=300;
 e=1.602176462e-19;
 m_e=0.17*9.10938188e-31;
 h=9.10938188e-31;
 A_R=(4*pi*e*m_e*k_B^2)/(h^3);
 
Phi1=zeros(length(sheet),1);
Phi2=zeros(length(sheet),1);
n1=zeros(length(sheet),1);
n2=zeros(length(sheet),1);
for i=1:length(sheet)
    Phi1(i)=-(k_B*T)/(e)*log(In0(i)./(A_R*T^2));
    Phi2(i)=-(k_B*T)/(e)*log(Ip0(i)./(A_R*T^2));
    n1(i)=A_n(i)*(k_B*T)/e;
    n2(i)=A_p(i)*(k_B*T)/e;
end
% plot phi and n vs U,A
fig5=figure('DefaultAxesFontSize',18, 'Name', 'Barrier and n','Units','normalized','OuterPosition',[0 0 1 1]);

      % Plot Phi data vs U.
     subplot( 2, 2, 1 );
     h = plot(U,Phi1,U,Phi2);
     title(char(strcat('Barrier vs U')));
     legend( h, '\Phi_{negative}','\Phi_{positive}', 'Location', 'SouthEast' );
%      Label axes
     xlabel 'U (mm)'
     ylabel 'E (eV)'
     grid on
     
     % Plot n data vs U.
     subplot( 2, 2, 2 );
     h = plot( U,n1,U,n2 );
     title(char(strcat('n vs U')));
     legend( h, 'n_{negative}', 'n_{positive}', 'Location', 'SouthEast' );
%      Label axes
     xlabel 'U (mm)'
     ylabel unitless
     grid on
     
     % Plot Phi data vs A.
     subplot( 2, 2, 3 );
     h = plot(A,Phi1,A,Phi2);
     title(char(strcat('Barrier vs A')));
     legend( h, '\Phi_{negative}','\Phi_{positive}', 'Location', 'SouthEast' );
%      Label axes
     xlabel 'A (mm^2)'
     ylabel 'E (eV)'
     grid on
     
     % Plot n data vs A.
     subplot( 2, 2, 4 );
     h = plot( A,n1,A,n2 );
     title(char(strcat('n vs A')));
     legend( h, 'n_{negative}', 'n_{positive}', 'Location', 'SouthEast' );
%      Label axes
     xlabel 'A (mm^2)'
     ylabel unitless
     grid on
     
fig.PaperPositionMode = 'auto';
print(char(strcat('diodefit_results','.png')),'-dpng','-r300')
movefile(char(strcat('diodefit_results','.png')),'fits');
end