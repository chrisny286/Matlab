% define path & measurement
clear all; close all;
addpath(genpath('\\Z\User AG Bluhm\Hartz\data\DickeBertha\2018-06-06 143-1_cooldown'))
% measurement = '2018_06_06_ZnSe_143-1_1to2_timetracekeithley_RT_Areas_5-5_cd_4'; % ...2-10
measurement = '2018_06_06_ZnSe_143-1_1to2_timetracekeithley_RT_Areas_4-4_continued_3';
load(measurement);

linewise_plot = figure(); % opens a new figure if required,
surface_plot = figure();
measurement_plot = figure();
%specify labels:
figure_title = 'sample 0143-1\ncooldown under IR illumination';
x_name = 'voltage (V)';
y_name = 'temperature (K)';
z_name = 'current (I)';

% read data, extract loop parameters from scan struct
range = scan.loops.rng;
V1 = range(1); V2 = range(2);
[N1, N2] = scan.loops.npoints;
volt = linspace(V1, V2, N1);
[I, T, time] = data_select(data, 200);
U= transpose(repelem(volt, 200, 1));

% reconstruct matlab measurement output:
figure(measurement_plot);
subplot(2, 2, 1);
plot(volt, I)
subplot(2, 2, 2);
plot(volt, T)
% save_figs(fig1, fig2)

% get fit parameters:
p={}; intercept=[]; slope=[];
for ii=1:size(U,2)
  if  any(isnan(U(:,ii)))
      range = ii-1
      break
  else
      I_ii = transpose(I(:,ii))
      p{ii} = polyfit(volt,I_ii,1);
      slope(ii)= p{1,ii}(1);
      intercept(ii)= p{1,ii}(2);
  end
  lin_fit_params = p;
  range;
end

% plot all linear fits in fig_linewise
figure(linewise_plot);
hold on
for ii=1:range
    single_fit = polyval([slope(ii), intercept(ii)], volt);
    plot(volt, single_fit);
end
xlabel(x_name);
ylabel(y_name);
title(figure_title);
hold off

% surface plot
figure(surface_plot);
[X,Y] = meshgrid(U, T);
Z = I;
surf(U,T,I);
xlabel(x_name);
ylabel(y_name);
zlabel(z_name);
title(figure_title);
