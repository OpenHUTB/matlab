classdef SimscapeBlock < handle




properties ( Access = protected )
Handle = [  ];
end 

properties ( Dependent )
Name
Type
Library
LibraryPath
ComponentPath
BlockChoice
end 

properties ( Access = protected, Dependent )
ModelName
ShortName
end 

properties ( Access = private )
RefreshMaskWSVariables = true;
end 

properties 
MaskParameters
MaskInitialTargets
end 

methods 
function obj = SimscapeBlock( blockHandle, namedArgs )
R36
blockHandle
namedArgs.MaskParameters = "NumericValues";
namedArgs.MaskInitialTargets = "NumericValues";
end 

if isempty( blockHandle )

obj = foundation.internal.parameterization.SimscapeBlock.empty;
elseif numel( blockHandle ) == 1 && isa( blockHandle, 'double' )

obj.Handle = blockHandle;
obj.MaskParameters = namedArgs.MaskParameters;
obj.MaskInitialTargets = namedArgs.MaskInitialTargets;
else 
if isa( blockHandle, 'char' ) || isa( blockHandle, 'string' )
obj.Handle = get_param( blockHandle, 'Handle' );
obj.MaskParameters = namedArgs.MaskParameters;
obj.MaskInitialTargets = namedArgs.MaskInitialTargets;
else 
obj = repmat( foundation.internal.parameterization.SimscapeBlock( '' ), length( blockHandle ), 1 );
for blockIdx = 1:length( blockHandle )
switch class( blockHandle )
case 'double'
thisBlockHandle = blockHandle( blockIdx );
case 'cell'
thisBlockHandle = blockHandle{ blockIdx };
end 
obj( blockIdx, 1 ) = foundation.internal.parameterization.SimscapeBlock( thisBlockHandle );
obj( blockIdx, 1 ).MaskParameters = namedArgs.MaskParameters;
obj( blockIdx, 1 ).MaskInitialTargets = namedArgs.MaskInitialTargets;
end 
end 
end 
end 

function value = get.BlockChoice( obj )

if isempty( obj.Handle )
value = '';
else 
componentPath = get_param( obj.Handle, 'ComponentPath' );
componentVariants = split( get_param( obj.Handle, 'ComponentVariants' ), ',' );

componentVariants = regexprep( componentVariants, '^\W*|\W*$', '' );
componentVariantNames = split( get_param( obj.Handle, 'ComponentVariantNames' ), ',' );

componentVariantNames = regexprep( componentVariantNames, '^\W*|\W*$', '' );

componentMap = containers.Map( componentVariants, componentVariantNames );
value = componentMap( componentPath );
end 
try 
value = getString( message( value ) );
catch 

end 
end 

function value = get.ComponentPath( obj )

if isempty( obj.Handle )
value = '';
else 
value = get_param( obj.Handle, 'ComponentPath' );
end 
end 

function value = get.Library( obj )

if isempty( obj.Handle )
value = '';
else 


value = strtok( obj.LibraryPath, '/' );
end 
end 

function value = get.LibraryPath( obj )

if isempty( obj.Handle )
value = '';
else 
value = get_param( obj.Handle, 'ReferenceBlock' );
end 
end 

function value = get.ModelName( obj )

if isempty( obj.Handle )
value = '';
else 
value = get_param( bdroot( obj.Handle ), 'Name' );
end 
end 

function value = get.Name( obj )

if isempty( obj.Handle )
value = '';
else 
value = [ get_param( obj.Handle, 'Parent' ), '/', get_param( obj.Handle, 'Name' ) ];
value = strrep( value, newline, ' ' );
end 
end 

function value = get.ShortName( obj )

value = regexprep( obj.Name, sprintf( '^%s/', obj.ModelName ), '' );
end 

function value = get.Type( obj )

if isempty( obj.Handle )
value = '';
else 
value = get_param( obj.Handle, 'MaskType' );

value = strrep( value, newline, ' ' );
end 
end 

function [ value ] = getCombinedParameters( obj, maxBlocksPerTable )




if ~exist( 'maxBlocksPerTable', 'var' )
maxBlocksPerTable = inf;
end 








libraryPath = { obj.LibraryPath }';
uniqueLibraryPath = unique( libraryPath, 'stable' );

