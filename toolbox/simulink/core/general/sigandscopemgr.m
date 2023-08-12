function varargout = sigandscopemgr( varargin )






persistent DIALOG_USERDATA

persistent HILITE_DATA


mlock









narginchk( 1, Inf );


Action = varargin{ 1 };
args = varargin( 2:end  );

switch ( Action )
case 'Create'
ModelHandle = get_param( args{ 1 }, 'Handle' );

case { 'AddObject' }
ModelHandle = args{ 1 };
ioType = args{ 2 };


try 
fullpath = char( ioType.getFullpath );


current_sys = get_param( 0, 'CurrentSystem' );
load_system( strtok( fullpath, '/' ) );
set_param( 0, 'CurrentSystem', current_sys );
mdlName = get_param( ModelHandle, 'Name' );

if strcmp( get_param( ModelHandle, 'type' ), 'block' )
mdlName = getfullname( ModelHandle );
end 
ioTypeName = get_param( fullpath, 'Name' );
object = add_block( fullpath, [ mdlName, '/', ioTypeName ], 'MakeNameUnique', 'on', 'SSMgrBlock', 'on' );

if strcmp( ioTypeName, 'MPlay' )

MPlayIO.mplayinst( object );
end 
numPorts = i_GetNumPorts( object );
varargout{ 1 } = Simulink.iomanager.IOObject( ioType,  ...
get_param( object, 'Name' ),  ...
get_param( object, 'Handle' ), numPorts,  ...
i_GetNumPortsChangeable( object ), ioType.isGenerator );
catch e
errordlg( e.message, 'Error', 'modal' );
end 

case 'DeleteObject'
BlockHandle = args{ 1 };
signalselector( 'Delete', BlockHandle );
isMPlay = ~isempty( strfind( get_param( BlockHandle, 'name' ), 'MPlay' ) );
if isMPlay
i_CloseMPlay( BlockHandle );
end 
delete_block( BlockHandle );

case 'SelectObject'
BlockHandle = get_param( args{ 1 }, 'Handle' );
ModelHandle = get_param( bdroot( BlockHandle ), 'Handle' );

case { 'Delete', 'Cancel', 'Close' }
ModelHandle = args{ 1 };

case 'Help'
slprophelp( 'sigandscopemgr' )

case 'Hilight'

HILITE_DATA = i_Unhilite( HILITE_DATA );


PortHandle = args{ 1 };
HILITE_DATA.lastHilited = PortHandle;
blk = get_param( PortHandle, 'Parent' );
HILITE_DATA.lastBlock = blk;

try 
hilite_system( PortHandle, 'find' );
catch mexception %#ok<NASGU>

end 
try 
hilite_system( blk, 'find' );
catch mexception %#ok<NASGU>

end 

case 'SigPropDialog'
portH = args{ 1 };
blkHandle = args{ 2 };
if ( ishandle( blkHandle ) )
ports = get_param( blkHandle, 'PortHandles' );
try 
portH = ports.Outport( 1 );
catch mexception %#ok<NASGU>

end 
end 
set_param( portH, 'OpenSigPropDialog', 'on' )

case 'GetLibraries'
[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 }, varargout{ 4 } ] = i_GetSignalLibraries;

case 'GetGeneratorLibraries'
[ varargout{ 1 }, varargout{ 2 }, ~, ~ ] = i_GetSignalLibraries;

case 'GetViewerLibraries'
[ ~, ~, varargout{ 1 }, varargout{ 2 } ] = i_GetSignalLibraries;

case 'GetLibraryBlocks'
if length( args ) == 2
[ varargout{ 1 }, varargout{ 2 } ] = LoadLibData( args{ 1 }, args{ 2 } );
else 
[ varargout{ 1 }, varargout{ 2 } ] = LoadLibData( args{ 1 } );
end 

case 'GetSigAndScopeMgr'
ModelHandle = args{ 1 };

case 'GetViewers'
ModelHandle = args{ 1 };
varargout{ 1 } = i_GetViewers( ModelHandle );

