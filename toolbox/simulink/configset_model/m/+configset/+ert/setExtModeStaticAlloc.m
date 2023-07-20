function newvalue=setExtModeStaticAlloc(hSrc,value)





    if coder.internal.xcp.isXCPTransport(hSrc)

        if strcmp(value,'off')&&~isempty(hSrc.getConfigSet)
            MSLDiagnostic('Simulink:Engine:ExtModeOpenProtocolParamNotSupported',...
            'ExtModeStaticAlloc').reportAsWarning;
        end

        newvalue=hSrc.ExtModeStaticAlloc;
    else
        newvalue=value;
    end
