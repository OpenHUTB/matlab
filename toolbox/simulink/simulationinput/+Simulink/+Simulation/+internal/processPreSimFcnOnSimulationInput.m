function simInput = processPreSimFcnOnSimulationInput( simInput )




R36
simInput( 1, 1 )Simulink.SimulationInput
end 

if ~isempty( simInput.PreSimFcn )
modelName = simInput.ModelName;
oldMStackValue = diagnostic_stacks_handlers( 'm_stack', true );
restoreMStackValue = onCleanup( @(  )diagnostic_stacks_handlers( 'm_stack', oldMStackValue ) );

try 
try 
simIn = simInput.PreSimFcn( simInput );
if isa( simIn, 'Simulink.SimulationInput' ) &&  ...
isscalar( simIn )
simInput = simIn;
end 
catch ME
if ~strcmp( ME.identifier, 'MATLAB:TooManyOutputs' ) &&  ...
~strcmp( ME.identifier, 'MATLAB:maxlhs' )
rethrow( ME )
end 

simInput.PreSimFcn( simInput );
end 
catch ME
reportError( simInput.ModelName, message( 'Simulink:Commands:SimInputPrePostFcnError', 'PreSimFcn' ), ME );
end 


if simInput.ModelName ~= modelName
reportError( simInput.ModelName, message( 'Simulink:Commands:DifferentModelsInArrayOfSimInput' ) );
end 
end 
simInput.PreSimFcn = [  ];
end 

function reportError( modelName, msg, cause )
R36
modelName( 1, 1 )string
msg( 1, 1 )message
cause MException = MException.empty
end 

err = MException( msg );
msld = MSLDiagnostic( err );
if ~isempty( cause )
msld = msld.addCause( MSLDiagnostic( cause ) );
end 

showInDiagnosticViewer = false;
msld.reportAsError( modelName, showInDiagnosticViewer );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSlWxNM.p.
% Please follow local copyright laws when handling this file.

