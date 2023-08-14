function argSpec=getPortDefaultConf(hSrc,portH,portNum,argPos)





    portName=get_param(portH,'Name');
    argName=portName;
    argName=regexprep(argName,'[^a-zA-Z0-9_]','_');
    argName=sprintf('arg_%s',argName);

    cat='None';
    qualifier='none';
    portNum=99999999;

    portType=get_param(portH,'BlockType');
    if hSrc.isControlPort(portH)
        portType='Inport';

    end

    argSpec=RTW.CPPFcnArgSpec(portName,portType,cat,argName,...
    argPos,qualifier,portNum,1);
