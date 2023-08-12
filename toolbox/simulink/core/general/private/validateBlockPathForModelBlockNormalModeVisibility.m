function validateBlockPathForModelBlockNormalModeVisibility( blockpath, topModelName )



if ( blockpath.getLength(  ) == 0 )
errID = Simulink.SimulationData.errorID( 'BlockPathCannotBeEmpty' );
DAStudio.error( errID );
end 


bpModel = blockpath.getModelNameForPath( blockpath.getBlock( 1 ) );
if ( ~isequal( bpModel, topModelName ) )
errID = 'Simulink:util:NormalModeVisibilityNotRootedAtTopModel';
DAStudio.error( errID, bpModel, topModelName );
end 


blockpath.validate(  );


for i = 1:blockpath.getLength(  )
currBlock = blockpath.getBlock( i );

if ( ~isequal( get_param( currBlock, 'BlockType' ), 'ModelReference' ) )
DAStudio.error( 'Simulink:util:NormalModeVisibilityMustBeModelBlock', currBlock );
elseif ( ~isequal( get_param( currBlock, 'SimulationMode' ), 'Normal' ) )
DAStudio.error( 'Simulink:util:NormalModeVisibilityMustBeNormalMode', currBlock );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpckDUto.p.
% Please follow local copyright laws when handling this file.

