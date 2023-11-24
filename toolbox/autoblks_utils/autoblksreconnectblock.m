function autoblksreconnectblock(BlkHdl,OldConns)


    PortInfo=autoblksgetportinfo(BlkHdl);
    ParentBlkHdl=get_param(BlkHdl,'Parent');

    [InportKeepOld,InportMoveNewIndex,InportRemove,InportCreate]=PortNameIntersect({OldConns.Inports.Name},{PortInfo.Inports.Name});
    [OutportKeepOld,OutportMoveNewIndex,OutportRemove,OutportCreate]=PortNameIntersect({OldConns.Outports.Name},{PortInfo.Outports.Name});
    [OldConns.LConns(:).Side]=deal('Left');
    [OldConns.RConns(:).Side]=deal('Right');

    OldPMIOPorts=[OldConns.LConns;OldConns.RConns];
    [PortInfo.LConns(:).Side]=deal('Left');
    [PortInfo.RConns(:).Side]=deal('Right');
    PMIOPortInfo=[PortInfo.LConns;PortInfo.RConns];
    [PMIOKeepOld,PMIOMoveNewIndex,PMIORemove,PMIOCreate]=PortNameIntersect({OldPMIOPorts.Name},{PMIOPortInfo.Name});

    InportBlkHdls=[OldConns.Inports([OldConns.Inports.isConnPort]==1).ConnBlkHdl];
    if~isempty(InportBlkHdls)
        InportStartNum=min(str2double(get_param(InportBlkHdls,'Port')));
    else
        InportStartNum=-1;
    end

    OutportBlkHdls=[OldConns.Outports([OldConns.Outports.isConnPort]==1).ConnBlkHdl];
    if~isempty(OutportBlkHdls)
        OutportStartNum=min(str2double(get_param(OutportBlkHdls,'Port')));
    else
        OutportStartNum=-1;
    end

    PMIOPortBlkHdls=[OldPMIOPorts([OldPMIOPorts.isConnPort]==1).ConnBlkHdl];
    if~isempty(PMIOPortBlkHdls)
        PMIOPortStartNum=min(str2double(get_param(PMIOPortBlkHdls,'Port')));
    else
        PMIOPortStartNum=-1;
    end



    for i=1:length(InportRemove)
        if OldConns.Inports(InportRemove(i)).isConnPort
            delete_block(OldConns.Inports(InportRemove(i)).ConnBlkHdl);
        end
    end


    for i=1:length(OutportRemove)
        if OldConns.Outports(OutportRemove(i)).isConnPort
            delete_block(OldConns.Outports(OutportRemove(i)).ConnBlkHdl);
        end
    end


    for i=1:length(PMIORemove)
        if OldPMIOPorts(PMIORemove(i)).isConnPort
            delete_block(OldPMIOPorts(PMIORemove(i)).ConnBlkHdl);
        end
    end



    for i=1:length(InportKeepOld)
        PortHdl=PortInfo.Inports(InportMoveNewIndex(i)).Hdl;
        PortPos=get_param(PortHdl,'Position');
        ConnPortHdl=OldConns.Inports(InportKeepOld(i)).ConnPortHdl;

        if OldConns.Inports(InportKeepOld(i)).isConnPort&&get_param(ConnPortHdl,'Line')<0
            set_param(OldConns.Inports(InportKeepOld(i)).ConnBlkHdl,'Position',GetBlkPos(PortPos,'Inport'))
            add_line(ParentBlkHdl,ConnPortHdl,PortHdl)
        else

            LinePoints=OldConns.Inports(InportKeepOld(i)).LinePoints;
            ReplaceLine(ParentBlkHdl,LinePoints,[],PortPos)
        end
    end


    for i=1:length(InportCreate)
        PortHdl=PortInfo.Inports(InportCreate(i)).Hdl;
        PortPos=get_param(PortHdl,'Position');
        InportBlkPos=GetBlkPos(PortPos,'Inport');
        NewPortName=[get_param(BlkHdl,'Parent'),'/',PortInfo.Inports(InportCreate(i)).Name];
        add_block('built-in/Inport',NewPortName,'Position',InportBlkPos)
        PortHandles=get_param(NewPortName,'PortHandles');
        add_line(ParentBlkHdl,PortHandles.Outport(1),PortHdl)
    end



    for i=1:length(OutportKeepOld)
        PortHdl=PortInfo.Outports(OutportMoveNewIndex(i)).Hdl;
        PortPos=get_param(PortHdl,'Position');
        ConnPortHdl=OldConns.Outports(OutportKeepOld(i)).ConnPortHdl;

        if OldConns.Outports(OutportKeepOld(i)).isConnPort&&get_param(ConnPortHdl,'Line')<0
            set_param(OldConns.Outports(OutportKeepOld(i)).ConnBlkHdl,'Position',GetBlkPos(PortPos,'Outport'))
            add_line(ParentBlkHdl,PortHdl,ConnPortHdl)
        else

            LinePoints=OldConns.Outports(OutportKeepOld(i)).LinePoints;
            ReplaceLine(ParentBlkHdl,LinePoints,PortPos,[]);
        end
    end


    for i=1:length(OutportCreate)
        PortHdl=PortInfo.Outports(OutportCreate(i)).Hdl;
        PortPos=get_param(PortHdl,'Position');
        OutportBlkPos=GetBlkPos(PortPos,'Outport');
        NewPortName=[get_param(BlkHdl,'Parent'),'/',PortInfo.Outports(OutportCreate(i)).Name];
        add_block('built-in/Outport',NewPortName,'Position',OutportBlkPos)
        PortHandles=get_param(NewPortName,'PortHandles');
        add_line(ParentBlkHdl,PortHdl,PortHandles.Inport(1))
    end




    for i=1:length(PMIOKeepOld)
        PortHdl=PMIOPortInfo(PMIOMoveNewIndex(i)).Hdl;
        PortPos=get_param(PortHdl,'Position');
        ConnPortHdl=OldPMIOPorts(PMIOKeepOld(i)).ConnPortHdl;
        PortBlkHdl=OldPMIOPorts(PMIOKeepOld(i)).ConnBlkHdl;

        if OldPMIOPorts(PMIOKeepOld(i)).isConnPort
            if strcmp(PMIOPortInfo(PMIOMoveNewIndex(i)).Side,'Left')
                set_param(PortBlkHdl,'Position',GetBlkPos(PortPos,'LConn'))
                set_param(PortBlkHdl,'Orientation','right')
                add_line(ParentBlkHdl,PortHdl,ConnPortHdl)
            else
                set_param(PortBlkHdl,'Position',GetBlkPos(PortPos,'RConn'))
                set_param(PortBlkHdl,'Orientation','left')
                add_line(ParentBlkHdl,PortHdl,ConnPortHdl)
            end

        else

            LinePoints=OldPMIOPorts(PMIOKeepOld(i)).LinePoints;
            if any(LinePoints(1,:)~=PortPos)
                ReplaceLine(ParentBlkHdl,LinePoints,PortPos,[]);
            else
                ReplaceLine(ParentBlkHdl,LinePoints,[],PortPos);
            end
        end
    end


    for i=1:length(PMIOCreate)
        PortHdl=PMIOPortInfo(PMIOCreate(i)).Hdl;
        PortPos=get_param(PortHdl,'Position');
        NewPortName=[get_param(BlkHdl,'Parent'),'/',PMIOPortInfo(PMIOCreate(i)).Name];

        if strcmp(PMIOPortInfo(PMIOCreate(i)).Side,'Left')
            add_block('built-in/PMIOPort',NewPortName,...
            'Position',GetBlkPos(PortPos,'LConn'),'Orientation','right','Side','Left');

        else
            add_block('built-in/PMIOPort',NewPortName,...
            'Position',GetBlkPos(PortPos,'RConn'),'Orientation','left','Side','Right');
        end

        PortHandles=get_param(NewPortName,'PortHandles');
        add_line(ParentBlkHdl,PortHdl,PortHandles.RConn(1))
    end


    NewConn=autoblksgetblockconn(BlkHdl);

    if InportStartNum>0
        SetPortIndex(NewConn.Inports,InportStartNum)
    end
    if OutportStartNum>0
        SetPortIndex(NewConn.Outports,OutportStartNum)
    end
    if PMIOPortStartNum<0
        if~isempty(NewConn.LConns)&&~isempty(NewConn.RConns)
            PMIOConnPort=[NewConn.LConns(NewConn.LConns.isConnPort);NewConn.RConns(NewConn.RConns.isConnPort)];
            PMIOPortStartNum=str2double(get_param(PMIOConnPort(1).ConnBlkHdl,'Port'));
        end

    end
    if PMIOPortStartNum>0
        PMIO2Port.LConns=NewConn.LConns([NewConn.LConns.isConnPort]);
        PMIO2Port.RConns=NewConn.RConns([NewConn.RConns.isConnPort]);
        LenLConns=length(PMIO2Port.LConns);
        LenRConns=length(PMIO2Port.RConns);
        PMIOPortIdx=PMIOPortStartNum;
        for i=1:max(LenLConns,LenRConns)
            if i<=LenLConns
                set_param(PMIO2Port.LConns(i).ConnBlkHdl,'Port',num2str(PMIOPortIdx));
                PMIOPortIdx=PMIOPortIdx+1;
            end
            if i<=LenRConns
                set_param(PMIO2Port.RConns(i).ConnBlkHdl,'Port',num2str(PMIOPortIdx));
                PMIOPortIdx=PMIOPortIdx+1;
            end

        end
        for i=1:length(NewConn.LConns)
            set_param(PMIO2Port.LConns(i).ConnBlkHdl,'Side','Left');
        end
        for i=1:length(PMIO2Port.RConns)
            set_param(PMIO2Port.RConns(i).ConnBlkHdl,'Side','Right');
        end
    end

