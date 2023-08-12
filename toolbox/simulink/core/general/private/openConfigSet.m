function openConfigSet






studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

if ( isempty( studios ) )
return ;
end 

topMostHandle = studios( 1 ).App.blockDiagramHandle;
topMostModel = get_param( topMostHandle, 'name' );

cs = getActiveConfigSet( topMostModel );
cs.openDialog;

if ( ~strcmp( cs.class, 'Simulink.ConfigSetRef' ) )
configset.showParameterGroup( topMostModel, { 'Solver' } );
end 

return ;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvbkScN.p.
% Please follow local copyright laws when handling this file.

