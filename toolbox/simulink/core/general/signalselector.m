function varargout = signalselector( varargin )







persistent USERDATA;

try 





mlock




Action = varargin{ 1 };
args = varargin( 2:end  );




switch ( Action )




case 'Create'


FunctionHandle = args{ 1 };
BlockHandle = args{ 2 };
NumInputs = args{ 3 };
ShowInputNum = args{ 4 };
PortPrefix = args{ 5 };
MultipleSigs = args{ 6 };
DialogTitle = args{ 7 };
if length( args ) > 7
UpdateCallback = args{ 8 };
else 
UpdateCallback = [  ];
end 

case { 'Close', 'Delete' }
BlockHandle = args{ 1 };

idx = 1;
if isempty( USERDATA )
return ;
elseif isempty( BlockHandle )

BlockHandle = USERDATA( idx ).BlockHandle;
else 
idx = FindSignalSelector( USERDATA, BlockHandle );



if isempty( idx )
idx = 1;
BlockHandle = [  ];
end 
end 


PanelHandle = USERDATA( idx ).PanelHandle;
Function = USERDATA( idx ).FunctionHandle;
frame = PanelHandle.getParent;
awtinvoke( frame, 'dispose()' );
USERDATA( idx ) = [  ];


if strcmp( Action, 'Close' ) && ishandle( BlockHandle )
if strcmp( Function, 'sigandscopemgr' ) && i_IsUnifiedScope( BlockHandle )
Function = 'Simulink.scopes.source.SignalSelectorController.Util';
end 
try 
feval( Function, 'DialogClosing', BlockHandle );
catch ME
end 
end 


case 'UpdateInputNum'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
idx = FindSignalSelector( USERDATA, BlockHandle );

if ~isempty( idx )
PanelHandle = USERDATA( idx ).PanelHandle;
PanelHandle.selectInputNumber( InputNumber );
PanelHandle.populate;
end 




case 'Populate'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
idx = FindSignalSelector( USERDATA, BlockHandle );





isValidSelection = true;
try 
get_param( args{ 3 }, 'Object' );
catch 
isValidSelection = false;
end 

if ( isValidSelection && ~isempty( idx ) && ishandle( BlockHandle ) )
Function = USERDATA( idx ).FunctionHandle;
newNumPorts = sigandscopemgr( 'GetNumPorts', BlockHandle );

[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 },  ...
varargout{ 4 }, varargout{ 5 }, varargout{ 6 },  ...
varargout{ 7 }, varargout{ 8 }, varargout{ 9 },  ...
varargout{ 10 }, varargout{ 11 } ] = DeterminePopulationData(  ...
USERDATA( idx ), InputNumber, newNumPorts, args( 3:end  ) );







bType = lower( get_param( BlockHandle, 'BlockType' ) );
if strfind( bType, 'scope' )
if ~i_IsUnifiedScope( BlockHandle )
scopeFig = get_param( BlockHandle, 'Figure' );
if ishandle( scopeFig )
feval( Function, 'SetSelectedAxes', scopeFig, InputNumber );
end 
else 
Simulink.scopes.source.SignalSelectorController.selectDisplay( BlockHandle, InputNumber );
end 
end 
end 

case 'UpdateName'
BlockHandle = args{ 1 };
NewName = args{ 2 };
idx = FindSignalSelector( USERDATA, BlockHandle );
if ~isempty( idx )
PanelHandle = USERDATA( idx ).PanelHandle;
PanelHandle.updateTitleBar( NewName );
end 





case 'GetSelection'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
idx = FindSignalSelector( USERDATA, BlockHandle );
Function = USERDATA( idx ).FunctionHandle;
try 
varargout{ 1 } = feval( Function, 'GetSelection', BlockHandle, InputNumber );
catch 
varargout{ 1 } = [  ];
end 

case 'AddSelection'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
idx = FindSignalSelector( USERDATA, BlockHandle );
Function = USERDATA( idx ).FunctionHandle;
UpdateCallback = USERDATA( idx ).UpdateCallback;
slObjects = args{ 3 };
if iscell( slObjects )
slObjects = [ slObjects{ : } ]';
end 

if ( isempty( slObjects ) )
return 
end 