end


function[KeepOldIndex,MoveNewIndex,RemoveIndex,CreateNewIndex]=PortNameIntersect(OldNames,NewNames)
    if~isempty(OldNames)&&~isempty(NewNames)
        [~,KeepOldIndex,MoveNewIndex]=intersect(OldNames,NewNames);
        [~,RemoveIndex,CreateNewIndex]=setxor(OldNames,NewNames);
    elseif~isempty(OldNames)
        RemoveIndex=1:length(OldNames);
        KeepOldIndex=[];
        MoveNewIndex=[];
        CreateNewIndex=[];
    elseif~isempty(NewNames)
        RemoveIndex=[];
        KeepOldIndex=[];
        MoveNewIndex=[];
        CreateNewIndex=1:length(NewNames);
    else
        RemoveIndex=[];
        KeepOldIndex=[];
        MoveNewIndex=[];
        CreateNewIndex=[];
    end

end


function BlkPos=GetBlkPos(PortPos,PortType)
    PortSize=[30,14];
    PortDist=75;

    switch PortType
    case 'Inport'
        Point1=[PortPos(1)-(PortDist+PortSize(1)),PortPos(2)-PortSize(2)/2];
    case 'Outport'
        Point1=[PortPos(1)+PortDist,PortPos(2)-PortSize(2)/2];
    case 'LConn'
        Point1=[PortPos(1)-(PortDist+PortSize(1)),PortPos(2)-PortSize(2)/2];
    case 'RConn'
        Point1=[PortPos(1)+PortDist,PortPos(2)-PortSize(2)/2];
    end

    BlkPos=[Point1,Point1+PortSize];

end


function SetPortIndex(PortStruct,StartNum)
    PortIdx=StartNum;
    for i=1:length(PortStruct)
        if PortStruct(i).isConnPort
            set_param(PortStruct(i).ConnBlkHdl,'Port',num2str(PortIdx))
            PortIdx=PortIdx+1;
        end
    end
end


function ReplaceLine(Blk,OldLinePoints,StartPoint,EndPoint)

    Dir=2;

    if~isempty(StartPoint)
        if size(OldLinePoints,1)==2
            NewLinePoints=[StartPoint;[OldLinePoints(2,1),StartPoint(Dir)];OldLinePoints(2,:)];
        else
            NewLinePoints=[StartPoint;OldLinePoints(2:end,:)];
            NewLinePoints(2,Dir)=StartPoint(Dir);
        end
    end
    if~isempty(EndPoint)
        if size(OldLinePoints,1)==2
            NewLinePoints=[OldLinePoints(1,:);[OldLinePoints(1,1),EndPoint(Dir)];EndPoint];
        else
            NewLinePoints=[OldLinePoints(1:end-1,:);EndPoint];
            NewLinePoints(end-1,Dir)=EndPoint(Dir);
        end
    end

    add_line(Blk,NewLinePoints)

end
