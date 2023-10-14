function extModeArgs = parseExtModeArgs( extModeMexArgs, transport, modelName, codeGenFolder, buildInfo )

arguments
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


