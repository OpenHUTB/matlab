function new_ss_hdl = ssGenSfunPost( rootSFunName, origBlk, struc_ports )





new_ss_hdl = [  ];

isGeneratingExportFunction = isfield( struc_ports, 'ExportFunctionCalls' ) && struc_ports.ExportFunctionCalls;


bds = find_system( 'type', 'block_diagram' );
bds = bds( find( strncmp( bds, 'untitled', length( 'untitled' ) ) ) );%#ok
if isempty( bds )
if slfeature( 'RightClickBuild' ) || isGeneratingExportFunction
bds = find_system( 'type', 'block_diagram' );
temporaryWrapperModel = Simulink.ModelReference.Conversion.ConversionData.ScratchModelName;
bds = bds( strncmp( bds, temporaryWrapperModel, length( temporaryWrapperModel ) ) );
if isempty( bds )
return ;
end 
else 
return ;
end 
end 

[ sfun, isCodeInfoBased ] = i_findXILSfunction( bds, rootSFunName );
if isempty( sfun )
if slfeature( 'RightClickBuild' ) || isGeneratingExportFunction
sfun = find_system( bds, 'SearchDepth', 1, 'BlockType', 'ModelReference' );
if isempty( sfun )
sfun = find_system( bds, 'SearchDepth', 1, 'BlockType', 'SubSystem' );
if isempty( sfun )
return ;
end 
end 
if iscell( sfun )
sfun = sfun{ : };
end 
else 
return ;
end 
end 

if isGeneratingExportFunction
new_ss_hdl = get_param( sfun, 'Handle' );
return ;
end 

if ~isfield( struc_ports, 'GenerateSFunction' )
struc_ports.GenerateSFunction = false;
end 

if slfeature( 'RightClickBuild' ) && slfeature( 'CodeInfoSILBlock' ) && ~struc_ports.GenerateSFunction && ~strcmp( get_param( bdroot( origBlk ), 'SystemTargetFile' ), 'rtwsfcn.tlc' )


sfunH = get_param( sfun, 'Handle' );
new_ss_hdl = sfunH;

scratchModelName = Simulink.ModelReference.Conversion.ConversionData.ScratchModelName;
mdlBlockInScratchModel = find_system( scratchModelName, 'SearchDepth', 1, 'BlockType', 'ModelReference' );
if numel( mdlBlockInScratchModel ) == 0
subSystemBlockInScratchModel = find_system( scratchModelName, 'SearchDepth', 1, 'BlockType', 'SubSystem' );
assert( numel( subSystemBlockInScratchModel ) == 1, 'Can find one and only one subsystem block' );
else 
assert( numel( mdlBlockInScratchModel ) == 1, 'Can find one and only one model block' );
end 

ginfo = Simulink.ModelReference.Conversion.CopyGraphicalInfo( origBlk );
ginfo.copy( new_ss_hdl );
compTimeIOAttribute = struc_ports.CompileTimeIOAttributes{ 1 };
compTimeIOAttribute.copy( new_ss_hdl );

else 
clear slBus;


origName = strrep( get_param( origBlk, 'Name' ), '/', '//' );
origBlkPath = sprintf( '%s/%s', get_param( origBlk, 'Parent' ), origName );
new_model = bdroot( sfun );
new_ss = [ new_model, '/', origName ];
new_ss_hdl = add_block( 'built-in/Subsystem', new_ss );
new_sfcn = [ new_ss, '/', origName, '_sfcn' ];
new_sfcn_hdl = add_block( sfun, new_sfcn );
input_ss = [ new_ss, '/__InputSSForSFun__' ];
output_ss = [ new_ss, '/', '__OutputSSForSFun__' ];
input_ss_hdl = add_block( 'built-in/Subsystem', input_ss );
output_ss_hdl = add_block( 'built-in/Subsystem', output_ss );

thisHdl.exportFcns = 0;
thisHdl.actualDataTypeOverride = get_param( origBlk, 'DataTypeOverride_Compiled' );

delete_block( sfun );

coder.internal.slBus( 'ResetNameStruct' );
clear busdemux;
outPortH = [  ];

origInportBlks = strrep( get_param( origBlk, 'Blocks' ), '/', '//' );
for i = 1:struc_ports.numOfInports
inportBlk = sprintf( '%s/%s', origBlkPath, origInportBlks{ i } );
tmpPrtH = busdemux( struc_ports.Inport{ i }, input_ss, inportBlk );
outPortH = [ outPortH( 1:end  ), tmpPrtH( 1:end  ) ];
end 

