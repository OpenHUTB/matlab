function varargout = evalinScopeSectionIncludingLibrary(  ...
model, exprToEval, ddSection, libDD )






















if ischar( model )
load_system( model );
end 

mdlDD = get_param( model, 'DataDictionary' );



modelHandle = get_param( model, 'Handle' );
if ~isempty( modelHandle ) && slprivate( 'simInputGlobalWSExists', modelHandle )
warning( message( 'Simulink:Data:CannotResolveVariablesInSimInputGlobalWS', 'evalinGlobalScope' ) );
end 

if isempty( mdlDD ) && isempty( libDD )


[ varargout{ 1:nargout } ] = evalin( 'base', exprToEval );
else 


allDD = libDD;


dest = 'Base Workspace';
if ~isempty( mdlDD )

ddName = mdlDD;
allDD{ end  + 1 } = mdlDD;
dest = mdlDD;
else 

ddName = libDD{ 1 };
end 
dd = Simulink.dd.open( ddName );
allDD = unique( allDD );
hasBWS = strcmp( get_param( model, 'EnableAccessToBaseWorkspace' ), 'on' );
[ varargout{ 1:nargout } ] = evalinDDSet( dd, exprToEval, allDD,  ...
ddSection, hasBWS, dest );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpUR37ph.p.
% Please follow local copyright laws when handling this file.

