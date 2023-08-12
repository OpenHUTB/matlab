function varargout = sfunbuilderports( varargin )




Action = varargin{ 1 };
blockHandle = varargin{ 2 };

switch ( Action )
case 'Create'



majority = varargin{ 3 };
iP = varargin{ 4 };
oP = varargin{ 5 };
param = varargin{ 6 };
AppData = varargin{ 7 };


varargout{ 1 } = AppData.SfunBuilderWidgets.fPortsConfigPanel;

varargout{ 2 } = AppData;
[ iP, oP, param ] = addBusPortInfo( iP, oP, param );
[ iP, oP, param ] = renamePortInfo( iP, oP, param );

switch majority
case 'Column'
majorityIdx = 0;
case 'Row'
majorityIdx = 1;
case 'Any'
majorityIdx = 2;
end 
AppData.SfunBuilderWidgets.setMajorityIndex( majorityIdx );

if ( ~isempty( iP.Name ) && ~strcmp( iP.Name{ 1 }, 'ALLOW_ZERO_PORTS' ) )
AppData.SfunBuilderWidgets.setInputPortsTableWithFixPt( iP.Name,  ...
iP.DataType,  ...
iP.Dims,  ...
iP.Row,  ...
iP.Col,  ...
iP.Complexity,  ...
iP.Frame,  ...
iP.Bus,  ...
iP.Busname,  ...
iP.FixPointScalingType,  ...
iP.WordLength,  ...
iP.IsSigned,  ...
iP.FractionLength,  ...
iP.Slope,  ...
iP.Bias );

AppData.SfunBuilderWidgets.setTreeView( iP.Name, 0 );
end 

if ( ~isempty( oP.Name ) && ~strcmp( oP.Name{ 1 }, 'ALLOW_ZERO_PORTS' ) )
AppData.SfunBuilderWidgets.setOutputPortsTableWithFixPt( oP.Name,  ...
oP.DataType,  ...
oP.Dims,  ...
oP.Row,  ...
oP.Col,  ...
oP.Complexity,  ...
oP.Frame,  ...
oP.Bus,  ...
oP.Busname,  ...
oP.FixPointScalingType,  ...
oP.WordLength,  ...
oP.IsSigned,  ...
oP.FractionLength,  ...
oP.Slope,  ...
oP.Bias );

AppData.SfunBuilderWidgets.setTreeView( oP.Name, 1 );
end 


try 
if ( ~isempty( param.Name ) && ~isempty( param.Name{ 1 } ) )
AppData.SfunBuilderWidgets.setParametersTable( param.Name, param.DataType, param.Complexity );
AppData.SfunBuilderWidgets.setTreeView( param.Name, 2 );
pD = setParamsValues( AppData, param );
AppData.SfunBuilderWidgets.setParametersDeploymentTable( pD.Name, pD.Value, pD.DataType );
end 
end 

case 'GetPortsInfo'



AppData = varargin{ 3 };
[ majority, inputPortsInfo, outputPortsInfo, parametersInfo, paramsValues ] = getPortsInfo( AppData );
varargout{ 1 } = majority;
varargout{ 2 } = inputPortsInfo;
varargout{ 3 } = outputPortsInfo;
varargout{ 4 } = parametersInfo;
varargout{ 5 } = paramsValues;

case 'UpdatePortsInfo'

majority = varargin{ 3 };
iP = varargin{ 4 };
oP = varargin{ 5 };
param = varargin{ 6 };
[ majority, iP, oP, param ] = updatePortsInfo( majority, iP, oP, param );
varargout = { majority, iP, oP, param };

otherwise 
DAStudio.error( 'Simulink:blocks:SFunctionBuilderInvalidInput' );
end 



function [ majority, inPortsInfo, outPortsInfo, paramInfo ] = updatePortsInfo( majr, ip, op, pp )

portsInfoFields = { 'Name', 'DataType', 'Dims', 'Row', 'Complexity', 'Frame',  ...
'Bus', 'Busname', 'Col', 'IsSigned', 'WordLength', 'FixPointScalingType',  ...
'FractionLength', 'Slope', 'Bias' };
portsInfoDefault = { 'ALLOW_ZERO_PORTS', '0', '0', '0', '0', '0', '0', '0',  ...
'0', '1', '8', '0', '3', '2^-3', '0' };

paramInfoFields = { 'Name', 'DataType', 'Complexity' };
paramInfoDefault = { '', '', '' };