case 'GetGenerators'
ModelHandle = args{ 1 };
varargout{ 1 } = i_GetGenerators( ModelHandle );

case 'GetNumPorts'

BlockHandle = args{ 1 };
varargout{ 1 } = i_GetNumPorts( BlockHandle );

case 'GetSelectionData'
BlockHandle = args{ 1 };
varargout{ 1 } = i_GetNumPorts( BlockHandle );
[ varargout{ 2 }, varargout{ 3 } ] = i_GetSelections( BlockHandle );

if length( varargout{ 2 } ) < varargout{ 1 }
varargout{ 2 }( end  + 1:varargout{ 1 } ) = { DAStudio.message( 'Simulink:blocks:SSMgrNoSelection' ) };
varargout{ 3 }( end  + 1:varargout{ 1 } ) = {  - 1 };
end 

case 'UpdateSelections'
BlockHandle = args{ 1 };
ModelHandle = get_param( get_param( BlockHandle, 'Parent' ), 'Handle' );
idx = [  ];

isMPlay = ~isempty( strfind( get_param( BlockHandle, 'name' ), 'MPlay' ) );
if isMPlay
sigandscopemgr( 'ConnectToMPlay', BlockHandle );
end 

case 'PopulateObjects'
[ varargout{ 1 }, varargout{ 2 }, varargout{ 3 } ] = i_PopulateObjects( args{ 1 } );

case 'RenameObject'
BlockHandle = args{ 1 };
NewName = args{ 2 };
nextName = i_RenameObject( BlockHandle, NewName );
signalselector( 'UpdateName', BlockHandle, nextName );
varargout{ 1 } = nextName;





case 'GetSelection'

BlockHandle = args{ 1 };
InputNumber = args{ 2 };
vs = get_param( BlockHandle, 'IOSignals' );
if isempty( vs ) || numel( vs ) == 1 && isempty( vs{ 1 } )
ports = struct( 'Handle',  - 1, 'RelativePath', '' );
vs{ 1 } = ports;
end 
varargout{ 1 } = [ vs{ InputNumber }.Handle ];

case 'AddSelection'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
addSel = args{ 3 };

addCell = cell( 1, length( addSel ) );
for k = 1:length( addSel )
addCell{ k } = addSel( k );
end 
vs = get_param( BlockHandle, 'IOSignals' );
if ~isempty( vs )




nPorts = length( vs );
ioType = get_param( BlockHandle, 'IOType' );
siggen = strcmpi( ioType, 'siggen' );
if siggen && nPorts > 1
for i = 1:nPorts
if i == InputNumber
continue ;
end 
ports = vs{ i };
ports = ports( [ ports.Handle ] ~= addSel );
if isempty( ports )
ports = struct( 'Handle',  - 1, 'RelativePath', '' );
end 
vs{ i } = ports;
end 
end 

