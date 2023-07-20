


function portInside=getInsidePort(ip)

    import Simulink.Structure.Utils.*

    portInside=ip;

    ipO=get_param(ip,'Object');

    if isInputOrControlPort(ipO)
        iBType='Inport';
    else
        iBType='Outport';
    end

    idx=get_param(ip,'PortNumber');
    ownerSub=get_param(ip,'Parent');
    so=get_param(ownerSub,'Object');

    if isSubsystemVirtual(so)||isSubsystemNonVirtual(so)||isNormalModeModelRef(so)

        if~strcmp(so.Type,'block_diagram')
            if isNormalModeModelRef(so)
                mdlName=so.ModelName;
                mo=get_param(mdlName,'Object');
                so=mo;
            end
        end

        gblkList=find_system(so.handle,'SearchDepth',1,...
        'LookUnderMasks','all','FollowLinks','on','FindAll',...
        'off','BlockType',iBType);

        for j=1:length(gblkList)
            block=gblkList(j);

            oBlock=get_param(block,'Object');
            iPort=get_param(block,'PortHandles');
            pIdx=str2double(oBlock.Port);
            if strcmp(iBType,'Inport')
                iPort=iPort.Outport;
            elseif strcmp(iBType,'Outport')
                iPort=getAllInportHandles(iPort);
            else
                return;
            end

            if pIdx==idx
                portInside=iPort;
                break;
            end
        end
    end

end