majority = majr;
if isempty( majority ) || ~any( strcmp( majority, { 'Column', 'Row', 'Any' } ) )
majority = 'Column';
end 
inPortsInfo = ip;
for k = 1:length( ip.Name )
for j = 1:length( portsInfoFields )
if ~isfield( inPortsInfo, portsInfoFields{ j } ) || k > length( inPortsInfo.( portsInfoFields{ j } ) )
inPortsInfo.( portsInfoFields{ j } ){ k } = portsInfoDefault{ j };
end 
end 
end 

outPortsInfo = op;
for k = 1:length( op.Name )
for j = 1:length( portsInfoFields )
if ~isfield( outPortsInfo, portsInfoFields{ j } ) || k > length( outPortsInfo.( portsInfoFields{ j } ) )
outPortsInfo.( portsInfoFields{ j } ){ k } = portsInfoDefault{ j };
end 
end 
end 

paramInfo = pp;
for k = 1:length( pp.Name )
for j = 1:length( paramInfoFields )
if ~isfield( paramInfo, paramInfoFields{ j } ) || k > length( paramInfo.( paramInfoFields{ j } ) )
paramInfo.( paramInfoFields{ j } ){ k } = paramInfoDefault{ j };
end 
end 
end 


function [ majority, inPortsInfo, outPortsInfo, parametersInfo, paramsValues ] = getPortsInfo( appData )

switch appData.SfunBuilderWidgets.getMajorityIndex
case 0
majority = 'Column';
case 1
majority = 'Row';
case 2
majority = 'Any';
end 
inCellRows = appData.SfunBuilderWidgets.getNumberofInputs;
outCellRows = appData.SfunBuilderWidgets.getNumberofOutputs;
paramsCellRows = appData.SfunBuilderWidgets.getNumberofParams;
nParams = paramsCellRows;

outPortsInfo.Name{ 1 } = 'ALLOW_ZERO_PORTS';
outPortsInfo.DataType{ 1 } = '0';
outPortsInfo.Dims{ 1 } = '0';
outPortsInfo.Row{ 1 } = '0';
outPortsInfo.Complexity{ 1 } = '0';
outPortsInfo.Frame{ 1 } = '0';
outPortsInfo.Bus{ 1 } = '0';
outPortsInfo.Busname{ 1 } = '0';
outPortsInfo.Col{ 1 } = '0';
outPortsInfo.IsSigned{ 1 } = '1';
outPortsInfo.WordLength{ 1 } = '8';
outPortsInfo.FixPointScalingType{ 1 } = '0';
outPortsInfo.FractionLength{ 1 } = '3';
outPortsInfo.Slope{ 1 } = '2^-3';
outPortsInfo.Bias{ 1 } = '0';

for k = 1:outCellRows
outPortsInfo.Name{ k } = char( appData.SfunBuilderWidgets.getOutputPortName( k - 1 ) );
outPortsInfo.DataType{ k } = char( appData.SfunBuilderWidgets.getOutputPortDataType( k - 1 ) );
outPortsInfo.Dims{ k } = char( appData.SfunBuilderWidgets.getOutputPortDimsValue( k - 1 ) );
outPortsInfo.Row{ k } = char( appData.SfunBuilderWidgets.getOutputPortRowDimsValue( k - 1 ) );
outPortsInfo.Complexity{ k } = char( appData.SfunBuilderWidgets.getOutputPortComplexity( k - 1 ) );
outPortsInfo.Frame{ k } = char( appData.SfunBuilderWidgets.getOutputPortFrame( k - 1 ) );
outPortsInfo.Bus{ k } = char( appData.SfunBuilderWidgets.getOutputPortBus( k - 1 ) );

if strcmp( char( outPortsInfo.Dims{ k } ), '1-D' )
outPortsInfo.Col{ k } = '1';
else 
outPortsInfo.Col{ k } = char( appData.SfunBuilderWidgets.getOutputPortDimsColValue( k - 1 ) );
if isempty( outPortsInfo.Col{ k } )
outPortsInfo.Col{ k } = '1';
end 
end 

if strcmp( char( outPortsInfo.Bus{ k } ), 'off' )
outPortsInfo.Busname{ k } = '';
elseif ~slfeature( 'slBusArraySFBuilder' )
outPortsInfo.Row{ k } = '1';
outPortsInfo.Col{ k } = '1';
outPortsInfo.Busname{ k } = char( appData.SfunBuilderWidgets.getOutputPortBusName( k - 1 ) );
end 

