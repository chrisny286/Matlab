% assign data arrays to physical channels
% Todo: select the entries that are not "NAN"
function [curr, time, temp] = data_select(raw_data, lines)	
    curr = raw_data{1,1};
    curr = transpose(curr(1:lines,:));
    temp = raw_data{1,3};
    temp = transpose(temp(1:lines,:));
    time = raw_data{1,2};
    time = transpose(time(1:lines,:));
end