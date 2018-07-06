<<<<<<< HEAD
% save plot function
% <save> is bool for saving data or not
function [] = save_figure(figure, name, res, save_bool)
    if save_bool
        figure.PaperPositionMode = 'auto';
    	print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng',res)
        movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');
    else
        printf('figure not saved. Please set save to <true>.')
    end
=======
% save plot function
% <save> is bool for saving data or not
function [] = save_figure(figure, name, res, save_bool)
    if save_bool
        figure.PaperPositionMode = 'auto';
    	print(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'-dpng',res)
        movefile(char(strcat('linfit_',string(xmin),'V_',string(xmax),'V_Areas','.png')),'fits');
    else
        printf('figure not saved. Please set save to <true>.')
    end
>>>>>>> develop
end