parentBlock = get_param( slObjects( 1 ), 'Parent' );
parentBlockIsInsideModelRef = i_IsObjectInsideModelRef( BlockHandle, parentBlock );

if ( parentBlockIsInsideModelRef )
blkHandleToBeAdded = args{ 5 };
else 
blkHandleToBeAdded = slObjects( 1 );
end 


if ( strcmp( get_param( slObjects( 1 ), 'Type' ), 'block' ) || parentBlockIsInsideModelRef )


relPath = args{ 4 };
sIOSigs = get_param( BlockHandle, 'IOSignals' );
ioSigs{ InputNumber }.Handle = blkHandleToBeAdded;
for k = 1:length( relPath )
ioSigs{ InputNumber }.RelativePath = relPath{ k };
if ( ~isempty( sIOSigs ) )

sIOSigs{ InputNumber }( [ sIOSigs{ InputNumber }.Handle ] ==  - 1 ) = [  ];
sIOSigs{ InputNumber }( end  + 1 ) = ioSigs{ InputNumber };
else 
DAStudio.error( 'Simulink:blocks:NoIOSignals' );
end 
end 
set_param( BlockHandle, 'IOSignals', sIOSigs )
else 

ports = slObjects;
try 
feval( Function, 'AddSelection', BlockHandle, InputNumber, ports );
catch ME
end 
if i_LinkedToSignalAndScopeMgr( BlockHandle )
sigandscopemgr( 'UpdateSelections', BlockHandle );
end 
end 


if ~isempty( UpdateCallback )
UpdateCallback(  );
end 

case 'RemoveSelection'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
idx = FindSignalSelector( USERDATA, BlockHandle );
Function = USERDATA( idx ).FunctionHandle;
UpdateCallback = USERDATA( idx ).UpdateCallback;
slObjects = args{ 3 };
if iscell( slObjects )
slObjects = [ slObjects{ : } ]';
end 

if ( isempty( slObjects ) )
return 
end 

parentBlock = get_param( slObjects( 1 ), 'Parent' );
parentBlockIsInsideModelRef = i_IsObjectInsideModelRef( BlockHandle, parentBlock );

if ( parentBlockIsInsideModelRef )
blkHandleToBeRemoved = args{ 5 };
else 
blkHandleToBeRemoved = slObjects( 1 );
end 

if ( strcmp( get_param( slObjects( 1 ), 'Type' ), 'block' ) || parentBlockIsInsideModelRef )


relPath = args{ 4 };
rC = [  ];
scopeIOSigs = get_param( BlockHandle, 'IOSignals' );
for k = 1:length( relPath )
for m = 1:length( scopeIOSigs{ InputNumber } )
if ( strcmp( relPath{ k }, scopeIOSigs{ InputNumber }( m ).RelativePath ) )
if ( blkHandleToBeRemoved == scopeIOSigs{ InputNumber }( m ).Handle )
rC = [ rC, m ];
end 
end 
end 
end 
scopeIOSigs{ InputNumber }( rC ) = [  ];
set_param( BlockHandle, 'IOSignals', scopeIOSigs )
else 

ports = slObjects;
try 
feval( Function, 'RemoveSelection', BlockHandle, InputNumber, ports );
catch ME
end 
if i_LinkedToSignalAndScopeMgr( BlockHandle )
sigandscopemgr( 'UpdateSelections', BlockHandle );
end 
end 


if ~isempty( UpdateCallback )
UpdateCallback(  );
end 

case 'SwitchSelection'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };

if ( strcmp( get_param( bdroot( BlockHandle ), 'SimulationStatus' ), 'running' ) )
MSLDiagnostic( 'Simulink:blocks:SigSelectionNADuringSim' ).reportAsWarning;
return 
end 

idx = FindSignalSelector( USERDATA, BlockHandle );
Function = USERDATA( idx ).FunctionHandle;
UpdateCallback = USERDATA( idx ).UpdateCallback;
oldPort = args{ 3 };
newPort = args{ 4 };
parentBlock = get_param( newPort, 'Parent' );
parentBlockIsInsideModelRef = i_IsObjectInsideModelRef( BlockHandle, parentBlock );

