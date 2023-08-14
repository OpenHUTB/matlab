function PortNames=autoblksgetblkportnames(BlkHdl,PortHdls,PortType)




    if~ishandle(BlkHdl)
        BlkHdl=get_param(BlkHdl,'Handle');
    end
    if strcmp(get_param(BlkHdl,'BlockType'),'SubSystem')
        SysHdl=BlkHdl;
    elseif strcmp(get_param(BlkHdl,'BlockType'),'ModelReference')
        MdlName=get_param(BlkHdl,'ModelName');
        if bdIsLoaded(MdlName)
            SysHdl=get_param(MdlName,'Handle');
        else
            SysHdl=-1;
        end
    else
        SysHdl=-1;
    end


    if ishandle(SysHdl)
        if strcmp(PortType,'Inport')||strcmp(PortType,'Outport')
            PortBlkHdls=find_system(SysHdl,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType',PortType);
        elseif strcmp(PortType,'LConn')
            PortBlkHdls=find_system(SysHdl,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','PMIOPort','Side','Left');
        else
            PortBlkHdls=find_system(SysHdl,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','PMIOPort','Side','Right');
        end
        PortNames=get_param(PortBlkHdls,'Name');
        if~ischar(PortNames)
            PortNumStr=get_param(PortBlkHdls,'Port');
            PortNums=zeros(size(PortBlkHdls));
            if PortNums>1
                for i=1:length(PortNums)
                    PortNums(i)=str2double(PortNumStr{i});
                end
                [~,SortI]=sort(PortNums);
                PortNames=PortNames(SortI);
            end
        else
            PortNames={PortNames};
        end
    else
        PortNames=cell(0,1);
        for i=1:length(PortHdls.(PortType))
            PortNames{i}=[PortType,num2str(i)];
        end
    end
end