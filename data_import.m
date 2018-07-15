% data import, in this case for area, ToDo: adapt import for
% TLM or Area (regarding distance or U/ A)
function [x, y, structure_legend, x2, x3] = data_import(sheet, file)
x=[];
y=[];
x3=[0.4 , 0.6 , 0.8 , 1.2, 1.6, 2.0];   % circumference
x2=[0.01,0.0225,0.04,0.09,0.16,0.25];   % area
structure_legend={};
for i=1:length(sheet)
    [xi,yi] =importfile(char(file),char(sheet(i)));
    x=[x,xi];
    y=[y,yi];
    structure_legend=[structure_legend,char(strcat(string(x3(i)),'mm',', ',string(x2(i)),'mm²'))];
end
disp(char(strcat('data import from file ', ' ', string(file), ' was successful.'))); 
end