valueIdx = 1;
for uniqueLibraryPathIdx = 1:length( uniqueLibraryPath )

thisLibraryPath = uniqueLibraryPath( uniqueLibraryPathIdx );
blockLibraryIdx = strcmp( thisLibraryPath, libraryPath );
theseLibraryBlocks = obj( blockLibraryIdx );




componentPath = { theseLibraryBlocks.ComponentPath }';
uniqueComponentPath = unique( componentPath, 'stable' );



numEmptyUniqueComponentPaths = 0;
for uniqueComponentPathIdx = 1:length( uniqueComponentPath )

thisComponentPath = uniqueComponentPath( uniqueComponentPathIdx );
blockComponentIdx = strcmp( thisComponentPath, componentPath );
theseBlocks = theseLibraryBlocks( blockComponentIdx );


variableNames = cell( 1, 2 * length( theseBlocks ) );

visibleIdx = [  ];

outputTable = theseBlocks( 1 ).getParameters;
if ~isempty( outputTable )
outputTable = outputTable( :, { 'Tab', 'Label' } );
for blockIdx = 1:length( theseBlocks )

thisBlock = theseBlocks( blockIdx );
paramTable = thisBlock.getParameters(  );


variableNames{ blockIdx * 2 - 1 } = thisBlock.ShortName;
variableNames{ blockIdx * 2 } = getString( message( 'physmod:simscape:utils:BlockParameterizationManager:Unit' ) );



Value = paramTable.Value;
VisibilityIdx = paramTable.Visible;
enumIdx = cellfun( @( x )~isempty( x ), paramTable{ :, 'EnumString' } );
Value( enumIdx ) = paramTable{ enumIdx, 'EnumString' };




outputTable = addvars( outputTable, Value );

Unit = paramTable.Unit;
Unit( enumIdx ) = { '' };



outputTable = addvars( outputTable, Unit );



if isempty( visibleIdx )

visibleIdx = paramTable.Visible;
else 

visibleIdx = visibleIdx | paramTable.Visible;
end 
end 




rowIsEnum = enumIdx;

if length( unique( outputTable.Tab ) ) == 1

rowNames = outputTable.Label;
else 


if size( outputTable, 1 ) == 1
rowNameStrings = [ { outputTable.Tab }, { outputTable.Label } ]';
else 
rowNameStrings = [ outputTable.Tab, outputTable.Label ]';
end 

rowNames = split( sprintf( '%s>%s\n', rowNameStrings{ : } ), newline );

rowNames = rowNames( cellfun( @( x )~isempty( x ), rowNames ) );

rowNames = regexprep( rowNames, '^>', '' );
end 

outputTable = removevars( outputTable, { 'Tab', 'Label' } );






outputTable = addprop( outputTable, { 'Visible', 'DisplayVariableNames', 'DisplayRowNames', 'LibraryPath', 'ComponentPath', 'BlockChoice', 'RowIsEnum', 'TitleConfig', 'InformationConfig' }, { 'table', 'variable', 'table', 'table', 'table', 'table', 'table', 'table', 'table' } );
outputTable.Properties.CustomProperties.Visible = VisibilityIdx;
outputTable.Properties.CustomProperties.DisplayRowNames = rowNames;
outputTable.Properties.CustomProperties.DisplayVariableNames = variableNames;
outputTable.Properties.CustomProperties.LibraryPath = thisLibraryPath{ 1 };
outputTable.Properties.CustomProperties.ComponentPath = thisComponentPath{ 1 };
outputTable.Properties.CustomProperties.BlockChoice = theseBlocks( 1 ).BlockChoice;
outputTable.Properties.CustomProperties.RowIsEnum = rowIsEnum;
if uniqueComponentPathIdx == 1 && uniqueLibraryPathIdx == 1


outputTable.Properties.CustomProperties.TitleConfig = 'TextWithId';
else 

outputTable.Properties.CustomProperties.TitleConfig = 'None';
end 
if length( uniqueLibraryPath ) > 1 && length( uniqueComponentPath ) == 1


outputTable.Properties.CustomProperties.InformationConfig = 'Library';
elseif length( uniqueComponentPath ) > 1 && length( uniqueLibraryPath ) == 1


