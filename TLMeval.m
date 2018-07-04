
function [SMU1I,VDIFF] = TLMeval(sheetin,xmax)
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
     title(char(strcat('data',{' '}, string(i*30),' \mu', 'm')));
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
legend( 'data', 'drude model+R_{contact}', 'Location', 'NorthEast' );
xlabel(x_label);
ylabel(y_label);

print(char(strcat('TLM_Drude_comparison')),'-dpng','-r300');
movefile(char(strcat('TLM_Drude_comparison','.png')),'fits');

end
