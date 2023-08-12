






function extModeArgs = parseExtModeArgs( extModeMexArgs, transport, modelName, codeGenFolder, buildInfo )








R36
extModeMexArgs
transport
modelName
codeGenFolder
buildInfo = RTW.BuildInfo.empty(  )
end 

switch transport
case { Simulink.ExtMode.Transports.XCPTCP.Transport,  ...
Simulink.ExtMode.Transports.XCPSerial.Transport,  ...
Simulink.ExtMode.Transports.XCPCAN.Transport }
extModeArgs = coder.internal.xcp.parseXcpExtModeArgs( extModeMexArgs, transport, modelName, codeGenFolder, buildInfo );

case { Simulink.ExtMode.Transports.TCP.Transport,  ...
Simulink.ExtMode.Transports.Serial.Transport }
extModeArgs = coder.internal.xcp.parseClassicExtModeArgs( extModeMexArgs, transport );

case { Simulink.ExtMode.Transports.None.Transport,  ...
Simulink.ExtMode.Transports.SharedMem.Transport }
extModeArgs = [  ];
otherwise 
assert( false, 'transport not supported' );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpy3DYSw.p.
% Please follow local copyright laws when handling this file.

