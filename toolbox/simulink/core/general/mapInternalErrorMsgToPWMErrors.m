function slException = mapInternalErrorMsgToPWMErrors( ~, ~, origException )
if exist( 'origException', 'var' )
if ( strcmp( origException.identifier, 'Simulink:blocks:InvInputDutyCycleForVPG' ) )
blockHandle = origException.arguments{ 1 };
portLabel = origException.arguments{ 2 };
currTime = origException.arguments{ 3 };
offendingBlock = regexprep( blockHandle, '/Variable Pulse Generator', '' );
msg = message( 'Simulink:blocks:InvInputDutyCycleForPWM',  ...
offendingBlock,  ...
portLabel,  ...
currTime );
slException = MSLException( msg );
elseif ( strcmp( origException.identifier, 'Simulink:blocks:InvSamplingRateForVPG' ) )
blockHandle = origException.arguments{ 1 };
sampleTime = origException.arguments{ 2 };
duty = origException.arguments{ 3 };
period = origException.arguments{ 4 };
currTime = origException.arguments{ 5 };
offendingBlock = regexprep( blockHandle, '/Variable Pulse Generator', '' );
msg = message( 'Simulink:blocks:InvSampleTimeForPWM',  ...
offendingBlock,  ...
sampleTime,  ...
duty,  ...
period,  ...
currTime );
slException = MSLException( msg );
elseif ( strcmp( origException.identifier, 'SimulinkBlocks:PropagationDelay:InputDelayMustBeGreaterThanSampleTime' ) )
inputdelay = origException.arguments{ 2 };
blockHandle = origException.arguments{ 3 };
sampletime = origException.arguments{ 4 };
offendingBlock = regexprep( blockHandle, '/Propagation Delay', '' );
msg = message( 'Simulink:blocks:InvInitialDelayForPWM',  ...
inputdelay,  ...
offendingBlock,  ...
sampletime );
slException = MSLException( msg );
else 
slException = origException;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBBQvde.p.
% Please follow local copyright laws when handling this file.

