% misc and cleaning 
clear all;close all;
%% locations
addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script'))

%%

structure = string('TLM');      % choose 'TLM' or 'Area'
format=string('*.xls');         % choose '*.xls' or '*.txt'

Evaluate(structure,format,'fitrangelin',0.1);