outputTable.Properties.CustomProperties.InformationConfig = 'BlockChoice';
elseif length( uniqueLibraryPath ) > 1 && length( uniqueComponentPath ) > 1



outputTable.Properties.CustomProperties.InformationConfig = 'LibraryAndBlockChoice';
else 

outputTable.Properties.CustomProperties.InformationConfig = 'None';
end 
end 

if maxBlocksPerTable > 0 ...
 && ~isempty( outputTable ) ...
 && isfinite( maxBlocksPerTable ) ...
 && length( theseBlocks ) > maxBlocksPerTable

maxColumnsPerTable = maxBlocksPerTable * 2;
startColumns = 1:maxColumnsPerTable:width( outputTable );
endColumns = maxColumnsPerTable:maxColumnsPerTable:width( outputTable );
if endColumns( end  ) ~= width( outputTable )
endColumns = [ endColumns, width( outputTable ) ];%#ok<AGROW>
end 
for outputIdx = 1:length( startColumns )
thisStartColumn = startColumns( outputIdx );
thisEndColumn = endColumns( outputIdx );
theseColumns = outputTable( :, thisStartColumn:thisEndColumn );
if outputIdx > 1



theseColumns.Properties.CustomProperties.TitleConfig = 'None';
theseColumns.Properties.CustomProperties.InformationConfig = 'None';
end 
value{ valueIdx } = theseColumns;%#ok<AGROW>
valueIdx = valueIdx + 1;
end 
elseif ~isempty( outputTable ) ...
 || numEmptyUniqueComponentPaths == 0

value{ valueIdx } = outputTable;
valueIdx = valueIdx + 1;
if isempty( outputTable )
numEmptyUniqueComponentPaths = 1;
end 
end 
end 
end 


if ~exist( 'value', 'var' )
value = table;
elseif length( value ) == 1
value = value{ 1 };
end 
end 

function value = getParameters( obj )

value = cell( size( obj ) );

for objIdx = 1:length( obj )
thisObj = obj( objIdx );


schema = physmod.schema.internal.blockComponentSchema( thisObj.Handle );
schemaInfo = schema.info(  );


schemaParameters = schemaInfo.Members.Parameters;
parameterVisibilities = getParameterVisibility( thisObj.Handle );


parameters = struct( 'Id', { '' }, 'Tab', { schemaParameters.Group }, 'Label', { schemaParameters.Label }, 'Value', { {  } }, 'Unit', { '' }, 'EnumString', { '' }, 'Visible', { [  ] } );



tmp = get_param( thisObj.Handle, schemaParameters( 1 ).ID );
if obj.RefreshMaskWSVariables
set_param( thisObj.Handle, schemaParameters( 1 ).ID, tmp );
end 


maskWSVariables = get_param( thisObj.Handle, 'MaskWSVariables' );
md = cell2struct( { maskWSVariables.Value }, { maskWSVariables.Name }, 2 );


for parameterIdx = 1:numel( parameters )
id = schemaParameters( parameterIdx ).ID;
parameters( parameterIdx ).Id = id;
parameters( parameterIdx ).Visible = parameterVisibilities.( id );



if obj.RefreshMaskWSVariables
parameters( parameterIdx ).Value = { md.( id ) };
else 
parameters( parameterIdx ).Value = get_param( thisObj.Handle, id );
end 
parameters( parameterIdx ).Unit = pm_canonicalunit( md.( [ id, '_unit' ] ) );

if ( iscell( parameters( parameterIdx ).Value ) ...
 && isenum( parameters( parameterIdx ).Value{ 1 } ) ) ...
 || ( ischar( schemaParameters( parameterIdx ).Default.Value ) ...
 && contains( schemaParameters( parameterIdx ).Default.Value, '.enum.' ) )



enumData = pm.sli.getEnumData( schemaParameters( parameterIdx ).Default.Value );
if isempty( enumData )
enumData = pm.sli.getEnumData( parameters( parameterIdx ).Value{ 1 } );
end 
if iscell( parameters( parameterIdx ).Value ) ...
 && ischar( parameters( parameterIdx ).Value{ 1 } )