if ( parentBlockIsInsideModelRef )
blkHandleToBeAdded = args{ 6 };
else 
blkHandleToBeAdded = newPort;
end 

if ( strcmp( get_param( newPort, 'type' ), 'block' ) || parentBlockIsInsideModelRef )
sIOSigs = get_param( BlockHandle, 'IOSignals' );
relPath = args{ 5 };
if ( ~isempty( sIOSigs ) )
sIOSigs{ InputNumber } = struct( 'Handle', blkHandleToBeAdded, 'RelativePath', relPath );
set_param( BlockHandle, 'IOSignals', sIOSigs )
end 
else 
try 
feval( Function, 'SwitchSelection', BlockHandle, InputNumber, oldPort, newPort );
catch ME %#ok<*NASGU>
end 
end 
if i_LinkedToSignalAndScopeMgr( BlockHandle )
sigandscopemgr( 'UpdateSelections', BlockHandle );
end 

if ~isempty( UpdateCallback )
UpdateCallback(  );
end 
case 'RemoveSingleSelection'
BlockHandle = args{ 1 };
idx = FindSignalSelector( USERDATA, BlockHandle );
UpdateCallback = USERDATA( idx ).UpdateCallback;
InputNumber = args{ 2 };
sIOSigs = get_param( BlockHandle, 'IOSignals' );
sIOSigs{ InputNumber }.Handle =  - 1;
set_param( BlockHandle, 'IOSignals', sIOSigs )

if i_LinkedToSignalAndScopeMgr( BlockHandle )
sigandscopemgr( 'UpdateSelections', BlockHandle );
end 

if ~isempty( UpdateCallback )
UpdateCallback(  );
end 

case 'BlockStart'
BlockHandle = args{ 1 };
lockStatus = 1;
updateUILockStatus( BlockHandle, lockStatus, USERDATA )
case 'BlockTerminate'
BlockHandle = args{ 1 };
lockStatus = 0;
updateUILockStatus( BlockHandle, lockStatus, USERDATA )




case 'GetUserData'
varargout{ 1 } = USERDATA;

case 'GetBlockUserData'
BlockHandle = args{ 1 };
idx = FindSignalSelector( USERDATA, BlockHandle );
varargout{ 1 } = USERDATA( idx );

case 'FindSigSelector'
BlockHandle = args{ 1 };
varargout{ 1 } = FindSignalSelector( USERDATA, BlockHandle );
end 

catch e

errordlg( e.message );
end 


function idx = FindSignalSelector( UD, H )


idx = [  ];
if ~isempty( UD )
idx = find( [ UD.BlockHandle ] == H );
end 


function flags = UpdateSelectionData( block, inputNumber, ports )

flags = zeros( length( ports ), 1 );
blockPorts = signalselector( 'GetSelection', block, inputNumber );

for i = 1:length( flags )
flags( i ) = ~isempty( find( ports( i ) == blockPorts, 1 ) );
end 


function flags = UpdateModelReferenceSelectionData( block, mdlrefblock, inputNumber, portParent, checkfullPathName )

if ( nargin == 4 )
checkfullPathName = false;
end 
flags = 0;

vs = get_param( block, 'IOSignals' );
vsAxes = vs{ inputNumber };
for i = 1:length( vsAxes )
sig = vsAxes( i );
bH = sig.Handle;
if ( checkfullPathName )
blkRelPath = sig.RelativePath;
else 
blkRelPath = strtok( sig.RelativePath, ':' );
end 
if ( mdlrefblock == bH )
if ( strcmp( blkRelPath, portParent ) )
flags = 1;
return ;
end 
end 
end 


function updateUILockStatus( BlockHandle, lockStatus, USERDATA )

idx = FindSignalSelector( USERDATA, BlockHandle );
if ~isempty( idx )
PanelHandle = USERDATA( idx ).PanelHandle;
PanelHandle.updateUILockStatus( lockStatus );
end 


function [ ports, names, flags, genStrs, parents, tps, types, relPaths ] =  ...
CollectStateflowTestPointData( UD, fSigBlk, sfBlk, inputNumber, isInsideOfModelRefBlock )

