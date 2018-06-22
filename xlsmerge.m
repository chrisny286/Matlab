function xlsmerge( list,outputfile )
%UNTITLED8 Summary of this function goes here
%   input list of files and sheets to be mergen [ filename , sheetname ]
sheetoput={'Data' , 'Append1' , 'Append2' , 'Append3' , 'Append4' , 'Append5'};
N=length(list)
for i=1:N
    Sheetdata=xlsread(char(list(i,1)),char(list(i,2)));
    xlswrite(char(outputfile),Sheetdata,char(sheetoput(i)));
end
end

