function [ output_args ] = Evaluate(structure, format, varargin)

%%
%   if file format is '*.txt' structure does not matter.
%
%   specify sheets with 'Sheets'
%   specify range for linear fit with 'fitrangelin' (Voltage range)
%
%
%

%create input parser
p = inputParser;

% add required vars
addRequired(p, 'structure', ...
            @(x) isstring(x)  && (x=='Area'  || x=='TLM'  ) );
addRequired(p, 'format', ...
            @(y) isstring(y)  && (y=='*.xls' || y=='*.txt') );

%add optional vars
addParameter(p,'Sheets',{'Data' , 'Append1' , 'Append2' , 'Append3' , 'Append4' , 'Append5'}, ...
            @(z) format=='*.xls' && iscellstr(z)            );
addParameter(p,'fitrangelin',inf, ...
            @(z) isnumeric(z)                               );
addParameter(p,'fitrangeexp',inf, ...
            @(z) isnumeric(z)                               );
        
%parse inputs
parse(p, structure, format, varargin{:})
        
%run evaluation in current folder
        if strcmp(p.Results.format, '*.xls')
           if strcmp(p.Results.structure, 'Area')
               xls_square_eval(p.Results.Sheets,p.Results.fitrangelin,p.Results.fitrangeexp);
           else
               TLMeval(p.Results.Sheets,p.Results.fitrangelin,p.Results.fitrangeexp);
           end
        else
            txteval();
        end
end

