function[argName,cat,qualifier]=getPortDefaultConf(hSrc,portH)





    argName=get_param(portH,'Name');
    argName=regexprep(argName,'[\s\\\/,\(\)\[\]\{\}]','_');
    argName=sprintf('arg_%s',argName);
    cat='Pointer';
    qualifier='none';
    portType=get_param(portH,'BlockType');

    if hSrc.isControlPort(portH)||strcmpi(portType,'Inport')
        dimensions=[];

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


