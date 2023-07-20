function PortInfo=autoblksgetportinfo(BlkHdl)






















    if strcmp(get_param(BlkHdl,'Type'),'block_diagram')
        InportBlkHdls=find_system(BlkHdl,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Inport');
        OutportBlkHdls=find_system(BlkHdl,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Outport');
        InportNames=cellstr(get_param(InportBlkHdls,'Name'));
        OutportNames=cellstr(get_param(OutportBlkHdls,'Name'));
        Inports=struct('Name',InportNames,'Hdl',-ones(size(InportNames)),'Position',nan(size(InportNames)));
        Outports=struct('Name',OutportNames,'Hdl',-ones(size(OutportNames)),'Position',nan(size(OutportNames)));
        LConns=struct('Name',{},'Hdl',{},'Position',{});
        RConns=LConns;
    else
        PortHdls=get_param(BlkHdl,'PortHandles');

        InportNames=autoblksgetblkportnames(BlkHdl,PortHdls,'Inport');
        Inports=GetPortTypeInfo(PortHdls,InportNames,'Inport');

        OutportNames=autoblksgetblkportnames(BlkHdl,PortHdls,'Outport');
        Outports=GetPortTypeInfo(PortHdls,OutportNames,'Outport');


        LConnNames=autoblksgetblkportnames(BlkHdl,PortHdls,'LConn');
        LConns=GetPortTypeInfo(PortHdls,LConnNames,'LConn');

        RConnNames=autoblksgetblkportnames(BlkHdl,PortHdls,'RConn');
        RConns=GetPortTypeInfo(PortHdls,RConnNames,'RConn');
    end


    PortInfo.Inports=Inports;
    PortInfo.Outports=Outports;
    PortInfo.LConns=LConns;
    PortInfo.RConns=RConns;
end




function PortStruct=GetPortTypeInfo(PortHdls,PortNames,PortType)
    Hdls=PortHdls.(PortType);
    Positions=get_param(Hdls,'Position');
    PortStruct=struct('Name',PortNames(:),'Hdl',num2cell(Hdls(:)),'Position',Positions);
end
