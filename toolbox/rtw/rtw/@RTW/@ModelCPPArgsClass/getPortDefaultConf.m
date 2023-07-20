function argSpec=getPortDefaultConf(hSrc,portH,portNum,argPos)





    portName=get_param(portH,'Name');
    argName=portName;
    argName=regexprep(argName,'[^a-zA-Z0-9_]','_');
    argName=sprintf('arg_%s',argName);
    cat='Pointer';
    portType=get_param(portH,'BlockType');

    if hSrc.isControlPort(portH)||strcmpi(portType,'Inport')
        hasBusObject=false;
        if hSrc.isControlPort(portH)
            dimsPortH=hSrc.getControlPortHandle(portH);
        else
            ph=get_param(portH,'PortHandles');
            dimsPortH=ph.Outport;

            useBusObject=get_param(portH,'UseBusObject');
            if strcmp(useBusObject,'on')
                hasBusObject=true;
            end
        end
        portType='Inport';
        dimensions=[];

        if dimsPortH~=-1
            dimensions=get_param(dimsPortH,'CompiledPortDimensions');
        end


        if~isempty(dimensions)&&~hasBusObject
            cat='Value';
            for index=2:length(dimensions)
                if dimensions(index)>1
                    cat='Pointer';
                    break;
                end
            end
        end
    end
    if strcmpi(portType,'inport')&&strcmpi(cat,'pointer')
        qualifier='const *';
    else
        qualifier='none';
    end

    argSpec=RTW.CPPFcnArgSpec(portName,portType,cat,argName,argPos,...
    qualifier,portNum,1);

