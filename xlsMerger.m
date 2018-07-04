% misc and cleaning 
clear all;close all;
addpath(genpath('C:\Users\Kamphausen\sciebo\ZnSe\Matlab script'))
files={'C:\Users\Kamphausen\sciebo\ZnSe\wafer\M12-0169_ZnSeCl_Al insitu\U-I data\TLM dark\2018-06-20_M12-169_30_um_TLM.xls';'C:\Users\Kamphausen\sciebo\ZnSe\wafer\M12-0169_ZnSeCl_Al insitu\U-I data\TLM dark\2018-06-20_M12-169_60_um_TLM.xls';'C:\Users\Kamphausen\sciebo\ZnSe\wafer\M12-0169_ZnSeCl_Al insitu\U-I data\TLM dark\2018-06-20_M12-169_90_um_TLM.xls';'C:\Users\Kamphausen\sciebo\ZnSe\wafer\M12-0169_ZnSeCl_Al insitu\U-I data\TLM dark\2018-06-20_M12-169_120_um_TLM.xls';'C:\Users\Kamphausen\sciebo\ZnSe\wafer\M12-0169_ZnSeCl_Al insitu\U-I data\TLM dark\2018-06-20_M12-169_150_um_TLM.xls';'C:\Users\Kamphausen\sciebo\ZnSe\wafer\M12-0169_ZnSeCl_Al insitu\U-I data\TLM dark\2018-06-20_M12-169_180_um_TLM.xls'};
sheets={'Append1';'Append1';'Append1';'Append1';'Append1';'Append1'};
list=[files,sheets];
xlsmerge(list,'2018-06-20_M12-169_TLM_30...180_um.xls');