sfChart = sf( 'Private', 'block2chart', sfBlk );
sfTps = sf( 'Private', 'test_points_in', sfChart, 0, sfBlk );
[ sigHandle, sigRelPathStem, chartPath ] = getSFSignalRelativePath( UD, sfBlk, isInsideOfModelRefBlock );

numTps = length( sfTps );
ports = zeros( numTps, 1 );
names = cell( numTps, 1 );
flags = zeros( numTps, 1 );
genStrs = cell( numTps, 1 );
parents = cell( numTps, 1 );
tps = cell( numTps, 1 );
types = cell( numTps, 1 );
relPaths = cell( numTps, 1 );

for i = 1:length( sfTps )
objId = sfTps( i );

names{ i } = sf( 'FullNameOf', objId, sfChart, '.' );
relPaths{ i } = sprintf( '%s/%s:o1', sigRelPathStem, names{ i } );
parents{ i } = chartPath;
ports( i ) = sfBlk;
flags( i ) = UpdateModelReferenceSelectionData( fSigBlk, sigHandle, inputNumber, relPaths{ i }, true );
genStrs{ i } = '';
tps{ i } = '';
types{ i } = '';
end 

return ;


function [ ports, names, flags, genStrs, parents, tps, types, newNumPorts, relPaths, cascadeModelRef, lockUI ] =  ...
DeterminePopulationData( UD, inputNumber, newNumPorts, args )

ports = [  ];
names = { '' };
flags = [  ];
genStrs = { '' };
parents = { '' };
tps = { '' };
types = { '' };
relPaths = { '' };
cascadeModelRef = 0;
lockUI = 0;

if ( inputNumber > newNumPorts )
inputNumber = newNumPorts;
end 

BlockHandle = UD.BlockHandle;
BlockDiagram = bdroot( BlockHandle );
if ~( strcmp( get_param( BlockDiagram, 'SimulationStatus' ), 'stopped' ) )
lockUI = 1;
end 

blkIsInsideOfModelRefBlock = i_IsObjectInsideModelRef( BlockHandle, args{ 1 } );

if ( strcmp( get_param( args{ 1 }, 'Type' ), 'block' ) && strcmp( determineBlockType( args{ 1 } ), 'Stateflow' ) )
[ ports, names, flags, genStrs, parents, tps, types, relPaths ] =  ...
CollectStateflowTestPointData( UD, BlockHandle, args{ 1 }, inputNumber, blkIsInsideOfModelRefBlock );
return ;
end 

parentModelRefHandle =  - 1;
originalSigType = args{ 9 };

if ( blkIsInsideOfModelRefBlock )


args{ 9 } = 'TestPointed';
parentModelRefHandle = UD.PanelHandle.getParentMRBlockHandleFromSelectedSubsystem;
end 

if ( strcmp( get_param( args{ 1 }, 'Type' ), 'block' ) )
if ( strcmp( determineBlockType( args{ 1 } ), 'ModelReference' ) )
args{ 9 } = 'TestPointed';
end 
end 

PORTTYPE = 'OUTPORT';
if strcmp( get_param( BlockHandle, 'IOType' ), 'siggen' )
PORTTYPE = 'INPORT';
end 


sigType = args{ find( strcmpi( args, 'SignalType' ) ) + 1 };


depthIdx = find( strcmpi( args, 'SearchDepth' ) ) + 1;
args{ depthIdx } = str2num( args{ depthIdx } );%#ok<ST2NM>


if strcmp( PORTTYPE, 'OUTPORT' )
if ~i_IsConfigurableSystem( args{ 1 } ) && ~i_IsForEachSubsystemOrInside( args{ 1 } )
if ( strncmpi( sigType, 'testpoint', 9 ) )


portsTestPointed1 = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'AllBlocks', 'on',  ...
'PortType', 'outport',  ...
'Testpoint', 'on' );
portsTestPointed2 = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'AllBlocks', 'on',  ...
'PortType', 'state',  ...
'Testpoint', 'on' );

portsDataLogged1 = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'AllBlocks', 'on',  ...
'PortType', 'outport',  ...
'DataLogging', 'on' );
portsDataLogged2 = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'AllBlocks', 'on',  ...
'PortType', 'state',  ...
'DataLogging', 'on' );

