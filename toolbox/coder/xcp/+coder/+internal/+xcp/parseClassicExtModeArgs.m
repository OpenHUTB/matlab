






function classicExtModeArgs=parseClassicExtModeArgs(extModeMexArgs,transport)



    assert(ismember(transport,...
    {Simulink.ExtMode.Transports.TCP.Transport,...
    Simulink.ExtMode.Transports.Serial.Transport}));

    classicExtModeArgs.transport=transport;
    classicExtModeArgs.verbosityLevel=0;


    tokens=coder.internal.xcp.tokenizeArgsString(extModeMexArgs);

    if strcmp(classicExtModeArgs.transport,Simulink.ExtMode.Transports.TCP.Transport)
        classicExtModeArgs=coder.internal.xcp.parseClassicExtModeTCPIPParameters(classicExtModeArgs,tokens);
    else
        classicExtModeArgs=coder.internal.xcp.parseClassicExtModeSerialParameters(classicExtModeArgs,tokens);
    end

end
