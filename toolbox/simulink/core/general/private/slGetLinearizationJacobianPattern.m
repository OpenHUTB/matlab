function pattern = slGetLinearizationJacobianPattern( obj )



needToTerm = false;
needToRestore = false;
setting = 'off';
mdl = '';


try 
mdl = get_param( bdroot( obj ), 'Name' );

if ( ~strcmp( get_param( mdl, 'BlockDiagramType' ), 'model' ) )
localCleanup( mdl, needToTerm, needToRestore, setting );
DAStudio.error( 'Simulink:utility:SlGetLinearizationJacobianPatternNotModel' );
end 

simStatus = get_param( mdl, 'SimulationStatus' );
setting = get_param( mdl, 'AnalyticLinearization' );

if strcmp( setting, 'on' ) && strcmp( simStatus, 'paused' )


needToTerm = false;
else 
if ~strcmpi( simStatus, 'stopped' )
feval( mdl, 'term' );
end 
set_param( mdl, 'AnalyticLinearization', 'on' );
needToRestore = true;
feval( mdl, [  ], [  ], [  ], 'lincompile' );
needToTerm = true;
end 

if ( strcmp( get_param( obj, 'Type' ), 'block_diagram' ) )
openLoopPattern = feval( mdl, [  ], [  ], [  ], 'jacobianPattern' );
else 
DAStudio.error( 'Simulink:utility:SlGetLinearizationJacobianPatternBadInput' );
end 

JopenInfo.Jopen.A = openLoopPattern.A;
JopenInfo.Jopen.B = openLoopPattern.B;
JopenInfo.Jopen.C = openLoopPattern.C;
JopenInfo.Jopen.D = openLoopPattern.D;
JopenInfo.Jopen.E = openLoopPattern.Mi.E;
JopenInfo.Jopen.F = openLoopPattern.Mi.F;
JopenInfo.Jopen.G = openLoopPattern.Mi.G;
JopenInfo.Jopen.H = openLoopPattern.Mi.H;
nx = size( openLoopPattern.A, 1 );
if ( nx > 0 )
JopenInfo.stateOffset = 0:nx - 1;
else 
JopenInfo.stateOffset = [  ];
end 
pattern = getCloseLoopSlvrJacobianPattern( JopenInfo );
pattern.blockName = openLoopPattern.blockName;
pattern.stateName = openLoopPattern.stateName;
pattern.outputName = openLoopPattern.Mi.OutputName;
pattern.inputName = openLoopPattern.Mi.InputName;

catch e
localCleanup( mdl, needToTerm, needToRestore, setting );
rethrow( e )
end 

localCleanup( mdl, needToTerm, needToRestore, setting );

end 


function localCleanup( mdl, needToTerm, needToRestore, setting )
if ( needToTerm )
feval( mdl, 'term' );
end 

if ( needToRestore )
set_param( mdl, 'AnalyticLinearization', setting );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpxVjlrY.p.
% Please follow local copyright laws when handling this file.