ports1NonUnique = [ portsTestPointed1;portsDataLogged1 ];
ports2NonUnique = [ portsTestPointed2;portsDataLogged2 ];



ports1 = unique( ports1NonUnique );
ports2 = unique( ports2NonUnique );

else 


ports1 = find_system( args{ 1:7 }, 'FindAll', 'on', 'AllBlocks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'PortType', 'outport' );
ports2 = find_system( args{ 1:7 }, 'FindAll', 'on', 'AllBlocks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'PortType', 'state' );


if strcmpi( get_param( BlockDiagram, 'BlockDiagramType' ), 'DeploymentDiagram' )
port1OwnerBlockTypes = get_param( ports1, 'Parent' );
port1OwnerBlockTypes = get_param( port1OwnerBlockTypes, 'BlockType' );
ports1 = ports1( ~strcmp( port1OwnerBlockTypes, 'ModelReference' ) );
end 
end 


if ( ~isempty( ports1 ) && strcmp( get_param( args{ 1 }, 'Type' ), 'block' ) )
if ( strcmp( determineBlockType( args{ 1 } ), 'SubSystem' ) || strcmp( determineBlockType( args{ 1 } ), 'ModelReference' ) )
P1 = get_param( get_param( ports1, 'Parent' ), 'Handle' );
if ( iscell( P1 ) )
P1 = cell2mat( P1 );
end 
repeatedIndex = ( P1( : ) == args{ 1 } );
ports1( repeatedIndex ) = [  ];
end 
end 

ports = [ ports1( : );ports2( : ) ];
end 
else 



ports1 = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'PortType', 'inport',  ...
'Line',  - 1 );

ports2 = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'PortType', 'enable',  ...
'Line',  - 1 );

ports3 = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'PortType', 'trigger',  ...
'Line',  - 1 );

unconn = find_system( args{ 1:7 }, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'Type', 'line',  ...
'SegmentType', 'trunk',  ...
'SrcBlockHandle',  - 1 );
ports4 = get_param( unconn, 'DstPortHandle' );
if ~iscell( ports4 )
ports4 = { ports4 };
end 

if iscell( ports4 )
ports4 = cell2mat( ports4 );
end 
ports4 = ports4( ports4 > 0 );

ports = [ ports1( : );ports2( : );ports3( : );ports4( : ) ];
end 


ports = unique( ports );
PortsAndBlocks = [  ];

ports = removeStateFlowPorts( ports );

if strcmp( PORTTYPE, 'INPORT' )
ports = removeVariantInputPorts( ports );
end 

[ ports, PortsAndBlocks, cascadeModelRef ] = getPortsAndBlocksForCurrentSystem( args, ports,  ...
PortsAndBlocks, BlockHandle, cascadeModelRef, depthIdx );

if ( cascadeModelRef )
cascadeModelRef = 0;
end 

if isempty( ports ), return , end 


sigNames = get_param( ports, 'Name' );
if ~iscell( sigNames )
sigNames = { sigNames };
end 
emptyIdx = find( strcmp( sigNames, '' ) );

if ( strncmpi( sigType, 'named', 5 ) )
ports( emptyIdx ) = [  ];
sigNames( emptyIdx ) = [  ];

if ( ~isempty( PortsAndBlocks ) )
PortsAndBlocks( emptyIdx ) = [  ];
end 
else 
blkHs = get_param( ports, 'Parent' );
if ~iscell( blkHs )
blkHs = { blkHs };
end 
blks = get_param( blkHs, 'Name' );
if ~iscell( blks )
blks = { blks };
end 
port_num = get_param( ports, 'PortNumber' );
if ~iscell( port_num )
port_num = { port_num };
end 
port_type = get_param( ports, 'PortType' );
if ~iscell( port_type )
port_type = { port_type };
end 



if strcmp( PORTTYPE, 'OUTPORT' )
IDX_CHECK = 2;
else 
IDX_CHECK = 1;
end 
for i = 1:length( blkHs )
p = get_param( blkHs{ i }, 'Ports' );
if strcmpi( port_type{ i }, 'inport' ) || strcmp( port_type{ i }, 'outport' )
if ( p( IDX_CHECK ) == 1 )
defNames{ i } = blks{ i };%#ok<*AGROW>
else 
defNames{ i } = [ blks{ i }, ' : ', num2str( port_num{ i } ) ];
end 
else 
defNames{ i } = [ blks{ i }, ' : (', port_type{ i }, ')' ];
end 
end 

