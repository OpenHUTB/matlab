function slvrJacobianPattern = slGetSlvrJacobianPattern( obj )



Simulink.Solver.SlvrJacobianPattern.empty( 0 );
needToTerm = false;
mdl = '';

try 
mdl = get_param( bdroot( obj ), 'Name' );

if ( ~strcmp( get_param( mdl, 'BlockDiagramType' ), 'model' ) )
localCleanup( mdl, needToTerm );
DAStudio.error( 'Simulink:utility:SlGetSlvrJacobianPatternNotModel' );
end 

simStatus = get_param( mdl, 'SimulationStatus' );
if ~strcmpi( simStatus, 'paused' )
feval( mdl, 'init' );
needToTerm = true;
end 

if ( strcmp( get_param( obj, 'Type' ), 'block_diagram' ) )
slvrJacobianPatternArr = feval( mdl, [  ], [  ], [  ], 'slvrJacobianPattern' );
else 
DAStudio.error( 'Simulink:utility:SlGetSlvrJacobianPatternBadInput' );
end 

slvrJacobianPattern = Simulink.Solver.SlvrJacobianPattern( slvrJacobianPatternArr );%#ok

catch e
localCleanup( mdl, needToTerm );
rethrow( e )
end 

localCleanup( mdl, needToTerm );

end 


function localCleanup( mdl, needToTerm )

if ( needToTerm )
feval( mdl, 'term' );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpVae02g.p.
% Please follow local copyright laws when handling this file.

