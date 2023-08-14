function syncPortsForCppMapping(hSrc)




    hModel=hSrc.ModelHandle;


    if~ishandle(hModel)
        DAStudio.error('RTW:fcnClass:invalidMdlHdl');
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                DAStudio.error('RTW:fcnClass:invalidMdlHdl');
            end
        catch me
            DAStudio.error('RTW:fcnClass:invalidMdlHdl');
        end
    end

    [inpH,outpH]=hSrc.getPortHandles(hModel);

    hSrc.Data=[];
    posInArgs=1;

    for i=1:length(inpH)
        portType=get_param(inpH(i),'BlockType');
        if strcmpi(portType,'Inport')
            portNumStr=get_param(inpH(i),'Port');
            portNum=str2double(portNumStr)-1;
        else
            assert(hSrc.isControlPort(inpH(i)));
            portNum=i-1;
        end

        argSpec=hSrc.getPortDefaultConf(inpH(i),portNum,posInArgs);

        argSpec.PortNum=portNum;
        posInArgs=posInArgs+1;
        hSrc.Data=[hSrc.Data;argSpec];
    end

    for i=1:length(outpH)
        portNumStr=get_param(outpH(i),'Port');
        portNum=str2double(portNumStr)-1;

        argSpec=hSrc.getPortDefaultConf(outpH(i),portNum,posInArgs);

        argSpec.PortNum=portNum;
        posInArgs=posInArgs+1;
        hSrc.Data=[hSrc.Data;argSpec];
    end
