% createCustomDBFromExcel Create custom units database file from Excel 
% spreadsheet that contains custom units
%
%   Usage:
%       createCustomDBFromExcel('unitsDB.xlsx') generates a custom units
%       database with name 'unitsDB.slunitdb.mldatx'.
%
%       createCustomDBFromExcel('unitsDB.xlsx', FILENAME) specifies output
%       file name as FILENAME.
%
%   Create an input spreadsheet that defines units. This spreedsheet must
%   contain these columns in this order:
%       name                : unit name (in any graphical Unicode character
%                             except @ * / ^ ( ) + \ " ' { } [ ] < > & - :: and whitespace)
%       symbol              : symbol of unit (in any graphical Unicode character
%                             except @ * / ^ ( ) + \ " ' { } [ ] < > & - :: and whitespace)
%       asciiSymbol         : symbol of unit (ASCII)
%       displayName         : name of unit displayed in model (LaTeX format)
%       definitionExpression: definition of unit in terms of predefined units such as seven base SI units
%       conversionFactor    : conversion factor between unit and its definition
%       conversionOffset    : conversion offset between unit and its definition
%       physicalQuantity    : valid physical quantities (see table
%                             'Physical Quantities' in showunitslist)
%       provenance(optional): list of unit provenances (separate by comma)
%
%   Example of a unit definition:
%       name                : ounce_force
%       symbol              : ozf
%       asciiSymbol         : ozf
%       displayName         : {\rm{}oz_{force}}
%       definitionExpression: oz*gn
%       conversionFactor    : 1
%       conversionOffset    : 0
%       physicalQuantity    : force
%
%
%   If the input spreedsheet contains more then one worksheet, you must name 
%   the worksheets with prefixes "unit", "physicalQuantity", or "provenance". 
%   If there are multiple instances of a prefix for a worksheet, the function 
%   uses all the worksheets to create the database.
%   sheet names with prefix "unit" will be used to create units
%   sheet names with prefix "physicalQuantity" will be used to create physical quantities
%   sheet names with prefix "provenance" will be used to create provenances
%
%   (optional) You can define physical quantities in another worksheet of
%   the input spreedsheet.
%   A worksheet defining physical quantities contains these columns in this order:
%       name                : physical quantity name (in any graphical Unicode characters
%                             except @ * / ^ ( ) + \ " ' { } [ ] < > & - :: whitespace)
%       definitionExpression: definition of physical quantity in terms of predefined physical quantities
%       provenance(optional): list of physical quantity provenances (separate by comma)
%
%   (optional) You can define provenances in another worksheet of
%   the input spreedsheet.
%   A worksheet defining provenances contains these columns in this order:
%       identifier          : identifier of provenance
%       title               : title of provenance
%       subTitle            : subtitle of provenance
%       organization        : organization of provenance
%       fullName            : full name of provenance
%       urlList             : list of URL links of provenance
%       edition             : provenance edition
%       year                : provenance year
%
%   Example
%       createCustomDBFromExcel unitsDB.xlsx
%       createCustomDBFromExcel unitsDB.xlsx unitsDatabase.slunitdb.mldatx
%
%   See Also rehashUnitDBs.
%

%   Copyright 2019 The MathWorks, Inc.

function createCustomDBFromExcel(file, outFile)

    sheet_name = sheetnames(file);

    UNIT = 'unit';
    PHYSICALQUANTITY = 'physicalQuantity';
    PROVENANCE =  'provenance';

    sheetIdxUnit = [];
    sheetIdxPQ = [];
    sheetIdxProv = [];

    customDB = customUnitDatabase();
    % split sheets by sheetName
    if numel(sheet_name) == 1
        if strncmpi(sheet_name{1}, PHYSICALQUANTITY, length(PHYSICALQUANTITY))
            sheetIdxPQ = [1]; %#ok
        elseif strncmpi(sheet_name{1}, PROVENANCE, length(PROVENANCE))
            sheetIdxProv = [1]; %#ok
        else
            sheetIdxUnit = [1]; %#ok
        end
    else
        for k = 1:numel(sheet_name)
            if strncmpi(sheet_name{k}, UNIT, length(UNIT))
                sheetIdxUnit(end+1) = k; %#ok
            elseif strncmpi(sheet_name{k}, PHYSICALQUANTITY, length(PHYSICALQUANTITY))
                sheetIdxPQ(end+1) = k; %#ok
            elseif strncmpi(sheet_name{k}, PROVENANCE, length(PROVENANCE))
                sheetIdxProv(end+1) = k; %#ok
            end
        end
    end

    % add provenances
    for idx = sheetIdxProv
        data = loc_readFormatedSheet(file, sheet_name{idx}, 'provenance');
        loc_addCustomProvenances(customDB, data, sheet_name{idx});
    end

    % add physical quantities
    for idx = sheetIdxPQ
        data = loc_readFormatedSheet(file, sheet_name{idx}, 'physicalQuantity');
        loc_addCustomPQs(customDB, data, sheet_name{idx});
    end

    % add units
    for idx = sheetIdxUnit
        data = loc_readFormatedSheet(file, sheet_name{idx}, 'unit');
        loc_addCustomUnits(customDB, data, sheet_name{idx});
    end

    % Serialize the database
    if nargin < 2 || isempty(outFile)
        outFile = file;
    end
    
    % If outFile contains extension
    [~,name_ext, mldatxExt] = fileparts(outFile);
    [~,name, slunitExt] = fileparts(name_ext);
    if(isequal(mldatxExt, '.mldatx') && isequal(slunitExt, '.slunitdb'))
        filePath = name;
    else
        filePath = name_ext;
    end
    
    customDB.serializeToDisk(filePath); %creates mldatx file
end

function data = loc_readFormatedSheet(file, sheet_name, type) 
    opts = detectImportOptions(file, 'Sheet', sheet_name);
    if isequal(type, 'unit')
        defaultVariableNames = {'name', 'symbol', 'asciiSymbol', 'displayName', ...
        'definitionExpression', 'conversionFactor', 'conversionOffset', 'physicalQuantity'};
        defaultVariableTypes = {'char', 'char', 'char', 'char', 'char', 'double', 'double', 'char'};
    elseif isequal(type, 'physicalQuantity')
        defaultVariableNames = {'name', 'definitionExpression'};
        defaultVariableTypes = {'char', 'char'};
    elseif isequal(type, 'provenance')
        defaultVariableNames = {'identifier', 'title', 'subTitle', 'organization',...
                            'fullName', 'urlList', 'edition', 'year'};
        defaultVariableTypes = {'char', 'char', 'char', 'char', 'char', 'char', 'char', 'double'};
    end

    % check missing columns
    missingVariables = setdiff(defaultVariableNames, opts.VariableNames);
    if ~isempty(missingVariables)
        ME = MException(message('Simulink:Unit:ExcelMissingColumns', opts.Sheet, strjoin(missingVariables, ',')));
        throw(ME);
    end
   
    % read data
    opts = setvartype(opts, defaultVariableNames, defaultVariableTypes);
    data = readtable(file, opts, 'Sheet', sheet_name);

    % check empty name/identifier
    if isequal(type, 'provenance')
        name_identifier = 'identifier';
    else
        name_identifier = 'name';
    end
    allMissing = all(ismissing(data), 2);
    [data, nameMissing] = rmmissing(data, 'DataVariables', name_identifier);
    nameMissing = nameMissing.*(~allMissing);
    if any(nameMissing)
        missingRows = find(nameMissing) + 1; % first row is column name
        missingRowsStr = strjoin(string(missingRows), ', ');
        warning(message('Simulink:Unit:ExcelInvalidEntrySkipRowWarning', missingRowsStr, opts.Sheet, name_identifier));
    end
    
    % remove empty
    data = rmmissing(data, 'MinNumMissing', length(data.Properties.VariableNames));

    % warns for duplicates
    [data, ~, ic] = unique(data);
    duplicate_data = data(accumarray(ic, 1)>1, :);
    if ~isempty(duplicate_data)
        if isequal(type, 'provenance')
            warning(message('Simulink:Unit:ExcelDuplicateEntriesWarning', ...
                            strjoin(duplicate_data.identifier, ', '), opts.Sheet, 'identifier'));
        else
            warning(message('Simulink:Unit:ExcelDuplicateEntriesWarning', ...
                            strjoin(duplicate_data.name, ', '), opts.Sheet, 'name'));
        end
    end

    if isequal(type, 'unit')
        % check conflicting units name, symbol, asciiSymbol and displayName
        loc_checkConflicts(data.name, 'name', opts.Sheet);
        loc_checkConflicts(data.symbol, 'symbol', opts.Sheet);
        loc_checkConflicts(data.asciiSymbol, 'asciiSymbol', opts.Sheet);
        loc_checkConflicts(data.displayName, 'displayName', opts.Sheet);
    elseif isequal(type, 'physicalQuantity')
        % check conflicting PQ name
        loc_checkConflicts(data.name, 'name', opts.Sheet);
    elseif isequal(type, 'provenance')
        % check conflicting provenance identifier
        loc_checkConflicts(data.identifier, 'identifier', opts.Sheet);
    end
end

function customDB = loc_addCustomUnits(customDB, data, sheet_name)
    for i = 1:height(data)
        aUnit = customDB.createUnitToAdd(); 
        aUnit.name = data.name{i};
        aUnit.symbol = data.symbol{i};
        aUnit.asciiSymbol = data.asciiSymbol{i};
        aUnit.displayName = data.displayName{i};
        aUnit.definitionExpression = data.definitionExpression{i};
        aUnit.conversionFactor = data.conversionFactor(i);
        aUnit.conversionOffset = data.conversionOffset(i);
        aUnit.physicalQuantity = data.physicalQuantity{i};
        if any(strcmp(data.Properties.VariableNames, 'provenance')) && iscell(data.provenance)
            aUnit.provenance = strsplit(data.provenance{i}, {' ', ','});
        end

        [isValidUnit, aUnit] = loc_checkUnit(aUnit, sheet_name);
        if isValidUnit
            customDB.addUnit(aUnit);
        end
    end
end

function [valid, aUnit] = loc_checkUnit(aUnit, sheet_name)
    valid = true;
    % check PQ
    if isempty(aUnit.physicalQuantity)
        valid = false;
        warning(message('Simulink:Unit:ExcelInvalidUnitEmptyPQWarning', aUnit.name, sheet_name));
        return;
    end
    % if unit's symbol, asciiSymbol or displayName is empty, will use unit name as default value
    if isempty(aUnit.symbol)
        aUnit.symbol = aUnit.name;
    end
    if isempty(aUnit.asciiSymbol)
        aUnit.asciiSymbol = aUnit.name;
    end
    if isempty(aUnit.displayName)
        aUnit.displayName = aUnit.name;
    end

    if aUnit.displayName(1) ~= '{' || aUnit.displayName(1) ~= '}'
        aUnit.displayName = ['{' aUnit.displayName '}'];
    end

    % check unit name/symbol/displayName
    if  ~loc_validSymbol(aUnit.name) || ~loc_validSymbol(aUnit.symbol) || ...
            ~loc_validSymbol(aUnit.asciiSymbol)
        valid = false;
        warning(message('Simulink:Unit:ExcelInvalidUnitInvalidCharWarning', aUnit.name, sheet_name));
        return;
    end

    % check asciiSymbol
    if  ~loc_validASCII(aUnit.asciiSymbol)
        valid = false;
        warning(message('Simulink:Unit:ExcelInvalidUnitASCIIWarning', aUnit.name, sheet_name));
        return;
    end

    % check conversionFactor and conversionOffset
    if isnan(aUnit.conversionFactor) || isnan(aUnit.conversionOffset) || ...
        aUnit.conversionFactor == 0 || isinf(aUnit.conversionFactor) || isinf(aUnit.conversionOffset)
        valid = false;
        warning(message('Simulink:Unit:ExcelInvalidUnitInvalidNumericWarning', aUnit.name, sheet_name));
        return;
    end
end

function valid = loc_validASCII(asciiSymbol)
    valid = all(asciiSymbol <= char(127)) && all(asciiSymbol >= char(32));
end

function valid = loc_validSymbol(symbol)
    persistent invalidChar;
    invalidChar = '@*/^()+\''"{}[]<>&- ';
    valid =  isempty(intersect(symbol, invalidChar)) && ~contains(symbol, '::');
end

function customDB = loc_addCustomPQs(customDB, data, sheet_name)
    for i = 1:height(data)
        aPhysicalQuantity = customDB.createPhysicalQuantityToAdd();
        aPhysicalQuantity.name = data.name{i};
        aPhysicalQuantity.definitionExpression = data.definitionExpression{i};
        if any(strcmp(data.Properties.VariableNames, 'provenance')) && iscell(data.provenance)
            aPhysicalQuantity.provenance = strsplit(data.provenance{i}, {' ', ','});
        end
        if ~isempty(aPhysicalQuantity.definitionExpression)
            customDB.addPhysicalQuantity(aPhysicalQuantity);
        else
            warning(message('Simulink:Unit:ExcelInvalidPQWarning', ...
                aPhysicalQuantity.name, sheet_name));
        end
    end
end


function customDB = loc_addCustomProvenances(customDB, data, ~)
    for i = 1:height(data)
        aProvenance = customDB.createProvenanceToAdd();
        aProvenance.identifier = data.identifier{i};
        aProvenance.title = data.title{i};
        aProvenance.subTitle = data.subTitle{i};
        aProvenance.organization = data.organization{i};
        aProvenance.fullName = data.fullName{i};
        aProvenance.urlList = strsplit(data.urlList{i}, {' ', ','});
        aProvenance.edition = data.edition{i};
        aProvenance.year = data.year(i);
        customDB.addProvenance(aProvenance);
    end
end

function loc_checkConflicts(val, col, sheet_name)
    [val_uni, ~, ic] = unique(val);
    if length(val_uni) < length(val)
        counts = accumarray(ic, 1);
        duplicate_vals = val_uni(counts>1);
        ME = MException(message('Simulink:Unit:ExcelConflictingDataEntry', ...
            strjoin(duplicate_vals, ','), sheet_name, col));
        throw(ME);
    end
end
