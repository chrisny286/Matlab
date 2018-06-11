% define path & measurement
clear all;close all;
addpath(genpath('\\Z\User AG Bluhm\Hartz\Data\DickeBertha\2018-06-06 143-1_cooldown'))
measurement = '2018_06_06_ZnSe_143-1_1to2_timetracekeithley_RT_Areas_5-5_cd_10';
load(measurement);

%read data, extract loop parameters from scan struct
valid_slices= 20; % only for the moment, has to be exchanged by "NAN" search in data
range = scan.loops.rng;
V1 = range(1);
V2 = range(2);
[N1, N2] = scan.loops.npoints;
volt = linspace(V1, V2, N1);
[I, U, T] =data_select(data, valid_slices);
fig1 = figure(1);
plot(volt, I)
fig2 = figure(2);
plot(volt, T)

save_figs(fig1, fig2)