for i = 1:struc_ports.numOfEnablePorts
tmpPrtH = busdemux( struc_ports.Enable{ i }, input_ss );
outPortH = [ outPortH( 1:end  ), tmpPrtH( 1:end  ) ];
end 

for i = 1:struc_ports.numOfTriggerPorts
tmpPrtH = busdemux( struc_ports.Trigger{ i }, input_ss );
outPortH = [ outPortH( 1:end  ), tmpPrtH( 1:end  ) ];
end 

for i = 1:struc_ports.numOfResetPorts
tmpPrtH = busdemux( struc_ports.Reset{ i }, input_ss );
outPortH = [ outPortH( 1:end  ), tmpPrtH( 1:end  ) ];
end 

for i = 1:struc_ports.numOfFromBlks
tmpPrtH = busdemux( struc_ports.From{ i }, input_ss,  ...
struc_ports.fromBlks( i ) );
outPortH = [ outPortH( 1:end  ), tmpPrtH( 1:end  ) ];
end 

if isempty( outPortH )
srcPos = [ 95, 35 ];
else 
srcPos = get_param( outPortH, 'Position' );
end 

if ~iscell( srcPos )
tempVar = srcPos;clear srcPos;srcPos{ 1 } = tempVar;
end 

max_x = [ srcPos{ : } ];
max_x = max( max_x( 1:2:end  ) );

for i = 1:length( outPortH )
outPortBlkH =  ...
add_block( 'built-in/Outport',  ...
sprintf( '%s/__UniqueOutportName__%d__', input_ss, i ) );
pos = get_param( outPortH( i ), 'Position' );
set_param( outPortBlkH, 'Position',  ...
[ max_x + 300, pos( 2 ) - 10, max_x + 320, pos( 2 ) + 10 ] );
set_param( outPortBlkH, 'ShowName', 'off' );
portH = get_param( outPortBlkH, 'PortHandles' );
add_line( input_ss, outPortH( i ), portH.Inport );
end 

pos = get_param( new_sfcn_hdl, 'Position' );
new_sfcn_pos( 1 ) = 400;
new_sfcn_pos( 2 ) = srcPos{ 1 }( 2 );
new_sfcn_pos( 3 ) = 700;
new_sfcn_pos( 4 ) = srcPos{ 1 }( 2 ) + pos( 4 ) - pos( 2 );
set_param( new_sfcn_hdl, 'Position', new_sfcn_pos );

input_ss_pos( 1 ) = 200;
input_ss_pos( 2 ) = new_sfcn_pos( 2 );
input_ss_pos( 3 ) = 300;
input_ss_pos( 4 ) = new_sfcn_pos( 4 );
set_param( input_ss_hdl, 'Position', input_ss_pos );

output_ss_pos( 1 ) = 800;
output_ss_pos( 2 ) = new_sfcn_pos( 2 );
output_ss_pos( 3 ) = 900;
output_ss_pos( 4 ) = new_sfcn_pos( 4 );
set_param( output_ss_hdl, 'Position', output_ss_pos );

ssBlocks = strrep( get_param( input_ss_hdl, 'Blocks' ), '/', '//' );
ssPorts = get_param( input_ss_hdl, 'Ports' );
ssPortH = get_param( input_ss_hdl, 'PortHandles' );

posOffset = [  - 100,  - 10,  - 80, 10 ];
for i = 1:ssPorts( 1 )
srcBlk = [ input_ss, '/', ssBlocks{ i } ];
dstBlk = [ new_ss, '/', ssBlocks{ i } ];
inportBlkH = add_block( srcBlk, dstBlk );
pos = get_param( ssPortH.Inport( i ), 'Position' );
set_param( inportBlkH, 'Position', [ pos, pos ] + posOffset );
portH = get_param( inportBlkH, 'PortHandles' );
add_line( new_ss, portH.Outport, ssPortH.Inport( i ) );
end 

sfcPortH = get_param( new_sfcn_hdl, 'PortHandles' );
ssPortH = get_param( input_ss_hdl, 'PortHandles' );

if length( sfcPortH.Inport ) ~= length( ssPortH.Outport )
disp( 'sfunction inports don''t match' )
return ;
end 

for i = 1:length( ssPortH.Outport )
add_line( new_ss, ssPortH.Outport( i ), sfcPortH.Inport( i ) );
end 




