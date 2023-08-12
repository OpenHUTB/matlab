function varargout = sldebugui( varargin )








persistent DEBUGGER_HANDLE;
persistent MODEL_HANDLE;
persistent MODEL_NAME;
persistent REF_MODEL_NAMES;



mlock




narginchk( 1, 2 );
Action = varargin{ 1 };

function i_close_for_model( h )



if h == MODEL_HANDLE
sldebugui( 'Destroy' );
end 
end 




switch ( Action )




case 'Create'


if ~usejava( 'MWT' )
DAStudio.error( 'Simulink:tools:slDebuguiRequiresJava' );
end 

model = varargin{ 2 };
if ( strcmp( get_param( 0, 'SlDebugEnable' ), 'on' ) )
if ( isempty( DEBUGGER_HANDLE ) )
if isempty( find_system( 'type', 'blockdiagram', 'Name', model ) )
load_system( model );
end 

MODEL_NAME = get_param( model, 'Name' );
DEBUGGER_HANDLE = com.mathworks.toolbox.simulink.debugger.SimDebugger.CreateSimulinkDebugger( MODEL_NAME );
tmpHandle = get_param( model, 'Handle' );
MODEL_HANDLE = tmpHandle;


Simulink.addBlockDiagramCallback( tmpHandle, 'PreClose', 'sldebugui',  ...
@(  )i_close_for_model( tmpHandle ), true );


REF_MODEL_NAMES = Simulink.ModelReference.internal.find_normal_mdlrefs( MODEL_NAME );
else 
frame = DEBUGGER_HANDLE.getParent;
awtinvoke( frame, 'show()' );
name = get_param( MODEL_HANDLE, 'Name' );
if ~strcmp( model, name )
errordlg( DAStudio.message( 'Simulink:tools:slDebuguiInUse', name, model ) );
end 
end 
else 
MSLDiagnostic( 'Simulink:tools:NoSLDebugWithTLCDebug' ).reportAsWarning;
end 




case 'Start'
frame = DEBUGGER_HANDLE.getParent;
if isempty( find_system( 'type', 'block_diagram', 'Name', MODEL_NAME ) )
load_system( MODEL_NAME );
MODEL_HANDLE = get_param( MODEL_NAME, 'Handle' );
end 
name = get_param( MODEL_NAME, 'Name' );
DEBUGGER_HANDLE.updateWindowTitle( frame, name );
origVB = warning( 'query', 'verbose' );
origBT = warning( 'query', 'backtrace' );
warning( 'off', 'verbose' );
warning( 'off', 'backtrace' );
sim( name, 'Debug', 'on' );
warning( origBT );
warning( origVB );
munlock;




case 'Close'
if ( isempty( MODEL_HANDLE ) || ( MODEL_HANDLE ==  - 1 ) || isempty( DEBUGGER_HANDLE ) )
varargout = { true };
return ;
end 
frame = DEBUGGER_HANDLE.getParent;
DEBUGGER_HANDLE = [  ];
MODEL_HANDLE =  - 1;
REF_MODEL_NAMES = {  };
awtinvoke( frame, 'dispose()' );
varargout = { false };
munlock;





case 'Destroy'
if ( isempty( MODEL_HANDLE ) || ( MODEL_HANDLE ==  - 1 ) || isempty( DEBUGGER_HANDLE ) ), return ;end 
DEBUGGER_HANDLE.cleanup;
frame = DEBUGGER_HANDLE.getParent;
DEBUGGER_HANDLE = [  ];
MODEL_HANDLE =  - 1;
REF_MODEL_NAMES = {  };
awtinvoke( frame, 'dispose()' );
munlock;




case 'GetHandle'
varargout{ 1 } = DEBUGGER_HANDLE;

case 'GetModelHandle'

if isempty( MODEL_HANDLE )
varargout{ 1 } =  - 1;
else 
varargout{ 1 } = MODEL_HANDLE;
end 




case 'GetCurrentBlock'
blk = gcb;
msg = '';

if isempty( blk )
msg = DAStudio.message( 'Simulink:tools:slDebugCurrentBlockIsEmpty',  ...
MODEL_NAME );
elseif ~isequal( bdroot( blk ), MODEL_NAME ) && ~any( strcmpi( bdroot( blk ), REF_MODEL_NAMES ) )
msg = DAStudio.message( 'Simulink:tools:slDebugCurrentBlockNotInModel',  ...
strrep( getfullname( blk ), newline, ' ' ),  ...
MODEL_NAME );
elseif isequal( get_param( blk, 'Virtual' ), 'on' )
msg = DAStudio.message( 'Simulink:tools:slDebugBreakpointSetOnVirtualBlock',  ...
strrep( getfullname( blk ), newline, ' ' ),  ...
MODEL_NAME );
end 
if isempty( msg )
blk = strrep( getfullname( blk ), newline, ' ' );
else 
errordlg( msg );
blk = '';
end 
varargout{ 1 } = blk;




case 'GetModelState'
if ( MODEL_HANDLE ==  - 1 ), return ;end 
state = get_param( MODEL_HANDLE, 'SimulationStatus' );
varargout{ 1 } = state;




case 'GetTopLevelStackData'
if ( MODEL_HANDLE ==  - 1 ), return ;end 
topstack = slInternal( 'sldebug', get_param( MODEL_HANDLE, 'Name' ), 'stack' );
varargout{ 1 } = i_ConvertStackToObject( topstack, 0 );




case 'GetStackData'
if ( MODEL_HANDLE ==  - 1 ), return ;end 
indices = varargin{ 2 };
indices = double( [ indices{ : } ] );

stack = slInternal( 'sldebug', get_param( MODEL_HANDLE, 'Name' ), 'stack', indices );
varargout{ 1 } = i_ConvertStackToObject( stack, indices );




case 'RefreshStack'
if ~isempty( DEBUGGER_HANDLE )
DEBUGGER_HANDLE.refreshStack;
end 




case 'GetBlockBreakPoints'
fullnames = {  };
bPoints = slInternal( 'sldebug', get_param( MODEL_HANDLE, 'Name' ), 'breakpoints' );
if ~isempty( bPoints ) && isstruct( bPoints )
blockPoints = bPoints( [ bPoints.nodeIndex ] ==  - 1 );
if ~isempty( blockPoints )
fullnames = getfullname( [ blockPoints.handle ] );
end 
end 
varargout{ 1 } = fullnames;

case 'IsPauseRequested'
varargout{ 1 } = DEBUGGER_HANDLE.querySimulationPause;
case 'GetAnimationDelay'
varargout{ 1 } = DEBUGGER_HANDLE.queryAnimationDelay;
end 
end 




function object = i_ConvertStackToObject( stack, indices )
if ( ~isempty( stack ) )
object = cell( 1, length( stack ) );
for i = 1:length( stack )
isBlock = double( strcmp( get_param( stack( i ).handle, 'Type' ), 'block' ) );
object{ i } = com.mathworks.toolbox.simulink.debugger.StackObject(  ...
stack( i ).name, stack( i ).handle, stack( i ).status,  ...
stack( i ).breakOnEntry, indices( i ), stack( i ).childNodeIndices, isBlock,  ...
stack( i ).blockpath );
end 
else 
object = {  };
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXXNz_T.p.
% Please follow local copyright laws when handling this file.

