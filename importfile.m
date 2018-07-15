function [SMU1I,VDIFF] = importfile(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   [SMU1I,VDIFF] = IMPORTFILE(FILE) reads data from the first worksheet in
%   the Microsoft Excel spreadsheet file named FILE and returns the data as
%   column vectors.
%
%   [SMU1I,VDIFF] = IMPORTFILE(FILE,SHEET) reads from the specified
%   worksheet.
%
%   [SMU1I,VDIFF] = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the
%   specified worksheet for the specified row interval(s). Specify STARTROW
%   and ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Non-numeric cells are replaced with: NaN
%
% Example:
%   [SMU1I,VDIFF] = importfile('2018-06-20_M12-169_squares.xls','Data',1,1203);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2018/06/21 14:16:03

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 1;
    endRow = 4100;
end

%% Import the data
[~, ~, raw1] = xlsread(workbookFile, sheetName, sprintf('B%d:B%d',startRow(1),endRow(1)));
[~, ~, raw2] = xlsread(workbookFile, sheetName, sprintf('F%d:F%d',startRow(1),endRow(1)));
raw = [raw1,raw2];
for block=2:length(startRow)
    [~, ~, tmpRawBlock1] = xlsread(workbookFile, sheetName, sprintf('B%d:B%d',startRow(block),endRow(block)));
    [~, ~, tmpRawBlock2] = xlsread(workbookFile, sheetName, sprintf('F%d:F%d',startRow(block),endRow(block)));
    raw = [raw;tmpRawBlock1,tmpRawBlock2]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
SMU1I = data(:,1);
VDIFF = data(:,2);

