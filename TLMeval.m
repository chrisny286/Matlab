
<<<<<<< HEAD
function [SMU1I,VDIFF] = TLMeval(sheetin,xmax,Xmax)
=======
function [SMU1I,VDIFF] = TLMeval(sheetin,xmax)
>>>>>>> develop
% misc and cleaning 
id='curvefit:prepareFittingData:removingNaNAndInf';
warning('off',id);

%% locations
addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script\resistance models'))
%addpath(genpath('C:\Users\hartz\Documents\MATLAB'))
%addpath(genpath('C:\Users\hartz\Documents\MATLAB'))

filestruct=dir('*.xls');
file={filestruct.name};
sheet=sheetin;
<<<<<<< HEAD
% sheet={'Data' , 'Append1' , 'Append2' , 'Append3' , 'Append4' , 'Append5'}; 
% for debugging
=======
>>>>>>> develop

fontsize=24;
C = regexp(char(file), '_', 'split');
sample_name=char(C{2});
% sheet=[1:6];

%% data import
I=[];
V=[];
L=[30:30:180];
%legendL=[];
for i=1:length(sheet)
    [Ii,Vi] =importfile(char(file),char(sheet(i)));
    I=[I,Ii];
    V=[V,Vi];
end


%% plot data

fig1=figure('Name', 'Raw Data', 'DefaultAxesFontSize',fontsize,'Units','normalized','OuterPosition',[0 0 1 1]);
plot(V , I,'LineWidth',2);
grid on
<<<<<<< HEAD
title('Raw data');
=======

>>>>>>> develop
legend(strcat(string(L),'µm'),'Location','southeast');

bool=exist('fits');
if bool==0&&bool~=7
    mkdir('fits');
end

print(char(strcat('Overview','.png')),'-dpng','-r300')
movefile(char(strcat('Overview','.png')),'fits');

%% Fits for R
% close all;

xmin=-1*xmax;

R=zeros(length(sheet),1);
fig2= figure( 'Name', 'Linear Fit', 'Units', 'normalized', 'OuterPosition', [ 0 0 1 1] );
x_label= 'U (V)';
y_label= 'I (A)';

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
    % Create a figure for the plots.
    
     % Plot fit with data.
     subplot( 4, 3, i );
     h = plot( fitresult, xData, yData );
     % Label axes, title
<<<<<<< HEAD
     title(char(strcat('Lin. Fit',{' '}, string(i*30),' \mu', 'm')));
=======
     title(char(strcat('data',{' '}, string(i*30),' \mu', 'm')));
>>>>>>> develop
     set(h,'LineWidth',2);
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     legend( h, 'I vs. U', char(strcat('R = ',string(R(i)),'\Omega')), 'Location', 'NorthEast' );
     xlabel(x_label);
     ylabel(y_label);
     grid on
    
     % Plot residuals.
     subplot( 4, 3, i+6 );
     h = plot( fitresult, xData, yData, 'residuals' );
     % Label axes, title
     title(char(strcat('residuals', {' '}, string(i*30),' \mu', 'm')));
     set(h,'LineWidth',2);
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     legend( h, 'Linear Fit - residuals', 'Zero Line', 'Location', 'NorthEast' );
     xlabel(x_label);
     ylabel(y_label);
     grid on
end

print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_TLM','.png')),'-dpng','-r300')
movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_TLM','.png')),'fits');

%% plot and fit results R vs distance 

[xData, yData] = prepareCurveData( L, R );

% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'Bisquare';

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
results{i}=fitresult;
R_y=fitresult.p2;


w=190e-4;
l=75e-4;
R_spec=specific_contact_resistance(R_y, l, w);

% Create a figure for the plots.
fig3=figure( 'Name', 'Linear Fit' ,'DefaultAxesFontSize',fontsize,'Units','normalized','OuterPosition',[0 0 1 1]);

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData );
% Label axes, title
title(char(strcat('data')));
legend( h, 'R vs. d', char(strcat('R_y = ',string(R_y),'\Omega a=',string(1e3*fitresult.p1),'\Omega/cm')), 'Location', 'SouthEast');
set(h,'LineWidth',2);
x_label='U (V)';
y_label='I (A)';
grid on

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
% Label axes, title
title(char(strcat('residuals')));
legend( h, 'Linear Fit - residuals', 'Zero Line', 'Location', 'SouthEast' );
set(h,'LineWidth',2);
xlabel(x_label);
ylabel(y_label);
grid on
     