parameters( parameterIdx ).Value{ 1 } = str2num( parameters( parameterIdx ).Value{ 1 } );
end 
if ischar( parameters( parameterIdx ).Value )
parameters( parameterIdx ).EnumString =  ...
enumData.enumValMap{  ...
strcmp( parameters( parameterIdx ).Value, enumData.enumValMap ) };
else 
parameters( parameterIdx ).EnumString =  ...
enumData.enumValMap{  ...
parameters( parameterIdx ).Value{ 1 } == enumData.enumValues };
end 
elseif length( schemaParameters( parameterIdx ).Choices ) > 1


enumValue = parameters( parameterIdx ).Value{ 1 };
mapKeys = { schemaParameters( parameterIdx ).Choices( : ).Expression };
mapKeys = cellfun( @str2num, mapKeys, 'UniformOutput', false );
mapValues = { schemaParameters( parameterIdx ).Choices( : ).Description };
displayTextMap = containers.Map( mapKeys, mapValues );
if ischar( enumValue )
enumValue = str2num( enumValue );%#ok<*ST2NM>
end 
parameters( parameterIdx ).EnumString = displayTextMap( enumValue );
end 



if iscell( parameters( parameterIdx ).Value ) ...
 && isempty( parameters( parameterIdx ).Value{ 1 } )
parameters( parameterIdx ).Value = getString(  ...
message( 'physmod:simscape:utils:BlockParameterizationManager:UnrecognizedFunctionOrVariable' ) );
end 
end 
end 


if isempty( parameters )

value{ objIdx } = table;
else 
paramTable = struct2table( parameters, 'AsArray', true );
paramTable.Properties.RowNames = paramTable.Id;
paramTable = removevars( paramTable, 'Id' );
value{ objIdx } = paramTable;
end 

if length( obj ) == 1
value = value{ 1 };
end 
end 

function value = getVariables( obj )

value = cell( size( obj ) );

for objIdx = 1:length( obj )
thisObj = obj( objIdx );


schema = physmod.schema.internal.blockComponentSchema( thisObj.Handle );
schemaInfo = schema.info(  );


schemaVariables = schemaInfo.Members.Variables;
parameterVisibilities = getParameterVisibility( thisObj.Handle );


variables = struct( 'Id', { '' }, 'Tab', { schemaVariables.Group }, 'Label', { schemaVariables.Label }, 'Value', { {  } }, 'Unit', { '' }, 'EnumString', { '' }, 'Visible', { [  ] } );



tmp = get_param( thisObj.Handle, schemaVariables( 1 ).ID );
if obj.RefreshMaskWSVariables
set_param( thisObj.Handle, schemaVariables( 1 ).ID, tmp );
end 


maskWSVariables = get_param( thisObj.Handle, 'MaskWSVariables' );
md = cell2struct( { maskWSVariables.Value }, { maskWSVariables.Name }, 2 );


for parameterIdx = 1:numel( variables )
id = schemaVariables( parameterIdx ).ID;
variables( parameterIdx ).Id = id;
variables( parameterIdx ).Visible = parameterVisibilities.( id );



if obj.RefreshMaskWSVariables
variables( parameterIdx ).Value = { md.( id ) };
else 
variables( parameterIdx ).Value = get_param( thisObj.Handle, id );
end 
variables( parameterIdx ).Unit = pm_canonicalunit( md.( [ id, '_unit' ] ) );




if iscell( variables( parameterIdx ).Value ) ...
 && isempty( variables( parameterIdx ).Value{ 1 } )
variables( parameterIdx ).Value = getString(  ...
message( 'physmod:simscape:utils:BlockParameterizationManager:UnrecognizedFunctionOrVariable' ) );
end 
end 
end 


if isempty( variables )

value{ objIdx } = table;
else 
variableTable = struct2table( variables, 'AsArray', true );
variableTable.Properties.RowNames = variableTable.Id;
variableTable = removevars( variableTable, 'Id' );
value{ objIdx } = variableTable;
end 

if length( obj ) == 1
value = value{ 1 };
end 
end 

function exportMaskVariableNamesToFile( obj, fileName, headerName, sectionName, textToRemove )
if ~exist( "textToRemove", "var" )
textToRemove = "";
end 
if ~exist( fileName, "file" )
firstCharacter = "";
else 
firstCharacter = newline;
end 


fid = fopen( fileName, "a" );
fileCleanup = onCleanup( @(  )fclose( fid ) );