sigNames( emptyIdx ) = defNames( emptyIdx );
end 


[ sigNames, idx ] = sort( sigNames );
ports = ports( idx );
if ( ~isempty( PortsAndBlocks ) )
PortsAndBlocks = PortsAndBlocks( idx );
end 


if ( blkIsInsideOfModelRefBlock )
for i = 1:length( ports )
portParent = get_param( ports( i ), 'Parent' );
sigFlags( i ) = UpdateModelReferenceSelectionData( BlockHandle, parentModelRefHandle, inputNumber, portParent );
end 
else 
sigFlags = UpdateSelectionData( BlockHandle, inputNumber, ports );
end 


names = strrep( sigNames, sprintf( '\n' ), ' ' );
flags = sigFlags;
parents = strrep( get_param( ports, 'Parent' ), sprintf( '\n' ), ' ' );
if ~iscell( parents )
parents = { parents };
end 


try 
genStrs = strrep( get_param( ports, 'SigGenPortName' ), sprintf( '\n' ), ' ' );
if ~iscell( genStrs )
genStrs = { genStrs };
end 
catch e
genStrs = cell( length( ports ) );
[ genStrs{ : } ] = deal( '' );
end 

tps = get_param( ports, 'Testpoint' );
if ~iscell( tps )
tps = { tps };
end 

types = get_param( ports, 'CompiledPortDataType' );
if ~iscell( types )
types = { types };
end 
for i = 1:length( types )
relPaths{ i } = '?';
if isempty( types{ i } )
types{ i } = '???';
end 
end 




if ( blkIsInsideOfModelRefBlock )
sys = args{ 1 };
portParent = get_param( sys, 'Name' );
for i = 1:length( relPaths )
relPaths{ i } = get_param( ports( i ), 'Parent' );
end 
for i = 1:length( parents )
parents{ i } = [ getfullname( parentModelRefHandle ), '|', getfullname( parents{ i } ) ];
end 
end 

mdlRefFlag = false;
if ( strcmp( get_param( args{ 1 }, 'type' ), 'block' ) )
if ( strcmp( determineBlockType( args{ 1 } ), 'ModelReference' ) )
mdlRefFlag = true;
end 
end 


if ( mdlRefFlag || blkIsInsideOfModelRefBlock )
[ relPaths, parents, ports, flags ] = getRelativePath( UD, relPaths, ports,  ...
PortsAndBlocks,  ...
flags,  ...
BlockHandle,  ...
inputNumber );
end 


if ( strncmpi( originalSigType, 'selected', 8 ) )
selected_ports = signalselector( 'GetSelection', BlockHandle, inputNumber );
ports = ports( flags == 1 );
names = names( flags == 1 );
genStrs = genStrs( flags == 1 );
parents = parents( flags == 1 );
tps = tps( flags == 1 );
types = types( flags == 1 );
relPaths = relPaths( flags == 1 );
flags = flags( flags == 1 );



if ( args{ depthIdx } == 1 )
sys = args{ 1 };
if iscell( selected_ports )
selected_ports = [ selected_ports{ : } ];
end 
port = intersect( ports, selected_ports );
else 

end 
end 




function [ relPaths, parents, ports, flags ] = getRelativePath( UD, relPaths, ports,  ...
PortsAndBlocks,  ...
flags,  ...
BlockHandle,  ...
inputNumber )



parents = relPaths;

encPath = char( UD.PanelHandle.getEncodedPathFromSelectedNode );

if ( ~isempty( PortsAndBlocks ) )
portParent = get_param( ports( 1 ), 'Parent' );



IDX = strfind( encPath, [ '|', bdroot( portParent ) ] );
if ~isempty( IDX )
encPath = encPath( 1:IDX( end  ) );
end 

for i = 1:length( relPaths )
portParent = get_param( ports( i ), 'Parent' );
encPortParent = slprivate( 'encpath', portParent, '', '', 'none' );
pn = get_param( ports( i ), 'PortNumber' );
relPaths{ i } = [ encPath, encPortParent ];




