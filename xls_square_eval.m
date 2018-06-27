% misc and cleaning 
clear all;close all;
id='curvefit:prepareFittingData:removingNaNAndInf';
warning('off',id);

%% locations
%addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script'))
%addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script\resistance models'))
addpath(genpath('C:\Users\hartz\Documents\MATLAB'))
addpath(genpath('C:\Users\hartz\Documents\MATLAB'))
% file='\\janeway\User AG Bluhm\Hartz\sciebo\wafer\M12-0169_ZnSeCl_Al insitu\U-I data\squares\2018-06-20_M12-169_squares.xls';
file='2018-06-25_M12-170-3_Areas.xls';
sheet={'Data' , 'Append1' , 'Append2' , 'Append3' , 'Append4' , 'Append5'};

%% data import
I=[];
V=[];
U=[0.4 , 0.6 , 0.8 , 1.2, 1.6, 2.0];
A=[0.01,0.0225,0.04,0.09,0.16,0.25];
legendL={};
for i=1:length(sheet)
    [Ii,Vi] =importfile(file,char(sheet(i)));
    I=[I,Ii];
    V=[V,Vi];
    legendL=[legendL,char(strcat(string(U(i)),'mm',', ',string(A(i)),'mm²'))];
end


%% plot data
close all;
bool=exist('fits');
if bool==0&&bool~=7
    mkdir('fits');
end

fig1=figure('DefaultAxesFontSize',12,'Units','normalized','OuterPosition',[0 0 1 1]);
plot(V , I,'LineWidth',2);
grid on
xlabel('U(V)');
ylabel('I(A)');
legend(legendL,'Location','southeast');

print(char(strcat('Overview','.png')),'-dpng','-r300')
movefile(char(strcat('Overview','.png')),'fits');

%% Fits for R
%close all;

xmax=0.9;
xmin=-1*xmax;
R=zeros(length(sheet),1);

figure( 'Name', 'Linear Fit','Units','normalized','OuterPosition',[0 0 1 1]);
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
     title(char(strcat('Lin. Fit Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     legend( h, 'I vs. U', char(strcat('R=',string(R(i)),'\Omega')), 'Location', 'SouthEast' );
     % Label axes
     xlabel U(V)
     ylabel I(A)
     grid on
    
     % Plot residuals.
     subplot( 4, 3, i+6 );
     h = plot( fitresult, xData, yData, 'residuals' );
     title(char(strcat('Residuals Area',{' '},string(i),'(',string(A(i)),'\mum)')));
     axis([xmin-0.1*abs(xmin) xmax+0.1*abs(xmax) -1 1])
     axis 'auto y'
     legend( h, 'Linear Fit - residuals', 'Zero Line', 'Location', 'SouthEast' );
     % Label axes
     xlabel U(V)
     ylabel I(A)
     grid on
     
end
    %save plot
     fig.PaperPositionMode = 'auto';
     print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng','-r300')
     movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');

%% plot A,U dependency 
%close all;

fig2=figure('DefaultAxesFontSize',12,'Units','normalized','OuterPosition',[0 0.4 0.7 0.6]);
title('Resistance vs. circumference and area');
subplot( 1, 2, 1 );
plot(U,1./R,'LineWidth',2);
title('Conductivity vs. Circumference');
xlabel('U(mm)');
ylabel('G(\Omega^{-1})');

subplot( 1, 2, 2 );
plot(A,1./R,'LineWidth',2);
title('Conductivity vs. Area');
xlabel('A(mm^2)');
ylabel('G(\Omega^{-1})');

print(char(strcat('R_vs_A_and_U')),'-dpng','-r300');
movefile(char(strcat('R_vs_A_and_U','.png')),'fits');

%% compare with drude 
%close all;

l=0.02;
w=[0.01,0.015,0.02,0.03,0.04,0.05];
t=0.0001;
mu=200;
n=1e19;

R_drude=zeros(length(w),1);
for i=1:length(w)
    R_drude(i)=drude_resistance(l,w(i),t,mu,n);
end

fig3=figure('DefaultAxesFontSize',12,'Units','normalized','OuterPosition',[0 0.4 0.7 0.6]);

subplot( 1, 2, 2 );
plot(U,1./R,U,1./R_drude,'LineWidth',2);
xlabel('U(mm)');
ylabel('G(\Omega^{-1})');

subplot( 1, 2, 1 );
plot(A,1./R,A,1./R_drude,'LineWidth',2);
xlabel('A(mm^2)');
ylabel('G(\Omega^{-1})');

print(char(strcat('Drude_comparison')),'-dpng','-r300');
movefile(char(strcat('Drude_comparison','.png')),'fits');