fprintf( fid, "%s%%%% %s\n", firstCharacter, headerName );
isRepmatPragmaRequired = false;

for objIdx = 1:length( obj )
thisObj = obj( objIdx );
variablePrefix = thisObj.( sectionName );
variablePrefix = strrep( variablePrefix, textToRemove, "" );
variablePrefix = strrep( variablePrefix, "/", "." );
fprintf( fid, "\n%%%% %s\n", variablePrefix );
thisObj.RefreshMaskWSVariables = false;
parameters = thisObj.getParameters;
variables = thisObj.getVariables;
maskVariableNames = [ parameters;variables ];
thisObj.RefreshMaskWSVariables = true;

for maskVariableNameIdx = 1:height( maskVariableNames )
isVisible = maskVariableNames{ maskVariableNameIdx, "Visible" };
tabName = maskVariableNames{ maskVariableNameIdx, "Tab" }{ 1 };
isInitialTarget = strcmp( getString( message( "physmod:simscape:gui:mli:customgui:VariablesContainer" ) ), tabName );
isParameter = ~isInitialTarget;
if ~isVisible ...
 || ( isInitialTarget && thisObj.MaskInitialTargets == "NumericValues" ) ...
 || ( isParameter && thisObj.MaskParameters == "NumericValues" )
continue 
end 
maskVariableName = maskVariableNames.Properties.RowNames{ maskVariableNameIdx, 1 };
isNotEnum = isempty( maskVariableNames{ maskVariableName, "EnumString" }{ 1 } );
if isNotEnum
variableName = variablePrefix + "." + maskVariableName;
variableValue = maskVariableNames{ maskVariableName, "Value" }{ 1 };
if ~isRepmatPragmaRequired && contains( variableValue, "repmat" )
isRepmatPragmaRequired = true;
end 
variableDescription = maskVariableNames{ maskVariableName, "Label" }{ 1 };
variableUnit = maskVariableNames{ maskVariableName, "Unit" }{ 1 };
if strcmp( variableUnit, '1' )
variableSuffix = '';
else 
variableSuffix = [ ', ', variableUnit ];
end 

fprintf( fid, '%s = %s; %% %s%s\n',  ...
variableName,  ...
variableValue,  ...
variableDescription,  ...
variableSuffix );
end 
end 
end 
if isRepmatPragmaRequired
fprintf( fid, '\n%% Suppress MATLAB editor message regarding readability of repmat\n%%#ok<*REPMAT>\n' );
end 

end 

function updateMaskToVariableNames( obj, sectionName, textToRemove )
if ~exist( "textToRemove", "var" )
textToRemove = "";
end 

for objIdx = 1:length( obj )
thisObj = obj( objIdx );
thisObj.RefreshMaskWSVariables = false;
parameters = thisObj.getParameters;
variables = thisObj.getVariables;
maskVariableNames = [ parameters;variables ];
thisObj.RefreshMaskWSVariables = true;
variablePrefix = thisObj.( sectionName );
variablePrefix = strrep( variablePrefix, textToRemove, "" );
variablePrefix = strrep( variablePrefix, "/", "." );

for maskVariableNameIdx = 1:height( maskVariableNames )
isVisible = maskVariableNames{ maskVariableNameIdx, "Visible" };
tabName = maskVariableNames{ maskVariableNameIdx, "Tab" }{ 1 };
isInitialTarget = strcmp( getString( message( "physmod:simscape:gui:mli:customgui:VariablesContainer" ) ), tabName );
isParameter = ~isInitialTarget;
if ~isVisible ...
 || ( isInitialTarget && thisObj.MaskInitialTargets == "NumericValues" ) ...
 || ( isParameter && thisObj.MaskParameters == "NumericValues" )
continue 
end 
maskVariableName = maskVariableNames.Properties.RowNames{ maskVariableNameIdx, 1 };
variableName = variablePrefix + "." + maskVariableName;
isNotEnum = isempty( maskVariableNames{ maskVariableName, "EnumString" }{ 1 } );
if isNotEnum
set_param( thisObj.Name, maskVariableName, variableName );
end 
if isInitialTarget
set_param( thisObj.Name, [ maskVariableName, '_specify' ], 'on' );
end 
end 
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp_lndIM.p.
% Please follow local copyright laws when handling this file.