[ pathParentMdlBlk, ~, relPaths{ i } ] = slprivate( 'decpath', relPaths{ i }, true );
if ( ~isempty( relPaths{ i } ) )
relPaths{ i } = [ relPaths{ i }, ':o', num2str( pn ) ];
try 
ParentMdlBlkHandle = get_param( pathParentMdlBlk, 'Handle' );
catch ME
ParentMdlBlkHandle = PortsAndBlocks;
end 
flags( i ) = UpdateModelReferenceSelectionData( BlockHandle, ParentMdlBlkHandle, inputNumber, relPaths{ i }, true );
end 
end 
ports = PortsAndBlocks;
end 


function [ sigHandle, sigRelPathStem, chartPath ] = getSFSignalRelativePath( UD, sfBlk, isInsideOfModelRefBlock )

chartPath = getfullname( sfBlk );

if ~isInsideOfModelRefBlock
sigHandle = sfBlk;
sigRelPathStem = 'StateflowChart';
else 
encPath = char( UD.PanelHandle.getEncodedPathFromSelectedNode );



IDX = strfind( encPath, [ '|', bdroot( chartPath ) ] );
if ~isempty( IDX )
encPath = encPath( 1:IDX( end  ) );
end 
encChartPath = slprivate( 'encpath', chartPath, '', '', 'none' );

sigRelPathStem = [ encPath, encChartPath ];




[ topMFBlk, ~, sigRelPathStem ] = slprivate( 'decpath', sigRelPathStem, true );
chartPath = sigRelPathStem;

sigHandle = get_param( topMFBlk, 'Handle' );
end 

return ;


function [ ports ] = removeStateFlowPorts( ports )

blocks = get_param( ports, 'Parent' );
parents = get_param( blocks, 'Parent' );
if ~iscell( parents )
parents = { parents };
end 

sfBlks = [  ];
for i = 1:length( parents )
if ( strcmp( get_param( parents{ i }, 'type' ), 'block' ) )
if ( strcmp( determineBlockType( parents{ i } ), 'Stateflow' ) )
sfBlks = [ sfBlks, i ];
end 
end 
end 
if ( ~isempty( sfBlks ) )
ports( sfBlks ) = [  ];
end 


function [ ports ] = removeVariantInputPorts( ports )

blocks = get_param( ports, 'Parent' );
parents = get_param( blocks, 'Parent' );
if ~iscell( parents )
parents = { parents };
end 



blks = [  ];
for i = 1:length( parents )
if ~isempty( parents{ i } ) &&  ...
strcmp( get_param( parents{ i }, 'Type' ), 'block' ) &&  ...
strcmp( get_param( parents{ i }, 'BlockType' ), 'SubSystem' ) &&  ...
strcmp( get_param( parents{ i }, 'Variant' ), 'on' )
blks = [ blks, i ];
end 
end 
if ( ~isempty( blks ) )
ports( blks ) = [  ];
end 



function [ ports, PortsAndBlocks, cascadeModelRef ] = getPortsAndBlocksForCurrentSystem( args, ports,  ...
PortsAndBlocks, BlockHandle, cascadeModelRef, depthIdx )









if ( strcmp( get_param( args{ 1 }, 'Type' ), 'block' ) )
blkType = determineBlockType( args{ 1 } );
switch blkType
case 'ModelReference'
[ ports, PortsAndBlocks ] = AppendPortsForModelRefBlock( args, ports,  ...
PortsAndBlocks, BlockHandle );
if ( i_IsObjectInsideModelRef( BlockHandle, args{ 1 } ) )

cascadeModelRef = 1;
end 
end 
end 

if ( isempty( PortsAndBlocks ) )
PortsAndBlocks = ports;
end 

if ( args{ depthIdx } == 1 )

return 
end 

