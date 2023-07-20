function argSpec=getPortDefaultConf(hSrc,portH,portNum,argPos)




    MSLDiagnostic('RTW:fcnClass:voidclassdeprecation').reportAsWarning;
    portName=get_param(portH,'Name');
    portType=get_param(portH,'BlockType');
    if hSrc.isControlPort(portH)
        portType='Inport';

    end
    argSpec=RTW.CPPFcnVoidArgSpec(portName,portType,portNum);