currPorts = vs{ InputNumber };
currPorts = [ currPorts( : )', struct( 'Handle', addCell, 'RelativePath', '' ) ];
currPorts = currPorts( [ currPorts.Handle ] ~=  - 1 );




[ ~, uniqueIdx ] = unique( [ currPorts.Handle ] );
currPorts = currPorts( uniqueIdx );

vs{ InputNumber } = currPorts;
else 
DAStudio.error( 'Simulink:blocks:NoIOSignals' );
vs{ InputNumber } = struct( 'Handle', addCell, 'RelativePath', '' );%#ok
end 
i_SetIOParam( BlockHandle, vs );

case 'RemoveSelection'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
remSel = args{ 3 };
vs = get_param( BlockHandle, 'IOSignals' );
currPorts = vs{ InputNumber };
idx = [  ];
allH = [ currPorts.Handle ];
for k = 1:length( remSel )
idx = [ idx, find( allH == remSel( k ) ) ];%#ok<*AGROW>
end 
currPorts( idx ) = [  ];
if isempty( currPorts )
currPorts = struct( 'Handle',  - 1, 'RelativePath', '' );
end 
vs{ InputNumber } = currPorts;
i_SetIOParam( BlockHandle, vs );

case 'SwitchSelection'
BlockHandle = args{ 1 };
InputNumber = args{ 2 };
newSel = args{ 4 };

vs = get_param( BlockHandle, 'IOSignals' );
vs{ InputNumber } = struct( 'Handle', newSel, 'RelativePath', '' );
i_SetIOParam( BlockHandle, vs );

case 'UpdateCache'
bd = args{ 1 };
UpdateCache( bd );

case 'GetFunctionHandle'
func = args{ 1 };
varargout{ 1 } = eval( [ '@', func ] );

case 'UpdateSimStatus'
varargout{ 1 } = i_UpdateSimStatus( args{ 1 } );

case 'ConnectToMPlay'
BlockHandle = args{ 1 };
i_ConnectToMPlay( BlockHandle );

case 'GetModelHandleForSSM'
ModelHandle = args{ 1 };
idx = find( [ DIALOG_USERDATA.ModelHandle ] == ModelHandle );
varargout{ 1 } = [  ];
if ~isempty( idx )
varargout{ 1 } = DIALOG_USERDATA( idx ).ModelHandle;
end 

end 


function [ generators, viewers, isSimulating ] = i_PopulateObjects( H )
generators = {  };
viewers = {  };
isSimulating = false;

if ( ishandle( H ) )

generators = i_GetGenerators( H );


viewers = i_GetViewers( H );


isSimulating = ~strcmp( get_param( H, 'SimulationStatus' ), 'stopped' );
end 

function viewers = i_GetViewers( model )

viewers = {  };
others = find_system( model, 'AllBlocks', 'on', 'SearchDepth', 1,  ...
'IOType', 'viewer' );

for i = 1:length( others )
ioviewer = others( i );









ioType = i_GetIOType2( ioviewer );

viewerType = Simulink.iomanager.IOType.findIOType( ioType );

if isempty( viewerType )
switch ( ioType )
case 'deprecatedScope'
deprName = 'Scope (Deprecated';
otherwise 
deprName = [ ioType, ' (Deprecated)' ];
end 
viewerType = Simulink.iomanager.IOType.createIOType(  ...
'deprecatedScope',  ...
deprName,  ...
'typefullpath',  ...
Simulink.scopes.getCallbackFile( ioviewer ),  ...
'',  ...
'iconstring',  ...
'single',  ...
Simulink.scopes.getPortPrefix( ioviewer ),  ...
false );
end 

numInputs = i_GetNumPorts( ioviewer );

if numInputs > 1 &&  ...
~strcmp( get_param( bdroot( ioviewer ), 'Lock' ), 'on' ) &&  ...
~strcmp( get_param( ioviewer, 'LinkStatus' ), 'implicit' )
numInputs = i_GetNumPorts( ioviewer );
end 

name = strrep( get_param( ioviewer, 'Name' ), sprintf( '\n' ), ' ' );
viewers{ i } = Simulink.iomanager.IOObject( viewerType,  ...
name,  ...
get_param( ioviewer, 'Handle' ), numInputs,  ...
i_GetNumPortsChangeable( ioviewer ), 0 );
end 


function generators = i_GetGenerators( model )

generators = {  };
gens = find_system( model, 'AllBlocks', 'on', 'SearchDepth', 1,  ...
'IOType', 'siggen' );

for i = 1:length( gens )
ioType = Simulink.scopes.getIOType( gens( i ) );

genType = Simulink.iomanager.IOType.findIOType( ioType );
portCounts = get_param( gens( i ), 'Ports' );
try 
if isempty( genType )
sigandscopemgr( 'DeleteObject', gens( i ) );
else 
generators{ end  + 1 } = Simulink.iomanager.IOObject( genType,  ...
strrep( get_param( gens( i ), 'Name' ), sprintf( '\n' ), ' ' ),  ...
get_param( gens( i ), 'Handle' ), portCounts( 2 ),  ...
i_GetNumPortsChangeable( gens( i ) ), 1 );
end 
catch mexception %#ok<NASGU>


end 
end 

function ioType = i_GetIOType2( object )


ioType = get_param( object, 'MaskType' );


if isempty( ioType )
ioType = get_param( object, 'BlockType' );



end 



function numPorts = i_GetNumPorts( object )
btype = get_param( object, 'BlockType' );
scope = strcmp( btype, 'Scope' ) || strcmp( btype, 'WebTimeScopeBlock' );

if scope
numPorts = Simulink.scopes.ViewerUtil.getNumAxes( object );
else 
portCounts = get_param( object, 'Ports' );
numPorts = 0;

if strcmp( get_param( object, 'IOType' ), 'viewer' )
isMPlay = ~isempty( strfind( get_param( object, 'name' ), 'MPlay' ) );
if isMPlay
numPorts = 1;
else 
numPorts = portCounts( 1 );
end 
elseif strcmp( get_param( object, 'IOType' ), 'siggen' )
numPorts = portCounts( 2 );
end 
end 




function scopeWithChangeableNumPorts = i_GetNumPortsChangeable( object )


blockType = get_param( object, 'BlockType' );
scopeWithChangeableNumPorts = strcmp( blockType, 'Scope' );





function str = i_GetHandleIdStr( sigs )

for i = 1:length( sigs )
handle = sigs( i ).Handle;
relPath = sigs( i ).RelativePath;
if isempty( relPath )
str{ i } = get_param( sigs( i ).Handle, 'Name' );
if isempty( str{ i } )
block = get_param( handle, 'parent' );
portNum = get_param( handle, 'PortNumber' );
fullpath = strrep( getfullname( block ), sprintf( '\n' ), ' ' );


fullpath = fullpath( strfind( fullpath, '/' ) + 1:length( fullpath ) );

str{ i } = [ fullpath, ':', num2str( portNum ) ];
else 
str{ i } = strrep( str{ i }, sprintf( '\n' ), ' ' );
end 
else 
fullpath = getfullname( handle );


fullpath = fullpath( strfind( fullpath, '/' ) + 1:length( fullpath ) );

relPath = strrep( relPath, ':o', ':' );
relPath = strrep( relPath, ':i', ':' );


relPath = relPath( strfind( relPath, '/' ) + 1:length( relPath ) );

str{ i } = strrep( [ fullpath, '/', relPath ], sprintf( '\n' ), ' ' );
end 

str{ i } = slprivate( 'enc2normalpath', str{ i } );
end 



function [ selections, sigs ] = i_GetSelections( block )

sigs = get_param( block, 'IOSignals' );
selections = {  };

for i = 1:length( sigs )
if ( [ sigs{ i }.Handle ] > 0 )%#ok<BDSCA>
selections{ i } = i_GetHandleIdStr( sigs{ i } );
else 
selections{ i } = DAStudio.message( 'Simulink:blocks:SSMgrNoSelection' );
end 
sigs{ i } = [ sigs{ i }.Handle ];
if ( isempty( sigs{ i } ) )
sigs{ i } =  - 1;
end 
end 


function nextName = i_RenameObject( BlockHandle, NewName )

model = get_param( BlockHandle, 'Parent' );
found = 1;num = 0;nextName = NewName;
throwError = 0;

while ( found ) && ~isequal( model,  - 1 )
found = ~isempty( find_system( model, 'AllBlocks', 'on',  ...
'SearchDepth', 1, 'Name', nextName ) );
if ( found )
throwError = 1;
num = num + 1;
nextName = [ NewName, num2str( num ) ];
end 
end 

if ( throwError )


errordlg( DAStudio.message( 'Simulink:blocks:RenameViewerErr', NewName,  ...
nextName ), DAStudio.message( 'Simulink:blocks:RenameErrorTitle' ), 'modal' )
end 

set_param( BlockHandle, 'Name', nextName )






function i_SetIOParam( block, data )


try 
set_param( block, 'IOSignals', data )
catch e
errordlg( e.message );
end 


function [ glibNames, glibs, vlibNames, vlibs, glibChildren, vlibChildren ] = i_GetSignalLibraries


vlc = Simulink.scopes.ViewerLibraryCache.Instance;
viewerLibraries = vlc.getAllViewerLibs;


preferredOrder = Simulink.scopes.ViewerUtil.GetPreferredLibraryOrder( 'viewer' );
viewerLibraries = Simulink.scopes.ViewerUtil.sortLibraries( viewerLibraries, preferredOrder );

viewerLibraries = [ viewerLibraries{ : } ];
vlibs = { viewerLibraries.name }';
vlibNames = { viewerLibraries.label }';
vlibChildren = { viewerLibraries.children };


generatorLibraries = vlc.getAllGeneratorLibs;


preferredOrder = Simulink.scopes.ViewerUtil.GetPreferredLibraryOrder( 'siggen' );
generatorLibraries = Simulink.scopes.ViewerUtil.sortLibraries( generatorLibraries, preferredOrder );

generatorLibraries = [ generatorLibraries{ : } ];
glibs = { generatorLibraries.name }';
glibNames = { generatorLibraries.label }';
glibChildren = { generatorLibraries.children };


function data = i_Unhilite( data )

if ~isempty( data )
try 
hilite_system( data.lastHilited, 'none' );
catch mexception %#ok<NASGU>

end 

try 
hilite_system( data.lastBlock, 'none' );
catch mexception %#ok<NASGU>

end 

data = [  ];
end 


function libH = i_LoadSys( lib )

if ~bdIsLoaded( lib )



try 
defwarn = warning;

warning( 'off' );
load_system( lib );
catch mexception %#ok<NASGU>

end 
warning( defwarn );
end 




libH = find_system( 0, 'SearchDepth', 0, 'Name', lib );
if isempty( libH )
DAStudio.error( 'Simulink:blocks:LibNotFoundOrNA', lib );
end 







function cache = GetCache( lib )
cache = [  ];

libH = i_LoadSys( lib );




dirty = onoff( get_param( libH, 'dirty' ) );
if dirty, return ;end 




ws = get_param( libH, 'LibraryWorkSpace' );
if isempty( ws ), return ;end 

wsDat = ws.data;
try 
if strcmp( wsDat( 1 ).Name, 'libCache' )
cache = wsDat( 1 ).Value;
end 
catch mexception %#ok<NASGU>

end 






function [ blocksTree, blockNames ] = LoadLibData( lib, forceLoad )

if nargin < 2
forceLoad = false;
end 

if ~forceLoad
cache = GetCache( lib );

if ~isempty( cache )
blocksTree = cache.blocksTree;
blockNames = cache.blockNames;
else 
[ blocksTree, blockNames ] = SigAndScopeMgrLoadLibrary( lib );
end 
else 
[ blocksTree, blockNames ] = SigAndScopeMgrLoadLibrary( lib );
end 








function UpdateCache( lib )

locked = onoff( get_param( lib, 'Lock' ) );
if locked
set_param( lib, 'Lock', 'off' );
end 




[ blocksTree, blockNames ] = SigAndScopeMgrLoadLibrary( lib );

libCache.blocksTree = blocksTree;
libCache.blockNames = blockNames;




ws = get_param( lib, 'LibraryWorkSpace' );
if isempty( ws )
MSLDiagnostic( 'Simulink:blocks:CacheUpdateErr' ).reportAsWarning;
end 

assignin( ws, 'libCache', libCache );

set_param( lib, 'Lock', onoff( locked ) );







function isSimulating = i_UpdateSimStatus( H )
isSimulating = false;

if ( ishandle( H ) )

isSimulating = ~strcmp( get_param( H, 'SimulationStatus' ), 'stopped' );
end 






function i_ConnectToMPlay( BlockHandle )




MPlayIO.mplayinst( BlockHandle, true );






function i_CloseMPlay( BlockHandle )


mPlayUD = get_param( BlockHandle, 'UserData' );
if isa( mPlayUD.hMPlay, 'uiscopes.Framework' )
mPlayUD.hMPlay.close;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpyqblD4.p.
% Please follow local copyright laws when handling this file.