outPortH = zeros( 1, length( sfcPortH.Outport ) );
for i = 1:length( sfcPortH.Outport )
inPortBlkH =  ...
add_block( 'built-in/Inport',  ...
sprintf( '%s/__UniqueInportName__%d__', output_ss, i ) );
pos = get_param( sfcPortH.Outport( i ), 'Position' );
set_param( inPortBlkH, 'Position', [ 100, pos( 2 ) - 10, 120, pos( 2 ) + 10 ] );
set_param( inPortBlkH, 'ShowName', 'off' );
portH = get_param( inPortBlkH, 'PortHandles' );
outPortH( i ) = portH.Outport;
end 

ssPortH = get_param( output_ss_hdl, 'PortHandles' );
for i = 1:length( sfcPortH.Outport )
add_line( new_ss, sfcPortH.Outport( i ), ssPortH.Inport( i ) );
end 




for i = 1:struc_ports.numOfOutports
portH = coder.internal.slBus( 'outPortH2bus', struc_ports.Outport{ i },  ...
output_ss, outPortH );
outportBlk = sprintf( '%s/%s', origBlkPath, origInportBlks{ i +  ...
length( origInportBlks ) - struc_ports.numOfOutports } );
coder.internal.slBus( 'LocalAddOutPortBlock', output_ss, portH, struc_ports.Outport{ i },  ...
thisHdl, outportBlk );
end 

for i = 1:struc_ports.numOfGotoBlks
portH = coder.internal.slBus( 'outPortH2bus', struc_ports.Goto{ i },  ...
output_ss, outPortH );
coder.internal.slBus( 'LocalAddOutPortBlock', output_ss, portH,  ...
struc_ports.Goto{ i }, thisHdl, struc_ports.gotoBlks( i ) );
end 





ssBlocks = get_param( output_ss_hdl, 'Blocks' );
ssPorts = get_param( output_ss_hdl, 'Ports' );
outPortBlks = strrep( ssBlocks( end  - ssPorts( 2 ) + 1:end  ), '/', '//' );
ssPortH = get_param( output_ss_hdl, 'PortHandles' );
posOffset = [ 100,  - 10, 120, 10 ];

for i = 1:length( outPortBlks )
srcBlk = [ output_ss, '/', outPortBlks{ i } ];
dstBlk = [ new_ss, '/', outPortBlks{ i } ];
outportBlkH = add_block( srcBlk, dstBlk );
pos = get_param( ssPortH.Outport( i ), 'Position' );
set_param( outportBlkH, 'Position', [ pos, pos ] + posOffset );
portH = get_param( outportBlkH, 'PortHandles' );
add_line( new_ss, ssPortH.Outport( i ), portH.Inport );
end 




