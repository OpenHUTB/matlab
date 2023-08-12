function varargout = ssGenCode( varargin )








persistent CREATEINFO


mlock

if nargin == 0
return ;
end 

action = varargin{ 1 };

switch action
case 'Create'



block = varargin{ 2 };
if ( nnz( ishandle( block ) ) == 0 )

try 
block_hdl = get_param( block, 'Handle' );
catch exc
LocalErrorExit(  - 1,  - 1, 'InvalidBlock', exc );
return ;
end 
else 
block_hdl = block;
end 

if nargin > 2
exportfcns = varargin{ 3 };
else 
exportfcns = 0;
end 

if exportfcns


if ecoderinstalled
load_system( 'simulink' );
load_system( 'expfcnlib' );
else 
LocalErrorExit( bdroot( block_hdl ),  - 1, 'invalidSubsystemBuild', [  ] );
end 
end 

try 
if ( strcmpi( get_param( block_hdl, 'BlockType' ), 'SubSystem' ) == 0 )
LocalErrorExit( bdroot( block_hdl ),  - 1, 'NotSubsystem', [  ] );
return ;
end 
catch exc
LocalErrorExit( bdroot( block_hdl ),  - 1, 'NotSubsystem', exc );
return ;
end 

if strcmp( get_param( bdroot( block_hdl ), 'isObserverBD' ), 'on' )
LocalErrorExit( bdroot( block_hdl ),  - 1, 'ObserverNotSupported', [  ] );
end 









CREATEINFO.BLK_HDL = block_hdl;
CREATEINFO.EXPORT_FCNS = exportfcns;
case 'Build'







assert( ~isempty( CREATEINFO ), '"Create" must be called before "Build"' );
blockHdl = CREATEINFO.BLK_HDL;
exportfcns = CREATEINFO.EXPORT_FCNS;
slbuildargs = { blockHdl,  ...
'OkayToPushNags', true };
if exportfcns
slbuildargs{ end  + 1 } = 'Mode';
slbuildargs{ end  + 1 } = 'ExportFunctionCalls';
end 
try 


slbuild( slbuildargs{ : } );
catch e %#ok<NASGU>

end 
case 'GetErrorMsgTxtForID'

varargout{ 1 } = LocalRetrieveErrorText( varargin{ 2 }, [  ] );
otherwise 
DAStudio.error( 'RTW:utility:UnknownAction', 'ssGenCode' );
end 

return ;








function LocalErrorExit( origModel, newModel, errorCode, exc, varargin )



if ishandle( origModel )
mdlName = get_param( origModel, 'Name' );
if isequal( get_param( mdlName, 'SimulationStatus' ), 'paused' )
feval( mdlName, [  ], [  ], [  ], 'term' );
end 
end 


rtwprivate( 'rtwattic', 'deleteSIDMap' );

if ishandle( newModel )
close_system( newModel, 0 );
end 

if nargin > 4
errText = varargin{ 1 };
errID = '';
else 
[ errText, errID ] = LocalRetrieveErrorText( errorCode, exc );
end 


if isempty( exc )
exc = MException( errID, errText );
end 

errStruct = LocGetLastError( errorCode, exc );
throw( errStruct );




function [ errorText, errID ] = LocalRetrieveErrorText( errorCode, exc )



errID = [ 'RTW:buildProcess:', errorCode ];
switch errorCode
case 'InvalidBlock'
errorText = DAStudio.message( errID, 'ssGenCode' );
case 'NotSubsystem'
errorText = DAStudio.message( errID, 'code' );
case 'invalidSubsystemBuild'
errorText = DAStudio.message( errID );
case 'FailToCreate'
errorText = DAStudio.message( errID );
case 'CannotSetRTWParams'
errorText = DAStudio.message( errID, 'code' );
case 'BuildFailed'
if isempty( exc )
errID = 'RTW:utility:UnknownError';
errorText = DAStudio.message( errID );
else 
errID = exc.identifier;
errorText = exc.message;
end 
case 'ObserverNotSupported'
errorText = DAStudio.message( errID, 'code' );
otherwise 
errID = 'RTW:utility:UnknownError';
errorText = DAStudio.message( errID );
end 



function err = LocGetLastError( id, mlErr )

errId = [ 'RTW:SSGENCODE:', id ];
errTxt = '';

if ~isempty( mlErr.identifier )
errId = [ errId, ':', mlErr.identifier ];
errTxt = mlErr.message;
end 

err = MException( errId, '%s', errTxt );

err = err.addCause( mlErr );





% Decoded using De-pcode utility v1.2 from file /tmp/tmpYjIVzm.p.
% Please follow local copyright laws when handling this file.