outPortsInfo.Dims{ k } = char( outPortsInfo.Dims{ k } );
if ~ischar( outPortsInfo.Col{ k } )
outPortsInfo.Col{ k } = '';
end 

if strcmp( char( outPortsInfo.DataType{ k } ), 'fixpt' )
outPortsInfo = configueFixPtAttributes( appData, outPortsInfo, k, 1 );
else 
outPortsInfo.IsSigned{ k } = '1';
outPortsInfo.WordLength{ k } = '8';
outPortsInfo.FixPointScalingType{ k } = '1';
outPortsInfo.FractionLength{ k } = '3';
outPortsInfo.Slope{ k } = '0.125';
outPortsInfo.Bias{ k } = '0';
end 
end 

inPortsInfo.Name{ 1 } = 'ALLOW_ZERO_PORTS';
inPortsInfo.DataType{ 1 } = '0';
inPortsInfo.Dims{ 1 } = '0';
inPortsInfo.Row{ 1 } = '0';
inPortsInfo.Complexity{ 1 } = '0';
inPortsInfo.Frame{ 1 } = '0';
inPortsInfo.Bus{ 1 } = '0';
inPortsInfo.Busname{ 1 } = '0';
inPortsInfo.Col{ 1 } = '0';
inPortsInfo.IsSigned{ 1 } = '1';
inPortsInfo.WordLength{ 1 } = '8';
inPortsInfo.FixPointScalingType{ 1 } = '0';
inPortsInfo.FractionLength{ 1 } = '3';
inPortsInfo.Slope{ 1 } = '2^-3';
inPortsInfo.Bias{ 1 } = '0';

for k = 1:inCellRows
inPortsInfo.Name{ k } = char( appData.SfunBuilderWidgets.getInputPortName( k - 1 ) );
inPortsInfo.DataType{ k } = char( appData.SfunBuilderWidgets.getInputPortDataType( k - 1 ) );
inPortsInfo.Dims{ k } = char( appData.SfunBuilderWidgets.getInputPortDimsValue( k - 1 ) );
inPortsInfo.Row{ k } = char( appData.SfunBuilderWidgets.getInputPortDimsRowValue( k - 1 ) );
inPortsInfo.Complexity{ k } = char( appData.SfunBuilderWidgets.getInputPortComplexity( k - 1 ) );
inPortsInfo.Frame{ k } = char( appData.SfunBuilderWidgets.getInputPortFrame( k - 1 ) );
inPortsInfo.Bus{ k } = char( appData.SfunBuilderWidgets.getInputPortBus( k - 1 ) );
inPortsInfo.Busname{ k } = char( appData.SfunBuilderWidgets.getInputPortBusName( k - 1 ) );

if strcmp( char( inPortsInfo.Dims{ k } ), '1-D' )
inPortsInfo.Col{ k } = '1';
else 
inPortsInfo.Col{ k } = char( appData.SfunBuilderWidgets.getInputPortDimsColValue( k - 1 ) );
if isempty( inPortsInfo.Col{ k } )
inPortsInfo.Col{ k } = '';
end 
end 

if strcmp( char( inPortsInfo.Bus{ k } ), 'off' )
inPortsInfo.Busname{ k } = '';
elseif ~slfeature( 'slBusArraySFBuilder' )
inPortsInfo.Row{ k } = '1';
inPortsInfo.Col{ k } = '1';
inPortsInfo.Busname{ k } = char( appData.SfunBuilderWidgets.getInputPortBusName( k - 1 ) );
end 

if strcmp( char( inPortsInfo.DataType{ k } ), 'fixpt' )
inPortsInfo = configueFixPtAttributes( appData, inPortsInfo, k, 0 );
else 
inPortsInfo.IsSigned{ k } = '0';
inPortsInfo.WordLength{ k } = '8';
inPortsInfo.FixPointScalingType{ k } = '1';
inPortsInfo.FractionLength{ k } = '9';
inPortsInfo.Slope{ k } = '0.125';
inPortsInfo.Bias{ k } = '0';
end 
end 
parametersInfo.Name = { '' };
parametersInfo.DataType = { '' };
parametersInfo.Complexity = { '' };
for k = 1:paramsCellRows
parametersInfo.Name{ k } = appData.SfunBuilderWidgets.fJParametersList.getValueAt( k - 1, 0 );
parametersInfo.DataType{ k } = appData.SfunBuilderWidgets.fJParametersList.getValueAt( k - 1, 1 );
parametersInfo.Complexity{ k } = appData.SfunBuilderWidgets.fJParametersList.getValueAt( k - 1, 2 );
end 