hRootIO = find_system( new_ss_hdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FindAll', 'on', 'PortType', 'outport' );
for i = 1:length( hRootIO )
set_param( hRootIO( i ),  ...
'RTWStorageTypeQualifier', '',  ...
'RTWStorageClass', 'Auto',  ...
'MustResolveToSignalObject', 'off' );
end 


set_param( input_ss_hdl, 'PermitHierarchicalResolution', 'ExplicitOnly' );
set_param( output_ss_hdl, 'PermitHierarchicalResolution', 'ExplicitOnly' );

[ new_ss_hdl, new_sfcn_hdl ] = rtwprivate( 'slGetExpFcnWrapperSys', origBlk, new_ss_hdl, new_sfcn_hdl );


origPos = get_param( origBlk, 'Position' );
subsysPos = get_param( new_ss_hdl, 'Position' );

offset1 = origPos( 3 ) - origPos( 1 );
offset2 = origPos( 4 ) - origPos( 2 );

subsysPos( 3 ) = subsysPos( 1 ) + offset1;
subsysPos( 4 ) = subsysPos( 2 ) + offset2;


set_param( new_ss_hdl,  ...
'Position', subsysPos,  ...
'Orientation', get_param( origBlk, 'Orientation' ),  ...
'NamePlacement', get_param( origBlk, 'NamePlacement' ),  ...
'Foreground', get_param( origBlk, 'Foreground' ),  ...
'Background', get_param( origBlk, 'Background' ) );


set_param( new_ss_hdl,  ...
'MaskDescription', get_param( new_sfcn_hdl, 'MaskDescription' ),  ...
'MaskHelp', get_param( new_sfcn_hdl, 'MaskHelp' ) );

if isCodeInfoBased

set_param( new_ss_hdl, 'DialogController', 'pil_create_dialog' );
set_param( new_ss_hdl, 'DialogControllerArgs', { 'pildialog' } );




creationTimeVersion = rtw.pil.getPILVersion;
nl = sprintf( '\n' );


loadFcn = [ 'try', nl ...
, '   if ~strcmp(rtw.pil.getPILVersion, ''', creationTimeVersion, ''')', nl ...
, '      set_param(gcb, ''DialogController'', '''');', nl ...
, '      set_param(gcb, ''DialogControllerArgs'', '''');', nl ...
, '   end', nl ...
, 'catch e', nl ...
, '      set_param(gcb, ''DialogController'', '''');', nl ...
, '      set_param(gcb, ''DialogControllerArgs'', '''');', nl ...
, 'end', nl ];



set_param( new_ss_hdl, 'LoadFcn', loadFcn );

simMode = get_param( new_sfcn_hdl, 'SimulationMode' );
if strcmp( simMode, 'SIL' )
set_param( new_ss_hdl, 'MaskDisplay', 'disp(''SIL'');' );
else 
set_param( new_ss_hdl, 'MaskDisplay', 'disp(''PIL'');' );
end 


set_param( new_ss_hdl, 'MaskIconOpaque', 'off' );
else 
maskDisplayFcn = get_param( origBlk, 'MaskDisplay' );
if ~isempty( maskDisplayFcn )
h = figure( 'visible', 'off' );
try 
evalc( maskDisplayFcn );
set_param( new_ss_hdl, 'MaskDisplay', maskDisplayFcn );
catch exc %#ok<NASGU>
end 
delete( h );
end 

if struc_ports.numOfScopeBlks == 0


maskPrompts = get_param( new_sfcn_hdl, 'MaskPrompts' );
maskStyles = get_param( new_sfcn_hdl, 'MaskStyles' );
maskCallbacks = get_param( new_sfcn_hdl, 'MaskCallbacks' );
maskValues = get_param( new_sfcn_hdl, 'MaskValues' );
maskNames = get_param( new_sfcn_hdl, 'MaskNames' );


maskVariables = get_param( new_sfcn_hdl, 'MaskVariables' );
expectedVars = 'rtw_sf_name=&1;showVar=@2;';
if ~strncmp( maskVariables, expectedVars, length( expectedVars ) )
DAStudio.error( 'RTW:buildProcess:UnexpectedBlockMaskVariables',  ...
strcat( get_param( new_sfcn_hdl, 'Parent' ), '/',  ...
get_param( new_sfcn_hdl, 'Name' ) ) );
end 


sfcnMaskValues = [ maskValues( 1:2 );maskNames( 3:end  ) ];

nValues = length( maskValues );
if nValues > 2
if strcmp( maskNames{ 3 }, 'prm_to_disp' )
sfcnMaskValues{ 3 } = maskValues{ 3 };
end 


newMaskVariables = '';
for idx = 3:nValues
newMaskVariables = strcat( newMaskVariables, maskNames{ idx },  ...
'=@', num2str( idx - 2 ), ';' );
end 
set_param( new_ss_hdl, 'MaskPrompts', maskPrompts( 3:end  ),  ...
'MaskValues', maskValues( 3:end  ),  ...
'MaskCallbacks', maskCallbacks( 3:end  ),  ...
'MaskStyles', maskStyles( 3:end  ),  ...
'MaskVariables', newMaskVariables );
set_param( new_sfcn_hdl, 'MaskValues', sfcnMaskValues );
end 
end 
end 
end 




function port_label( a, b, c )%#ok
function dpoly( a, b, c )%#ok
function droots( a, b, c )%#ok



function [ sfun, isCodeInfoBased ] = i_findXILSfunction( model, name )
isCodeInfoBased = false;
sfunSuffix = '_sf';
sfun = i_findSfunction( model, name, sfunSuffix );

if isempty( sfun )
sfunSuffix = '_sbs';
sfun = i_findSfunction( model, name, sfunSuffix );
if ~isempty( sfun )
isCodeInfoBased = true;
end 
end 


if isempty( sfun ) && slfeature( 'CodeInfoSILBlock' )
sfunSuffix = '_pbs';
sfun = i_findSfunction( model, name, sfunSuffix );
if ~isempty( sfun )
isCodeInfoBased = true;
end 
end 


function sfun = i_findSfunction( model, name, suffix )
sfun = find_system( model, 'SearchDepth', 1,  ...
'FunctionName', [ name, suffix ],  ...
'BlockType', 'S-Function' );
if ~isempty( sfun )
sfun = sfun{ 1 };
end 


function outPortH = busdemux( strucBus, systemName, varargin )
persistent inportPos;
persistent portNumber;

if isempty( inportPos )
inportPos = [ 70, 30, 90, 40 ];
portNumber = 0;
else 
inportPos = inportPos + [ 0, 30, 0, 30 ];
portNumber = portNumber + 1;
end 

if nargin > 2 && ~Simulink.BlockDiagram.Internal.isCompositePortBlock( get_param( varargin{ 1 }, 'Handle' ) )
srcBlk = varargin{ 1 };
else 
srcBlk = 'built-in/Inport';
end 

if strucBus.type == 2 && strucBus.node.isVirtualBus

busCellArray = coder.internal.BusUtils.LocalBusStruct2CellArray( strucBus, 1 );

inputH = add_block( srcBlk,  ...
[ systemName, '/__UniqueNameforInportBlock__' ],  ...
'Position', rtwprivate( 'sanitizePosition', inportPos ) );

if isfield( strucBus, 'portName' )
coder.internal.slBus( 'LocalSetName', inputH, strucBus.portName, 'Inport' );
else 
coder.internal.slBus( 'LocalSetName', inputH, strucBus.name, 'Inport' );
end 

ph = get_param( inputH, 'PortHandles' );

outPortH = coder.internal.slBus( 'LocalAddBusSelectBlock', systemName, ph.Outport, busCellArray );

[ numberOfOutputs, ~ ] = coder.internal.BusUtils.LocalGetNumberOfSignals( strucBus );
if length( outPortH ) ~= numberOfOutputs
DAStudio.error( 'RTW:buildProcess:slbusDemuxError' );
end 

portH = get_param( get_param( outPortH( 1 ), 'Parent' ), 'PortHandles' );
portPos = get_param( portH.Inport, 'Position' );
set_param( inputH, 'Position', [ 70, portPos( 2 ) - 5, 90, portPos( 2 ) + 5 ] );

portPos = get_param( outPortH( end  ), 'Position' );
inportPos( 2 ) = portPos( 2 ) - 10;inportPos( 4 ) = portPos( 2 );
if strucBus.type == 2 && strucBus.node.hasBusObject
coder.internal.BusUtils.localSetBusObjectParams( inputH, strucBus.node.busObject );
end 

else 
inputH = add_block( srcBlk,  ...
[ systemName, '/__UniqueNameforInportBlock__' ],  ...
'Position', rtwprivate( 'sanitizePosition', inportPos ) );
if isfield( strucBus, 'portName' )
coder.internal.slBus( 'LocalSetName', inputH, strucBus.portName, 'Inport' );
else 
coder.internal.slBus( 'LocalSetName', inputH, strucBus.name, 'Inport' );
end 
ph = get_param( inputH, 'PortHandles' );
outPortH( 1 ) = ph.Outport;

outPortH( 1 ) = coder.internal.IOUtils.LocalSetInPortNonAutoSCOrUdi( systemName, outPortH( 1 ), strucBus, 1 );

if strucBus.type == 2 && strucBus.node.hasBusObject
coder.internal.BusUtils.localSetBusObjectParams( inputH, strucBus.node.busObject );
end 
end 

if ~strcmp( get_param( inputH, 'BlockType' ), 'Inport' )
return ;
end 

defaultValuePairs = { { 'SampleTime', '-1' }, { 'PortDimensions', '-1' } };

for i = 1:length( defaultValuePairs )
prmName = defaultValuePairs{ i }{ 1 };
defaultValue = defaultValuePairs{ i }{ 2 };
prmValue = get_param( inputH, prmName );
if ~strcmp( defaultValue, prmValue )
[ ~, itExists ] = slResolve( prmValue, inputH );
if ~itExists
set_param( inputH, prmName, defaultValue );
end 
end 
end 

defaultDTValue = 'Inherit: auto';
dtPrmName = 'OutDataTypeStr';
dtPrmValue = get_param( inputH, dtPrmName );
if ~coder.internal.DataType.l_dtPrmResolved( dtPrmValue, inputH )
set_param( inputH, dtPrmName, defaultDTValue );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpHW5835.p.
% Please follow local copyright laws when handling this file.

