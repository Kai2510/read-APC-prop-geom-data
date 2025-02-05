function apcPropGeomData = readAPCgeom(filename, startRow, endRow)
%READAPCGEOM Import APC propeller performance data from file.
% APC geometry data files usually report data as tables. 
% All data are collected in a table, so that the variables
% can be extracted into a table and converted into a cell array.
% Finally, it converts each cell of cell array into a table and keeps 
% all the tables into the cell array adding columns in mm.
% That is, the output of the function is a table. If do not evaluate its
% result into variables, the function will plot the propeller's planar
% shape.
%
%   APCPROPGEOMDATA = READAPCGEOM(FILENAME)
%   Reads data from text file READAPCPERF for the default selection.
%
%   APCPROPGEOMDATA = READAPCGEOM(FILENAME, STARTROW, ENDROW)
%   Reads data from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   APCPROPGEOMDATA = READAPCGEOM('19x16_PERF.PE0');
%
%    See also TEXTSCAN.

% Edited by Li Zhikai on 2025/02/05

%% Initialize variables.
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this code. If an error occurs for a different file, try regenerating the code from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13]
    % Converts text in the input cell array to numbers. Replaced non-numeric text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;

            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% Split data into numeric and string columns.
rawNumericColumns = raw(:, [1,2,3,4,5,6,7,8,9,10,11,12,13]);
rawStringColumns = string(raw(:, 13));


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
idx = (rawStringColumns(:, 1) == "<undefined>");
rawStringColumns(idx, 1) = "";

%% Create output variable
apcPropGeomData = table;
apcPropGeomData.Station_IN = cell2mat(rawNumericColumns(:, 1));
apcPropGeomData.Chord_IN = cell2mat(rawNumericColumns(:, 2));
apcPropGeomData.Pitch_Quoted = cell2mat(rawNumericColumns(:, 3)); % "Quoted" = "Input"
apcPropGeomData.Pitch_LETE = cell2mat(rawNumericColumns(:, 4));
apcPropGeomData.Pitch_Prather = cell2mat(rawNumericColumns(:, 5)); % Pitch measured by Prather Gauge (桨距规)
apcPropGeomData.Sweep_IN = cell2mat(rawNumericColumns(:, 6));
apcPropGeomData.Thick_ratio = cell2mat(rawNumericColumns(:, 7));
apcPropGeomData.Twist_DEG = cell2mat(rawNumericColumns(:, 8));
apcPropGeomData.Max_Thick_IN = cell2mat(rawNumericColumns(:, 9));
apcPropGeomData.Cross_Section_IN2 = cell2mat(rawNumericColumns(:, 10));
apcPropGeomData.Z_High_IN = cell2mat(rawNumericColumns(:, 11));
apcPropGeomData.CG_Y_IN = cell2mat(rawNumericColumns(:, 12));
apcPropGeomData.CG_Z_IN = cell2mat(rawNumericColumns(:, 13));
apcPropGeomData.VarName14 = categorical(rawStringColumns(:, 1));

%% Edit table
apcPropGeomData.VarName14 = []; % remove last empty column
apcPropGeomData(1:24,:) = []; % remove first 24 rows
apcPropGeomData(end-25:end,:) = []; % remove last 25 rows
[nRows, ~] = size(apcPropGeomData);

%% Convert Units into metric
apcPropGeomData.Station_mm = apcPropGeomData.Station_IN * 25.4;
apcPropGeomData.Chord_mm = apcPropGeomData.Chord_IN *25.4 ;
apcPropGeomData.Pitch_Quoted_mm = apcPropGeomData.Pitch_Quoted * 25.4; % "Quoted" = "Input"
apcPropGeomData.Pitch_LETE_mm = apcPropGeomData.Pitch_LETE * 25.4;
apcPropGeomData.Pitch_Prather_mm = apcPropGeomData.Pitch_Prather * 25.4; % Pitch measured by Prather Gauge (桨距规)
apcPropGeomData.Sweep_mm = apcPropGeomData.Sweep_IN * 25.4;

apcPropGeomData.Twist_RAD = apcPropGeomData.Twist_DEG * pi / 180;
apcPropGeomData.Max_Thick_mm = apcPropGeomData.Max_Thick_IN * 25.4;
apcPropGeomData.Cross_Section_mm2 = apcPropGeomData.Cross_Section_IN2 * (25.4^2);
apcPropGeomData.Z_High_mm = apcPropGeomData.Z_High_IN * 25.4;
apcPropGeomData.CG_Y_mm = apcPropGeomData.CG_Y_IN * 25.4;
apcPropGeomData.CG_Z_mm = apcPropGeomData.CG_Z_IN * 25.4;

%% Output options - If do not evaluate, plot the propeller's shape in imperial unit.

    if nargout ~= 1
        plot (apcPropGeomData.Station_IN,apcPropGeomData.Chord_IN);
        xlabel('R\_Station [IN]'), ylabel('Chord [IN]'), title("Propeller's Planar Shape");
    end

%% display the data table for debugging
% disp(apcPropGeomData.Station_IN)
end