paramsValues = '';
for k = 1:nParams
paramsValues = [ paramsValues, ',', appData.SfunBuilderWidgets.fJParametersDeploymentList.getValueAt( k - 1, 2 ) ];
end 
if ~isempty( paramsValues )
paramsValues( 1 ) = '';
end 

[ inPortsInfo, outPortsInfo, parametersInfo ] = sfcnbuilder.i_renamePortDataTypes( inPortsInfo, outPortsInfo, parametersInfo );

function param = setParamsValues( AppData, param )
useWizardDataParam = false;
if ~isempty( param.Name{ 1 } )
if ( isfield( AppData.SfunWizardData.Parameters, 'Value' ) && ~isempty( AppData.SfunWizardData.Parameters.Value{ 1 } ) )
param.Value = AppData.SfunWizardData.Parameters.Value;
useWizardDataParam = true;
else 
for k = 1:length( param.Name )
param.Value{ k } = '';
end 
end 
end 

blkParams = get_param( AppData.inputArgs, 'Parameters' );

pat = { '\[', '\]' };
loc = regexp( blkParams, pat );
if ( length( loc{ 1 } ) == length( loc{ 1 } ) )
for ( k = 1:length( loc{ 1 } ) )
startIdx = loc{ 1 }( k );
endIdx = loc{ 2 }( k );
noCommas = strrep( blkParams( startIdx:endIdx ), ',', '|' );
blkParams = strrep( blkParams, blkParams( startIdx:endIdx ), noCommas );
end 
end 
p = AppData.SfunWizardData.Parameters;
if ~isempty( param.Name{ 1 } )
if ~useWizardDataParam
param.Value = strread( blkParams, '%s', 'delimiter', ',' );
param.Value = strrep( param.Value, '|', ',' );
end 
for j = 1:length( param.Name )
if strcmp( param.Complexity{ j }, 'complex' )
param.DataType{ j } = [ param.DataType{ j }, '(complex)' ];
end 
end 
end 

function [ iP, oP, param ] = renamePortInfo( iP, oP, param )

for i = 1:length( iP.Name )
iP.Row{ i } = strrep( iP.Row{ i }, 'DYNAMICALLY_SIZED', '-1' );
if ( strcmp( iP.DataType{ i }, 'real32_T' ) |  ...
strcmp( iP.DataType{ i }, 'creal32_T' ) )
iP.DataType{ i } =  ...
strrep( iP.DataType{ i }, 'real32_T', 'single' );
iP.DataType{ i } = strrep( iP.DataType{ i }, 'c', '' );
else 
iP.DataType{ i } = strrep( iP.DataType{ i }, 'real_T', 'double' );
iP.DataType{ i } =  ...
strrep( iP.DataType{ i }, '_T', '' );
iP.DataType{ i } = strrep( iP.DataType{ i }, 'c', '' );
end 

if strcmp( iP.Dims{ i }, '1-D' )
iP.Col{ i } = '';
end 

if ( ~isfield( iP, 'IsSigned' ) || ( length( iP.IsSigned ) < length( iP.Name ) ) )
iP.IsSigned{ i } = '1';
iP.WordLength{ i } = '12';
iP.FixPointScalingType{ i } = '1';
iP.FractionLength{ i } = '3';
iP.Slope{ i } = '2^-3';
iP.Bias{ i } = '0';
end 
end 
for i = 1:length( oP.Name )
oP.Row{ i } = strrep( oP.Row{ i }, 'DYNAMICALLY_SIZED', '-1' );
if ( strcmp( oP.DataType{ i }, 'real32_T' ) |  ...
strcmp( oP.DataType{ i }, 'creal32_T' ) )
oP.DataType{ i } =  ...
strrep( oP.DataType{ i }, 'real32_T', 'single' );
oP.DataType{ i } =  ...
strrep( oP.DataType{ i }, 'c', '' );
else 
oP.DataType{ i } =  ...
strrep( oP.DataType{ i }, 'real_T', 'double' );
oP.DataType{ i } =  ...
strrep( oP.DataType{ i }, '_T', '' );
oP.DataType{ i } =  ...
strrep( oP.DataType{ i }, 'c', '' );
end 

if strcmp( oP.Dims{ i }, '1-D' )
oP.Col{ i } = '';
end 

