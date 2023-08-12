function varargout = read_sfunwiz( SfunName )









fileHandler = fopen( SfunName, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', SfunName );
end 
INSFunCode = fread( fileHandler, '*char' )';
fclose( fileHandler );

defineCode = regexp( INSFunCode, '(?m)^\h*/\* %%%-SFUNWIZ_defines_Changes_BEGIN .*?\*/\r?$\n?(?<defines>.*?)^\h*/\* %%%-SFUNWIZ_defines_Changes_END .*?\*/\r?$\n?', 'names' );
defineCode = defineCode.defines;

clear INSFunCode
outStrBuffer = "";

sfbRevision = regexp( defineCode, '(?m)^\s*#define\s*?SFUNWIZ_REVISION\s*?(?<value>\<\S*?\>)\s*?$', 'names' );
sfbRevision = sfbRevision.value;


if strcmp( sfbRevision, '1.0' )
miscKeys = [ "INPUT_0_WIDTH", "INPUT_0_FEEDTHROUGH", "OUTPUT_0_WIDTH",  ...
"NPARAMS", "SAMPLE_TIME_0", "NUM_DISC_STATES", "DISC_STATES_IC",  ...
"NUM_CONT_STATES", "CONT_STATES_IC", "SFUNWIZ_GENERATE_TLC",  ...
"SOURCEFILES", "PANELINDEX" ];
mapADStrcutFields = { 'InputPortWidth', 'DirectFeedThrough', 'OutputPortWidth',  ...
'NumberOfParameters', 'SampleTime', 'NumberOfDiscreteStates', 'DiscreteStatesIC',  ...
'NumberOfContinuousStates', 'ContinuousStatesIC', 'GenerateTLC',  ...
'LibraryFilesText', 'PanelIndex' };
else 
miscKeys = [ "NPARAMS", "SAMPLE_TIME_0", "NUM_DISC_STATES", "DISC_STATES_IC",  ...
"NUM_CONT_STATES", "CONT_STATES_IC", "SFUNWIZ_GENERATE_TLC",  ...
"SOURCEFILES", "PANELINDEX", "USE_SIMSTRUCT", "SHOW_COMPILE_STEPS",  ...
"CREATE_DEBUG_MEXFILE", "SAVE_CODE_ONLY" ];
mapADStrcutFields = { 'NumberOfParameters', 'SampleTime', 'NumberOfDiscreteStates', 'DiscreteStatesIC',  ...
'NumberOfContinuousStates', 'ContinuousStatesIC', 'GenerateTLC',  ...
'LibraryFilesText', 'PanelIndex', 'UseSimStruct', 'ShowCompileSteps',  ...
'CreateDebugMex', 'SaveCodeOnly' };
end 
mapMacroKeys = cellstr( miscKeys );
miscStructFieldsMap = containers.Map( mapMacroKeys, mapADStrcutFields );

misc_KVPairs = regexp( defineCode, [ '(?m)^\s*#define\s*?(?<key>\<(', char( join( miscKeys, '|' ) ), ')\>)\s*?(?<value>\<\S*\>)\s*?$' ], 'names' );

for i = 1:numel( misc_KVPairs )
outStrBuffer = outStrBuffer ...
 + "ad.SfunWizardData." ...
 + miscStructFieldsMap( misc_KVPairs( i ).key ) ...
 + " = '" + misc_KVPairs( i ).value + "';" + newline;
end 


if strcmp( sfbRevision, '1.0' )

inFieldKeys = { 'Name', 'Row', 'Col', 'DataType', 'Complexity', 'Frame',  ...
'Bus', 'Busname', 'Dims', 'IsSigned', 'WordLength', 'FractionLength',  ...
'FixPointScalingType', 'Slope', 'Bias' };
inFieldVals = { 'u', 'ad.SfunWizardData.InputPortWidth', '1', 'real_T', 'COMPLEX_NO', 'FRAME_NO',  ...
'off', '', '1-D', '', '', '',  ...
'', '', '' };
for i = 1:numel( inFieldKeys )
outStrBuffer = outStrBuffer ...
 + "ad.SfunWizardData.InputPorts." ...
 + inFieldKeys{ i } ...
 + " = {'" + inFieldVals{ i } + "'};" + newline;
end 

outFieldKeys = { 'Name', 'Row', 'Col', 'DataType', 'Complexity', 'Frame',  ...
'Bus', 'Busname', 'Dims', 'IsSigned', 'WordLength', 'FractionLength',  ...
'FixPointScalingType', 'Slope', 'Bias' };
outFieldVals = { 'y', 'ad.SfunWizardData.OutputPortWidth', '1', 'real_T', 'COMPLEX_NO', 'FRAME_NO',  ...
'off', '', '1-D', '', '', '',  ...
'', '', '' };
for i = 1:numel( outFieldKeys )
outStrBuffer = outStrBuffer ...
 + "ad.SfunWizardData.OutputPorts." ...
 + outFieldKeys{ i } ...
 + " = {'" + outFieldVals{ i } + "'};" + newline;
end 
else 
numIOParam_KVPairs = regexp( defineCode, '(?m)^\s*#define\s*?(?<key>\<(NUM_INPUTS|NUM_OUTPUTS|NPARAMS)\>)\s*?(?<value>\<\S*?\>)\s*?$', 'names' );

NumberOfInputPorts = 0;
NumberOfOutputPorts = 0;
NumParams = 0;
for KeyValPair = numIOParam_KVPairs
switch KeyValPair.key
case 'NUM_INPUTS'
NumberOfInputPorts = str2double( KeyValPair.value );
case 'NUM_OUTPUTS'
NumberOfOutputPorts = str2double( KeyValPair.value );
case 'NPARAMS'
NumParams = str2double( KeyValPair.value );
end 
end 

inputPort_KVPairs = regexp( defineCode, '(?m)^\s*#define\s*?\<(IN|IN_PORT|INPUT|INPUT_DIMS)_(?<index>\d*)_(?<key>\w*\>)\s*?(?<value>\S*\>)\s*?$', 'names' );
inputPort_KVPairs = sortByKeyIdxThenGroup( inputPort_KVPairs, NumberOfInputPorts );

outputPort_KVPairs = regexp( defineCode, '(?m)^\s*#define\s*?\<(OUT|OUT_PORT|OUTPUT|OUTPUT_DIMS)_(?<index>\d*)_(?<key>\w*\>)\s*?(?<value>\S*\>)\s*?$', 'names' );
outputPort_KVPairs = sortByKeyIdxThenGroup( outputPort_KVPairs, NumberOfOutputPorts );

param_KVPairs = regexp( defineCode, '(?m)^\s*#define\s*?\<PARAMETER_(?<index>\d*)_(?<key>\w*\>)\s*?(?<value>\<\S*\>)\s*?$', 'names' );
param_KVPairs = sortByKeyIdxThenGroup( param_KVPairs, NumParams );

mapMacroKeys = { 'NAME', 'WIDTH', 'COL', 'DTYPE', 'COMPLEX', 'FRAME_BASED',  ...
'BUS_BASED', 'BUS_NAME', 'DIMS', 'ISSIGNED', 'WORDLENGTH', 'FRACTIONLENGTH',  ...
'FIXPOINTSCALING', 'SLOPE', 'BIAS' };
mapADStrcutFields = { 'Name', 'Row', 'Col', 'DataType', 'Complexity', 'Frame',  ...
'Bus', 'Busname', 'Dims', 'IsSigned', 'WordLength', 'FractionLength',  ...
'FixPointScalingType', 'Slope', 'Bias' };

portStructFieldsMap = containers.Map( mapMacroKeys, mapADStrcutFields );

if ( NumberOfInputPorts > 0 )
for missingKeyCell = setdiff( mapMacroKeys, { inputPort_KVPairs.key } )
missingKey = missingKeyCell{ 1 };
if ( strcmp( missingKey, 'BUS_BASED' ) )
defaultVal = "'0'";
else 
defaultVal = "''";
end 
defaultVals = join( repmat( defaultVal, [ 1, NumberOfInputPorts ] ), ' ' );
inputPort_KVPairs( end  + 1 ).key = missingKey;%#ok
inputPort_KVPairs( end  ).value = defaultVals;
end 

mskBusKey = strcmp( { inputPort_KVPairs.key }, 'BUS_BASED' );
assert( numel( find( mskBusKey ) ) == 1, 'Each key should appear only once.' );
inputPort_KVPairs( mskBusKey ).value = regexprep( inputPort_KVPairs( mskBusKey ).value, [ "'0+'", "'1+'" ], [ "'off'", "'on'" ] );
end 

for i = 1:numel( inputPort_KVPairs )
if ( portStructFieldsMap.isKey( inputPort_KVPairs( i ).key ) )
outStrBuffer = outStrBuffer ...
 + "ad.SfunWizardData.InputPorts." ...
 + portStructFieldsMap( inputPort_KVPairs( i ).key ) ...
 + " = {" + inputPort_KVPairs( i ).value + "};" + newline;
end 
end 

if ( NumberOfOutputPorts > 0 )
for missingKeyCell = setdiff( mapMacroKeys, { outputPort_KVPairs.key } )
missingKey = missingKeyCell{ 1 };
if ( strcmp( missingKey, 'BUS_BASED' ) )
defaultVal = "'0'";
else 
defaultVal = "''";
end 
defaultVals = join( repmat( defaultVal, [ 1, NumberOfOutputPorts ] ), ' ' );
outputPort_KVPairs( end  + 1 ).key = missingKey;%#ok
outputPort_KVPairs( end  ).value = defaultVals;
end 


mskBusKey = strcmp( { outputPort_KVPairs.key }, 'BUS_BASED' );
assert( numel( find( mskBusKey ) ) == 1, 'Each key should appear only once.' );
outputPort_KVPairs( mskBusKey ).value = regexprep( outputPort_KVPairs( mskBusKey ).value, [ "'0+'", "'1+'" ], [ "'off'", "'on'" ] );
end 

for i = 1:numel( outputPort_KVPairs )
if ( portStructFieldsMap.isKey( outputPort_KVPairs( i ).key ) )
outStrBuffer = outStrBuffer ...
 + "ad.SfunWizardData.OutputPorts." ...
 + portStructFieldsMap( outputPort_KVPairs( i ).key ) ...
 + " = {" + outputPort_KVPairs( i ).value + "};" + newline;
end 
end 


mapMacroKeys = { 'NAME', 'DTYPE', 'COMPLEX' };
mapADStrcutFields = { 'Name', 'DataType', 'Complexity' };

paramStructFieldsMap = containers.Map( mapMacroKeys, mapADStrcutFields );

if ( NumParams == 0 )
param_KVPairs = struct( 'key', { 'NAME', 'DTYPE', 'COMPLEX' }, 'value', { '', '', '' } );
for missingKeyCell = setdiff( mapMacroKeys, { param_KVPairs.key } )
missingKey = missingKeyCell{ 1 };
defaultVal = "''";
defaultVals = join( repmat( defaultVal, [ 1, NumParams ] ), ' ' );
param_KVPairs( end  + 1 ).key = missingKey;%#ok
param_KVPairs( end  ).value = defaultVals;
end 
end 
if ( NumParams > 0 )
for missingKeyCell = setdiff( mapMacroKeys, { param_KVPairs.key } )
missingKey = missingKeyCell{ 1 };
defaultVal = "''";
defaultVals = join( repmat( defaultVal, [ 1, NumParams ] ), ' ' );
param_KVPairs( end  + 1 ).key = missingKey;%#ok
param_KVPairs( end  ).value = defaultVals;
end 
end 
for i = 1:numel( param_KVPairs )
if ( paramStructFieldsMap.isKey( param_KVPairs( i ).key ) )
outStrBuffer = outStrBuffer ...
 + "ad.SfunWizardData.Parameters." ...
 + paramStructFieldsMap( param_KVPairs( i ).key ) ...
 + " = {" + param_KVPairs( i ).value + "};" + newline;
end 
end 
end 

varargout{ 1 } = char( outStrBuffer );
if ( nargout > 1 )
varargout{ 2 } = [ 'ad.Version = ''', sfbRevision, ''';' ];
end 

end 

function KVPairs = sortByKeyIdxThenGroup( KVPairs, numPorts )
if ( isempty( KVPairs ) )
return ;
end 

KVPairs = convertIndexFieldToNumeric( KVPairs );

KVPairs = sortByKeyThenByIdx( KVPairs );

assert( mod( numel( KVPairs ), numPorts ) == 0 );

numFields = numel( KVPairs ) / numPorts;
groupedKeyCell = cell( 1, numFields );
groupedValueCell = cell( 1, numFields );
for i = 1:numFields
groupedKey = unique( { KVPairs( ( i - 1 ) * numPorts + ( 1:numPorts ) ).key } );
assert( numel( groupedKey ) == 1 );
groupedKeyCell( i ) = groupedKey;
singleQuotedValueStrs = cellfun( @( x )[ '''', x, '''' ], { KVPairs( ( i - 1 ) * numPorts + ( 1:numPorts ) ).value }, 'UniformOutput', false );
groupedValueCell( i ) = join( singleQuotedValueStrs, ' ' );
end 

KVPairs = struct( 'key', groupedKeyCell, 'value', groupedValueCell );

end 

function KVPairs = sortByKeyThenByIdx( KVPairs )
[ ~, idx ] = sortrows( [ { KVPairs.index }', { KVPairs.key }' ], [ 2, 1 ] );
KVPairs = KVPairs( idx );
end 

function KVPairs = convertIndexFieldToNumeric( KVPairs )
cellIndexField = { KVPairs( 1:end  ).index };
assert( iscell( cellIndexField ) );
idxNum = cellfun( @( x )str2double( x ), cellIndexField );

for i = 1:numel( idxNum )
KVPairs( i ).index = idxNum( i );
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmp6XE_yA.p.
% Please follow local copyright laws when handling this file.