print(char(strcat('TLM_R_vs_L')),'-dpng','-r300');
movefile(char(strcat('TLM_R_vs_L','.png')),'fits');
<<<<<<< HEAD
%% compare with drude 
=======

>>>>>>> develop
fig4=figure('Name', 'process fit results', 'DefaultAxesFontSize',fontsize,'Units','normalized','OuterPosition',[0 0 1 1]);
x_label = 'd (\mum)';
y_label = 'R (\Omega)';
l=[30e-4:30e-4:180e-4];
w=190e-4;
t=0.0001;
mu=200;
n=1e19;
R_drude=zeros(length(l),1);
for i=1:length(l)
    R_drude(i)=drude_resistance(l(i),w,t,mu,n)+R_y;
end
plot(L,[R,R_drude],'LineWidth',2);
<<<<<<< HEAD
title('Comparison with drude model');
=======
>>>>>>> develop
legend( 'data', 'drude model+R_{contact}', 'Location', 'NorthEast' );
xlabel(x_label);
ylabel(y_label);

print(char(strcat('TLM_Drude_comparison')),'-dpng','-r300');
movefile(char(strcat('TLM_Drude_comparison','.png')),'fits');

<<<<<<< HEAD
%% Fit exponential model to data curves
Xmin=-1*Xmax;
In0=zeros(length(sheet),1);
A_n=zeros(length(sheet),1);
Ip0=zeros(length(sheet),1);
A_p=zeros(length(sheet),1);

fig4=figure( 'Name', 'Diode Fit','Units','normalized','OuterPosition',[0 0 1 1]);
for i=1:length(sheet)
    % Fit: 'Linear Fit'.
    [xData, yData] = prepareCurveData( V(:,i), I(:,i) );
    
    %define interval to be fitted 
    %outliers = excludedata(xdata,ydata,MethodName,MethodValue)
    outliers = excludedata(xData,yData,'domain',[Xmin Xmax]);
    
    % Set up fittype and options.
    ft =fittype(@(I0n,An,I0p,Ap,in) VImodel(in,3,[I0n,An,I0p,Ap]),'independent',{'in'},'coefficients',{'I0n','An','I0p','Ap'});
    opts = fitoptions( 'Method', 'NonlinearLeastSquares','Exclude',outliers,'StartPoint', [0.02, 1.5, 0.02, 1.5] );
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
     title(char(strcat('Diode Fit TLM',{' '},string(i),'(',string(L(i)),'\mum)')));
     axis([Xmin-0.1*abs(Xmin) Xmax+0.1*abs(Xmax) -1 1])
     axis 'auto y'
     legend( h, 'I vs. U', char(strcat('TODO')), 'Location', 'SouthEast' );
     % Label axes
     xlabel 'U (V)'
     ylabel 'I (A)'
     grid on
    
     % Plot residuals.
     subplot( 4, 3, i+6 );
     h = plot( fitresult, xData, yData, 'residuals' );
     title(char(strcat('Residuals Area',{' '},string(i),'(',string(L(i)),'\mum)')));
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
     print(char(strcat('diodefit_',string(Xmin),'V_',string(Xmax),'V_TLM','.png')),'-dpng','-r300')
     movefile(char(strcat('diodefit_',string(Xmin),'V_',string(Xmax),'V_TLM','.png')),'fits');

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
% plot phi and n vs d
fig5=figure('DefaultAxesFontSize',18, 'Name', 'Barrier and n','Units','normalized','OuterPosition',[0 0 1 1]);

      % Plot Phi data vs L.
     subplot( 1, 2, 1 );
     h = plot(L,Phi1,L,Phi2);
     title(char(strcat('Barrier vs L')));
     legend( h, '\Phi_{negative}','\Phi_{positive}', 'Location', 'SouthEast' );
%      Label axes
     xlabel 'd (\mum)'
     ylabel 'E (eV)'
     grid on
     
     % Plot n data vs L.
     subplot( 1, 2, 2 );
     h = plot( L,n1,L,n2 );
     title(char(strcat('n vs L')));
     legend( h, 'n_{negative}', 'n_{positive}', 'Location', 'SouthEast' );
%      Label axes
     xlabel 'd (\mum)'
     ylabel unitless
     grid on
     
fig.PaperPositionMode = 'auto';
print(char(strcat('diodefit_results','.png')),'-dpng','-r300')
movefile(char(strcat('diodefit_results','.png')),'fits');

=======
>>>>>>> develop
end