if ( ~isfield( oP, 'IsSigned' ) || ( length( oP.IsSigned ) < length( oP.Name ) ) )
oP.IsSigned{ i } = '1';
oP.WordLength{ i } = '12';
oP.FixPointScalingType{ i } = '1';
oP.FractionLength{ i } = '3';
oP.Slope{ i } = '2^-3';
oP.Bias{ i } = '0';
end 
end 

for i = 1:length( param.Name )
if ( strcmp( param.DataType{ i }, 'real32_T' ) |  ...
strcmp( param.DataType{ i }, 'creal32_T' ) )
param.DataType{ i } =  ...
strrep( param.DataType{ i }, 'real32_T', 'single' );
param.DataType{ i } =  ...
strrep( param.DataType{ i }, 'c', '' );
else 
param.DataType{ i } =  ...
strrep( param.DataType{ i }, 'real_T', 'double' );
param.DataType{ i } =  ...
strrep( param.DataType{ i }, '_T', '' );
param.DataType{ i } =  ...
strrep( param.DataType{ i }, 'c', '' );
end 
end 

iP.Complexity = strrep( iP.Complexity, 'COMPLEX_YES', 'complex' );
iP.Complexity = strrep( iP.Complexity, 'COMPLEX_NO', 'real' );
oP.Complexity = strrep( oP.Complexity, 'COMPLEX_YES', 'complex' );
oP.Complexity = strrep( oP.Complexity, 'COMPLEX_NO', 'real' );
param.Complexity = strrep( param.Complexity, 'COMPLEX_YES', 'complex' );
param.Complexity = strrep( param.Complexity, 'COMPLEX_NO', 'real' );

iP.Frame =  ...
strrep( iP.Frame, 'FRAME_NO', 'off' );
iP.Frame =  ...
strrep( iP.Frame, 'FRAME_YES', 'on' );
iP.Frame =  ...
strrep( iP.Frame, 'FRAME_INHERITED', 'auto' );
oP.Frame =  ...
strrep( oP.Frame, 'FRAME_NO', 'off' );
oP.Frame =  ...
strrep( oP.Frame, 'FRAME_YES', 'on' );
oP.Frame =  ...
strrep( oP.Frame, 'FRAME_INHERITED', 'auto' );

function [ Slope ] = getSlope( Str, appData )
Slope = sprintf( '%0.19g', 2 ^  - 3 );

try 
Slope = eval( Str );
Slope = sprintf( '%0.19g', Slope( 1 ) );
catch 

appData.SfunBuilderPanel.fCompileStatsTextArea.setText( DAStudio.message( 'Simulink:blocks:SFunctionBuilderInvalidSlope' ) );

DAStudio.error( 'Simulink:blocks:SFunctionBuilderInvalidSlope' );
end 


function portsInfo = configueFixPtAttributes( appData, portsInfo, k, port_mode );








if ( port_mode == 0 )
FxPtAtt = appData.SfunBuilderWidgets.getInputPortFixedPointAttributes( k - 1 );
else 
FxPtAtt = appData.SfunBuilderWidgets.getOutputPortFixedPointAttributes( k - 1 );
end 

if ( strcmp( char( FxPtAtt( 3 ) ), 'true' ) )
portsInfo.IsSigned{ k } = '1';
else 
portsInfo.IsSigned{ k } = '0';
end 
portsInfo.WordLength{ k } = char( FxPtAtt( 2 ) );
portsInfo.FractionLength{ k } = char( FxPtAtt( 4 ) );
portsInfo.FixPointScalingType{ k } = char( FxPtAtt( 1 ) );
portsInfo.FractionLength{ k } = char( FxPtAtt( 4 ) );
portsInfo.Slope{ k } = getSlope( char( FxPtAtt( 5 ) ), appData );
portsInfo.Bias{ k } = char( FxPtAtt( 6 ) );

function [ iP, oP, param ] = addBusPortInfo( iP, oP, param )
if ~isfield( iP, 'Bus' )
iP.Bus = {  };
oP.Bus = {  };
iP.Busname = {  };
oP.Busname = {  };

for i = 1:length( iP.Name )
iP.Bus = [ iP.Bus, 'off' ];
iP.Busname = [ iP.Busname, { '' } ];
end 

for i = 1:length( oP.Name )
oP.Bus = [ oP.Bus, 'off' ];
oP.Busname = [ oP.Busname, { '' } ];
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpOHy1SH.p.
% Please follow local copyright laws when handling this file.

