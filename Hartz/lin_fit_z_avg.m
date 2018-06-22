% x, y, z data may be arrays
% lin_fit makes linewise fits to data
% in this context (1K setup) z represents the sample temperaure
function [y_fit, z_avg] = lin_fit_z_avg(x_data, y_data, z_data)
    y_fit= % [p1,S1]=polyfit(polyfitdat1(:,1),polyfitdat1(:,2),n)
    z_avg = mean(z_data, 1)     % linewise averaging
end