portParents = strrep( get_param( ports, 'Parent' ), sprintf( '\n' ), ' ' );
modelRefBlkHandles = [  ];
mdlRefBlockPorts = [  ];
if ( ~isempty( portParents ) )
if ~iscell( portParents )
portParents = { portParents };
end 
end 
for i = 1:length( portParents )
blkType = determineBlockType( portParents{ i } );
switch blkType
case 'ModelReference'
modelRefBlkHandles = get_param( portParents{ i }, 'Handle' );
modelRefName = get_param( portParents{ i }, 'ModelName' );
try 
load_system( modelRefName );
catch 
DAStudio.error( 'Simulink:blocks:ModelNotFound', modelRefName );
end 
modelRefHandle = get_param( modelRefName, 'Handle' );


mdlRefBlockPortsTmp = find_system( modelRefName, 'FindAll', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'SearchDepth', args{ depthIdx },  ...
'Testpoint', 'on' );
if iscell( mdlRefBlockPorts )
mdlRefBlockPorts = [ mdlRefBlockPorts{ : } ]';
end 
mdlRefBlockPorts = [ mdlRefBlockPorts;mdlRefBlockPortsTmp ];
mdlRefBlockPorts = unique( mdlRefBlockPorts );
if ( ~isempty( ports ) && ~any( ismember( ports, mdlRefBlockPorts ) ) )
PortsAndBlocks( end :end  + length( mdlRefBlockPorts ) ) = modelRefBlkHandles;
ports = [ ports;mdlRefBlockPorts ];
end 
end 
end 


function [ ports, PortsAndBlocks ] = AppendPortsForModelRefBlock( args, ports, PortsAndBlocks, BlockHandle )


modelRefName = get_param( args{ 1 }, 'ModelName' );
mrefPorts = [  ];
try 
modelRefHandle = get_param( modelRefName, 'Handle' );
catch 
DAStudio.error( 'Simulink:blocks:ModelNotFound', modelRefName );
end 


mrefPortsTestpointed = find_system( modelRefName, 'FindAll', 'on', 'SearchDepth', 1,  ...
'Testpoint', 'on' );


mrefPortsDataLogged = find_system( modelRefName, 'FindAll', 'on', 'SearchDepth', 1,  ...
'DataLogging', 'on' );



mrefPortsNonUnique = [ mrefPortsTestpointed( : );mrefPortsDataLogged( : ) ];



mrefPorts = unique( mrefPortsNonUnique );



args{ 9 } = 'TestPointed';
if ( ~isempty( mrefPorts ) )
for i = 1:length( mrefPorts )
m_refHandles( i ) = args{ 1 };
end 
end 

if ( i_IsObjectInsideModelRef( BlockHandle, args{ 1 } ) )

cascadeModelRef = 1;
end 

if ( ~isempty( mrefPorts ) )
PortsAndBlocks = [ ports;m_refHandles' ];
ports = [ ports;mrefPorts ];
end 



function out = i_LinkedToSignalAndScopeMgr( block )
out = ~strcmp( get_param( block, 'IOType' ), 'none' );

function out = i_IsObjectInsideModelRef( ScopeBlock, SubSystemBlock )

scopeRootName = get_param( bdroot( ScopeBlock ), 'Name' );
subsysRootName = get_param( bdroot( SubSystemBlock ), 'Name' );

out = ~strcmp( scopeRootName, subsysRootName );

function blkType = determineBlockType( blkHandle )

blkType = get_param( blkHandle, 'BlockType' );

if slprivate( 'is_stateflow_based_block', blkHandle )
blkType = 'Stateflow';
end 



function isConfigSys = i_IsConfigurableSystem( h )

isConfigSys = false;

if ( strcmp( get_param( h, 'Type' ), 'block' ) &&  ...
strcmp( determineBlockType( h ), 'SubSystem' ) &&  ...
~isempty( get_param( h, 'BlockChoice' ) ) )

isConfigSys = true;
end 


function isForEachSysOrInside = i_IsForEachSubsystemOrInside( h )

isForEachSysOrInside = false;

if ( strcmp( get_param( h, 'Type' ), 'block' ) &&  ...
strcmp( determineBlockType( h ), 'SubSystem' ) &&  ...
isequal( get_param( h, 'IsForEachSSOrInside' ), 'on' ) )

isForEachSysOrInside = true;
end 



function b = i_IsUnifiedScope( BlockHandle )

b = strcmp( get_param( BlockHandle, 'BlockType' ), 'Scope' );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpV5eCSI.p.
% Please follow local copyright laws when handling this file.

