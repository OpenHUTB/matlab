function varargout = evalinScopeSection( model, exprToEval, ddSection, checkBWS )




















if ischar( model )
load_system( model );
end 

ddSpec = get_param( model, 'DataDictionary' );



modelHandle = get_param( model, 'Handle' );
if ~isempty( modelHandle ) && slprivate( 'simInputGlobalWSExists', modelHandle )
warning( message( 'Simulink:Data:CannotResolveVariablesInSimInputGlobalWS', 'evalinGlobalScope' ) );
end 

if isempty( ddSpec )


[ varargout{ 1:nargout } ] = evalin( 'base', exprToEval );
else 


dd = Simulink.dd.open( ddSpec );
if slfeature( 'SLModelAllowedBaseWorkspaceAccess' ) > 0 && checkBWS
hasBWS = strcmp( get_param( model, 'EnableAccessToBaseWorkspace' ), 'on' );
[ varargout{ 1:nargout } ] = evalin( dd, exprToEval, ddSection, 'SimulinkDataObject', hasBWS );
else 
[ varargout{ 1:nargout } ] = evalin( dd, exprToEval, ddSection );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpo3jSuU.p.
% Please follow local copyright laws when handling this file.

