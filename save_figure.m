% save plot function
% <save> is bool for saving data or not
function [] = save_figure(figure, name, save)
    figure.PaperPositionMode = 'auto';
	print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng','-r300')
	movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');
end