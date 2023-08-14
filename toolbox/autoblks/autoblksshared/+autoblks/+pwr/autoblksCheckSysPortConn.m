classdef(Hidden)autoblksCheckSysPortConn<handle





    properties(SetAccess=protected,Hidden=true)
        OldSourceOutputPortsMap containers.Map
    end


    methods

        function obj=autoblksCheckSysPortConn
            obj.OldSourceOutputPortsMap=containers.Map('KeyType','double','ValueType','any');
        end


        function flag=isPortConnected(obj,StartPortHdl,EndPortHdl,StartMdlHierarchy,EndMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls)

            if nargin<3
                StartMdlHierarchy={};
            end
            if nargin<4
                EndMdlHierarchy={};
            end
            if nargin<5
                PassThroughBlkTypes={};
            end
            if nargin<6
                StopSearchBlkHdls=[];
            end
            if ischar(PassThroughBlkTypes)
                PassThroughBlkTypes=cellstr(PassThroughBlkTypes);
            end
            flag=false(size(EndPortHdl));


            if length(EndPortHdl)>1
                for i=1:length(EndPortHdl)
                    if iscell(EndMdlHierarchy)&&~isempty(EndMdlHierarchy)
                        NextEndMdlHierarchy=EndMdlHierarchy{i};
                    else
                        NextEndMdlHierarchy=EndMdlHierarchy;
                    end
                    flag(i)=obj.isPortConnected(StartPortHdl,EndPortHdl(i),StartMdlHierarchy,NextEndMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                end
            else
                StartPortType=get_param(StartPortHdl,'PortType');
                EndPortType=get_param(EndPortHdl,'PortType');

                switch StartPortType
                case 'inport'
                    switch EndPortType
                    case 'inport'
                        flag=obj.isInportInportConnected(StartPortHdl,EndPortHdl,StartMdlHierarchy,EndMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    case 'outport'
                        flag=obj.isInportOutportConnected(StartPortHdl,EndPortHdl,StartMdlHierarchy,EndMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    case 'connection'
                        flag=obj.isInportTwoWayConnected(StartPortHdl,EndPortHdl,StartMdlHierarchy,EndMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    end
                case 'outport'
                    switch EndPortType
                    case 'inport'
                        flag=obj.isInportOutportConnected(EndPortHdl,StartPortHdl,EndMdlHierarchy,StartMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    case 'outport'
                        flag=false;
                    case 'connection'
                        flag=obj.isOutportTwoWayConnected(StartPortHdl,EndPortHdl,StartMdlHierarchy,EndMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    end
                case 'connection'
                    switch EndPortType
                    case 'inport'
                        flag=obj.isInportTwoWayConnected(EndPortHdl,StartPortHdl,EndMdlHierarchy,StartMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    case 'outport'
                        flag=obj.isOutportTwoWayConnected(EndPortHdl,StartPortHdl,EndMdlHierarchy,StartMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    case 'connection'
                        flag=obj.isTwoWayTwoWayConnected(StartPortHdl,EndPortHdl,StartMdlHierarchy,EndMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                    end
                end


            end
        end


        function clear(obj)
            obj.OldSourceOutputPortsMap=containers.Map('KeyType','double','ValueType','any');
        end
    end


    methods(Access=private)

        function[flag,OriginOutports]=isInportOutportConnected(obj,InportHdl,OutportHdl,InportMdlHierarchy,OutportMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls,SearchedInportHdls)

            if nargin<8
                SearchedInportHdls=[];
            end
            if ismember(InportHdl,SearchedInportHdls)
                flag=false;
                return;
            end
            AllSourceOutputPorts=obj.getSourceOutputPorts(InportHdl);
            SearchedInportHdls=[SearchedInportHdls;InportHdl];
            OriginOutports=[];
            if ischar(InportMdlHierarchy)
                InportMdlHierarchy=cellstr(InportMdlHierarchy);
            end
            if ischar(InportMdlHierarchy)
                OutportMdlHierarchy=cellstr(OutportMdlHierarchy);
            end

            for i=1:length(AllSourceOutputPorts)

                SourceOutputPorts=AllSourceOutputPorts{i};


                PortIdx=1;
                while PortIdx<=length(SourceOutputPorts)


                    StartParentSystem=get_param(SourceOutputPorts(PortIdx),'Parent');
                    if strcmp(get_param(StartParentSystem,'Type'),'block')
                        if strcmp(get_param(StartParentSystem,'BlockType'),'SubSystem')
                            if strcmp(get_param(StartParentSystem,'Variant'),'on')
                                ActiveVariantPortInfo=autoblksgetportinfo(get_param(get_param(StartParentSystem,'ActiveVariantBlock'),'Handle'));
                                BlkPortInfo=autoblksgetportinfo(get_param(StartParentSystem,'Handle'));
                                [~,IA]=intersect([BlkPortInfo.Outports.Hdl],SourceOutputPorts(PortIdx));
                                BlkPortName=BlkPortInfo.Outports(IA).Name;
                                ActiveVariantPortNames={ActiveVariantPortInfo.Outports.Name};
                                [~,IA]=intersect(ActiveVariantPortNames,BlkPortName);
                                if~isempty(IA)
                                    SourceOutputPorts=[SourceOutputPorts(1:PortIdx-1);ActiveVariantPortInfo.Outports(IA).Hdl;SourceOutputPorts(PortIdx:end)];
                                    PortIdx=PortIdx+1;
                                end
                            end
                        end
                    end


                    if strcmp(get_param(StartParentSystem,'Type'),'block')
                        if strcmp(get_param(StartParentSystem,'BlockType'),'Inport')
                            ParentBlk=get_param(StartParentSystem,'Parent');
                            if strcmp(get_param(ParentBlk,'Type'),'block')
                                ParentBlk2=get_param(ParentBlk,'Parent');
                                if strcmp(get_param(ParentBlk2,'Type'),'block')
                                    if strcmp(get_param(ParentBlk2,'Variant'),'on')
                                        InportName=get_param(StartParentSystem,'Name');
                                        try
                                            InportBlk=get_param([ParentBlk2,'/',InportName],'PortHandles');
                                        catch
                                            InportBlk=[];
                                        end
                                        if~isempty(InportBlk)
                                            SourceOutputPorts=[SourceOutputPorts(1:PortIdx-1);InportBlk.Outport;SourceOutputPorts(PortIdx:end)];
                                            PortIdx=PortIdx+1;
                                        end
                                    end
                                end

                            end
                        end
                    end

                    PortIdx=PortIdx+1;
                end

                SourceOutputPorts=unique(SourceOutputPorts,'stable');

                SourceBlkHdls=get_param(get_param(SourceOutputPorts,'Parent'),'Handle');
                if iscell(SourceBlkHdls)
                    SourceBlkHdls=cell2mat(SourceBlkHdls);
                end
                [~,IA]=intersect(SourceBlkHdls,StopSearchBlkHdls);
                if~isempty(IA)
                    SourceOutputPorts=SourceOutputPorts(max(IA):end);
                end
                if~isempty(SourceOutputPorts)
                    BranchOriginOutports=SourceOutputPorts(1);
                else
                    BranchOriginOutports=[];
                end

                flag=ismember(OutportHdl,SourceOutputPorts);


                if~flag&&~isempty(SourceOutputPorts)
                    StartOutputPort=SourceOutputPorts(1);
                    ParentBlk=get_param(StartOutputPort,'Parent');
                    ParentBlkType=get_param(ParentBlk,'BlockType');
                    ParentBlkHdl=get_param(ParentBlk,'Handle');


                    if ismember(cellstr(ParentBlkType),PassThroughBlkTypes)&&~ismember(ParentBlkHdl,StopSearchBlkHdls)
                        BlkPortHdls=get_param(ParentBlk,'PortHandles');
                        BranchOriginOutports=[];
                        for j=1:length(BlkPortHdls.Inport)
                            [flag,OriginOutportJ]=obj.isInportOutportConnected(BlkPortHdls.Inport(j),OutportHdl,InportMdlHierarchy,OutportMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls,SearchedInportHdls);
                            BranchOriginOutports=[BranchOriginOutports;OriginOutportJ];
                            if flag
                                break;
                            end
                        end
                    end


                    if~flag&&~ismember(ParentBlkHdl,StopSearchBlkHdls)
                        if strcmp('ModelReference',ParentBlkType)
                            InportPortHdl=obj.getChildPortBlkPortHdl(StartOutputPort);
                            NewInportMdlHierarchy=[InportMdlHierarchy(1:end-1),ParentBlk,get_param(InportPortHdl,'Parent')];
                            [flag,BranchOriginOutports]=obj.isInportOutportConnected(InportPortHdl,OutportHdl,NewInportMdlHierarchy,OutportMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls,SearchedInportHdls);
                        elseif strcmp('Inport',ParentBlkType)&&strcmp('block_diagram',get_param(get_param(ParentBlk,'Parent'),'Type'))
                            if length(InportMdlHierarchy)>=2
                                NewInportMdlHierarchy=InportMdlHierarchy{end-1};
                                MdlRefPortHdl=obj.getParentBlkPortHdl(ParentBlkHdl,NewInportMdlHierarchy);
                                [flag,BranchOriginOutports]=obj.isInportOutportConnected(MdlRefPortHdl,OutportHdl,NewInportMdlHierarchy,OutportMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls,SearchedInportHdls);
                            end
                        end
                    end

                end


                OriginOutports=[OriginOutports;BranchOriginOutports];
                if flag
                    break;
                end
            end
        end


        function flag=isInportInportConnected(obj,StartInportHdl,EndInportHdl,StartInportMdlHierarchy,EndInportMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls)

            [~,StartOriginOutports]=obj.isInportOutportConnected(StartInportHdl,-1,StartInportMdlHierarchy,{},PassThroughBlkTypes,StopSearchBlkHdls);
            [~,EndOriginOutports]=obj.isInportOutportConnected(EndInportHdl,-1,EndInportMdlHierarchy,{},PassThroughBlkTypes,StopSearchBlkHdls);


            if~isempty(intersect(StartOriginOutports,EndOriginOutports))
                flag=true;
            else
                flag=false;
            end

        end


        function flag=isInportTwoWayConnected(obj,InportHdl,TwoWayHdl,InportMdlHierarchy,TwoWayMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls)


            [~,LastTwoWayPortHdl]=obj.isTwoWayTwoWayConnected(TwoWayHdl,-1,TwoWayMdlHierarchy,{},PassThroughBlkTypes,StopSearchBlkHdls);
            ParentBlk=get_param(LastTwoWayPortHdl,'Parent');
            if strcmp(get_param(ParentBlk,'BlockType'),'TwoWayConnection')
                ph=get_param(ParentBlk,'PortHandles');
                OutportHdl=ph.Outport;
            else
                OutportHdl=-1;
            end


            if ishandle(OutportHdl)
                flag=obj.isInportOutportConnected(InportHdl,OutportHdl,InportMdlHierarchy,TwoWayMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
            else
                flag=false;
            end

        end


        function flag=isOutportTwoWayConnected(obj,OutportHdl,TwoWayHdl,OutportMdlHierarchy,TwoWayMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls)


            [~,LastTwoWayPortHdl]=obj.isTwoWayTwoWayConnected(TwoWayHdl,-1,TwoWayMdlHierarchy,{},PassThroughBlkTypes,StopSearchBlkHdls);
            ParentBlk=get_param(LastTwoWayPortHdl,'Parent');
            if strcmp(get_param(ParentBlk,'BlockType'),'TwoWayConnection')
                ph=get_param(ParentBlk,'PortHandles');
                InportHdl=ph.Inport;
            else
                InportHdl=-1;
            end


            if ishandle(InportHdl)
                flag=obj.isInportOutportConnected(InportHdl,OutportHdl,TwoWayMdlHierarchy,OutportMdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
            else
                flag=false;
            end

        end


        function[flag,LastTwoWayPortHdl]=isTwoWayTwoWayConnected(obj,StartTwoWayHdl,EndTwoWayHdl,TwoWay1MdlHierarchy,TwoWay2MdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls)

            StartParentSystem=get_param(StartTwoWayHdl,'Parent');
            VariantPortBlkPortHdl=-1;
            if strcmp(get_param(StartParentSystem,'Type'),'block')
                if strcmp(get_param(StartParentSystem,'BlockType'),'SubSystem')
                    ParentBlk=get_param(StartParentSystem,'Parent');
                    if strcmp(get_param(StartParentSystem,'Variant'),'on')
                        ActiveVariantPortInfo=autoblksgetportinfo(get_param(get_param(StartParentSystem,'ActiveVariantBlock'),'Handle'));
                        BlkPortInfo=autoblksgetportinfo(get_param(StartParentSystem,'Handle'));

                        [~,IA]=intersect([BlkPortInfo.LConns.Hdl,BlkPortInfo.RConns.Hdl],StartTwoWayHdl);
                        BlkPortName={BlkPortInfo.LConns.Name,BlkPortInfo.RConns.Name};
                        BlkPortName=BlkPortName{IA};
                        ActiveVariantPortNames={ActiveVariantPortInfo.LConns.Name,ActiveVariantPortInfo.RConns.Name};
                        [~,IA]=intersect(ActiveVariantPortNames,BlkPortName);
                        if~isempty(IA)
                            ActiveVariantPortHdls=[ActiveVariantPortInfo.LConns.Hdl,ActiveVariantPortInfo.RConns.Hdl];
                            StartTwoWayHdl=ActiveVariantPortHdls(IA);
                            VariantPortNames={BlkPortInfo.LConns.Name,BlkPortInfo.RConns.Name};
                            VariantPortBlk=[StartParentSystem,'/',VariantPortNames{IA}];
                            VariantPortHdls=get_param(VariantPortBlk,'PortHandles');
                            VariantPortBlkPortHdl=VariantPortHdls.RConn(1);
                        end
                    elseif strcmp(get_param(ParentBlk,'Type'),'block')
                        if strcmp(get_param(ParentBlk,'BlockType'),'SubSystem')
                            if strcmp(get_param(ParentBlk,'Variant'),'on')
                                VariantPortInfo=autoblksgetportinfo(get_param(ParentBlk,'Handle'));
                                BlkPortInfo=autoblksgetportinfo(get_param(StartParentSystem,'Handle'));
                                [~,IA]=intersect([BlkPortInfo.LConns.Hdl,BlkPortInfo.RConns.Hdl],StartTwoWayHdl);
                                VariantPortNames={VariantPortInfo.LConns.Name,VariantPortInfo.RConns.Name};
                                BlkPortName={BlkPortInfo.LConns.Name,BlkPortInfo.RConns.Name};
                                BlkPortName=BlkPortName{IA};
                                [~,IA]=intersect(VariantPortNames,BlkPortName);
                                if~isempty(IA)
                                    VariantPortHdls=[VariantPortInfo.LConns.Hdl,VariantPortInfo.RConns.Hdl];
                                    StartTwoWayHdl=VariantPortHdls(IA);
                                    VariantPortNames={VariantPortInfo.LConns.Name,VariantPortInfo.RConns.Name};
                                    VariantPortBlk=[ParentBlk,'/',VariantPortNames{IA}];
                                    VariantPortHdls=get_param(VariantPortBlk,'PortHandles');
                                    VariantPortBlkPortHdl=VariantPortHdls.RConn(1);
                                end
                            end
                        end
                    end
                elseif strcmp(get_param(StartParentSystem,'BlockType'),'PMIOPort')
                    ParentBlk=get_param(StartParentSystem,'Parent');
                    if strcmp(get_param(ParentBlk,'Type'),'block')
                        if strcmp(get_param(ParentBlk,'BlockType'),'SubSystem')
                            if strcmp(get_param(ParentBlk,'Variant'),'on')
                                ActiveVariantBlk=get_param(ParentBlk,'ActiveVariantBlock');
                                ActiveVariantPortInfo=autoblksgetportinfo(get_param(ActiveVariantBlk,'Handle'));
                                PortBlkName=get_param(StartParentSystem,'Name');
                                ActiveVariantPortNames={ActiveVariantPortInfo.LConns.Name,ActiveVariantPortInfo.RConns.Name};
                                [~,IA]=intersect(ActiveVariantPortNames,PortBlkName);
                                if~isempty(IA)
                                    ActiveVariantPortHdls=[ActiveVariantPortInfo.LConns.Hdl,ActiveVariantPortInfo.RConns.Hdl];
                                    VariantPortBlkPortHdl=ActiveVariantPortHdls(IA);
                                    VariantPortBlk=[ActiveVariantBlk,'/',ActiveVariantPortNames{IA}];
                                    VariantPortHdls=get_param(VariantPortBlk,'PortHandles');
                                    StartTwoWayHdl=VariantPortHdls.RConn(1);
                                end
                            end
                        end
                    end


                end
            end


            LineHdl=obj.getLineHdl(StartTwoWayHdl);
            if ishandle(LineHdl)
                LastTwoWayPortHdl=setxor([get_param(LineHdl,'SrcPortHandle'),get_param(LineHdl,'DstPortHandle')],StartTwoWayHdl);
                LineConnected=true;
            else
                LastTwoWayPortHdl=StartTwoWayHdl;
                LineConnected=false;
            end


            if isequal(EndTwoWayHdl,LastTwoWayPortHdl)&&ishandle(LastTwoWayPortHdl)
                flag=true;
            elseif isequal(VariantPortBlkPortHdl,EndTwoWayHdl)&&ishandle(VariantPortBlkPortHdl)
                flag=true;
            else
                flag=false;
            end


            if~flag&&LineConnected
                ConnBlk=get_param(LastTwoWayPortHdl,'Parent');
                ConnBlkType=get_param(ConnBlk,'BlockType');
                ConnBlkHdl=get_param(ConnBlk,'Handle');

                if~ismember(ConnBlkHdl,StopSearchBlkHdls)
                    switch ConnBlkType
                    case 'SubSystem'
                        StartPMIOPortHdls=obj.getChildPortBlkPortHdl(LastTwoWayPortHdl);

                    case 'PMIOPort'
                        StartPMIOPortHdls=obj.getParentBlkPortHdl(ConnBlkHdl,get_param(ConnBlkHdl,'Parent'));

                    otherwise
                        StartPMIOPortHdls=[];
                    end
                    for i=1:length(StartPMIOPortHdls)
                        [flag,LastTwoWayPortHdl]=obj.isTwoWayTwoWayConnected(StartPMIOPortHdls(i),EndTwoWayHdl,TwoWay1MdlHierarchy,TwoWay2MdlHierarchy,PassThroughBlkTypes,StopSearchBlkHdls);
                        if flag
                            break
                        end
                    end

                end
            end

        end


        function SourceOutputPorts=getSourceOutputPorts(obj,InportHdl)


            if obj.OldSourceOutputPortsMap.isKey(InportHdl)

                SourceOutputPorts=obj.OldSourceOutputPortsMap(InportHdl);
            else

                LineHdl=obj.getLineHdl(InportHdl);
                SourceOutputPorts=[];


                if ishandle(LineHdl)
                    SourceOutputPorts=get_param(LineHdl,'SourceOutputPorts');


                    idxFindBus=length(SourceOutputPorts)-1;
                    SignalHierarchyChange=false;
                    CurrSignalHierarchy=get_param(SourceOutputPorts(end),'SignalHierarchy');
                    if~isempty(CurrSignalHierarchy)
                        if~isempty(CurrSignalHierarchy.Children)
                            while~SignalHierarchyChange&&idxFindBus>1
                                NextSignalHierarchy=get_param(SourceOutputPorts(idxFindBus),'SignalHierarchy');
                                idxFindBus=idxFindBus-1;
                                CurrSignalHierarchy=NextSignalHierarchy;
                                if isempty(NextSignalHierarchy)
                                    SignalHierarchyChange=true;
                                else
                                    if~isequal(CurrSignalHierarchy.Children,NextSignalHierarchy.Children)
                                        SignalHierarchyChange=true;
                                    end
                                end
                            end
                            idxFindBus=idxFindBus+2;
                        end
                    end


                    if SignalHierarchyChange
                        BusBlk=get_param(SourceOutputPorts(idxFindBus),'Parent');
                        ph=get_param(BusBlk,'PortHandles');
                        BusInports=ph.Inport;
                        BusInportSrc=zeros(size(BusInports));
                        for i=1:length(BusInportSrc)
                            BusInportSrc(i)=get_param(get_param(BusInports(i),'Line'),'SrcPortHandle');
                        end
                        [~,IA]=intersect(BusInportSrc,SourceOutputPorts);
                        BusInports=BusInports(IA);


                        StartOutputPorts=SourceOutputPorts(idxFindBus:end);
                        SourceOutputPorts=cell(size(BusInports));
                        idxOutputPorts=1;
                        for i=1:length(BusInports)
                            BusSourceOutputPorts=obj.getSourceOutputPorts(BusInports(i));
                            for j=1:length(BusSourceOutputPorts)
                                SourceOutputPorts{idxOutputPorts}=[BusSourceOutputPorts{j};StartOutputPorts];
                                idxOutputPorts=idxOutputPorts+1;
                            end
                        end
                    end

                else
                    StartParentSystem=get_param(InportHdl,'Parent');
                    if strcmp(get_param(StartParentSystem,'Type'),'block')
                        if strcmp(get_param(StartParentSystem,'BlockType'),'Outport')
                            ParentBlk=get_param(StartParentSystem,'Parent');
                            if strcmp(get_param(ParentBlk,'Type'),'block')
                                if strcmp(get_param(ParentBlk,'Variant'),'on')
                                    ActiveVariantBlk=get_param(ParentBlk,'ActiveVariantBlock');
                                    ActiveVariantPortInfo=autoblksgetportinfo(get_param(ActiveVariantBlk,'Handle'));
                                    PortBlkName=get_param(StartParentSystem,'Name');
                                    ActiveVariantPortNames={ActiveVariantPortInfo.Outports.Name};
                                    [~,IA]=intersect(ActiveVariantPortNames,PortBlkName);
                                    if~isempty(IA)
                                        ActiveVariantPortHdls=[ActiveVariantPortInfo.Outports.Hdl];

                                        VariantPortBlk=[ActiveVariantBlk,'/',ActiveVariantPortNames{IA}];
                                        VariantPortHdls=get_param(VariantPortBlk,'PortHandles');
                                        InportHdl=VariantPortHdls.Inport(1);
                                        SourceOutputPorts=getSourceOutputPorts(obj,InportHdl);
                                        for i=1:length(SourceOutputPorts)
                                            SourceOutputPorts{i}=[SourceOutputPorts{i};ActiveVariantPortHdls(IA)];
                                        end
                                    end
                                end
                            end
                        end
                    end
                end


                if~iscell(SourceOutputPorts)
                    SourceOutputPorts={SourceOutputPorts};
                end


                obj.OldSourceOutputPortsMap(InportHdl)=SourceOutputPorts;
            end

        end



        function PortHdl=getChildPortBlkPortHdl(obj,ParentPortHdl)
            Blk=get_param(ParentPortHdl,'Parent');
            BlkHdl=get_param(Blk,'Handle');
            BlkType=get_param(BlkHdl,'BlockType');

            if strcmpi(BlkType,'Subsystem')||strcmpi(BlkType,'ModelReference')
                PortInfo=autoblksgetportinfo(BlkHdl);
                AllParentBlkPortNames={PortInfo.Inports.Name,PortInfo.Outports.Name,PortInfo.LConns.Name,PortInfo.RConns.Name};
                AllParentBlkPortHdls=[PortInfo.Inports.Hdl,PortInfo.Outports.Hdl,PortInfo.LConns.Hdl,PortInfo.RConns.Hdl];
                [~,IA]=intersect(AllParentBlkPortHdls,ParentPortHdl);
                if strcmpi(BlkType,'Subsystem')
                    ConnPortName=[Blk,'/',AllParentBlkPortNames{IA}];
                else
                    ConnPortName=[get_param(Blk,'ModelName'),'/',AllParentBlkPortNames{IA}];
                end
                ChildBlkPortHdl=get_param(ConnPortName,'PortHandles');
                PortHdl=[ChildBlkPortHdl.Inport,ChildBlkPortHdl.Outport,ChildBlkPortHdl.RConn];
            else
                PortHdl=[];
            end

        end



        function PortHdl=getParentBlkPortHdl(obj,ChildPortBlkHdl,ParentBlk)
            PortBlkName=get_param(ChildPortBlkHdl,'Name');
            PortInfo=autoblksgetportinfo(get_param(ParentBlk,'Handle'));
            AllParentBlkPortNames={PortInfo.Inports.Name,PortInfo.Outports.Name,PortInfo.LConns.Name,PortInfo.RConns.Name};
            AllParentBlkPortHdls=[PortInfo.Inports.Hdl,PortInfo.Outports.Hdl,PortInfo.LConns.Hdl,PortInfo.RConns.Hdl];
            [~,IA]=intersect(AllParentBlkPortNames,PortBlkName);

            PortHdl=AllParentBlkPortHdls(IA);
        end


        function LineHdl=getLineHdl(obj,StartPortHdl)

            LineHdl=get_param(StartPortHdl,'Line');


            if~ishandle(LineHdl)
                ParentSystem=get_param(get_param(StartPortHdl,'Parent'),'Parent');
                PortType=get_param(StartPortHdl,'PortType');
                if strcmp(get_param(ParentSystem,'Type'),'block')
                    if strcmp(get_param(ParentSystem,'BlockType'),'SubSystem')
                        if strcmp(get_param(ParentSystem,'Variant'),'on')
                            BlkPortInfo=autoblksgetportinfo(get_param(get_param(StartPortHdl,'Parent'),'Handle'));
                            VariantPortInfo=autoblksgetportinfo(get_param(ParentSystem,'Handle'));
                            switch PortType
                            case 'inport'
                                [~,IA]=intersect([BlkPortInfo.Inports.Hdl],StartPortHdl);
                                BlkPortName=BlkPortInfo.Inports(IA).Name;
                                VariantPortNames={VariantPortInfo.Inports.Name};
                                [~,IA]=intersect(VariantPortNames,BlkPortName);
                                if~isempty(IA)
                                    LineHdl=get_param(VariantPortInfo.Inports(IA).Hdl,'Line');
                                end
                            case 'outport'
                                [~,IA]=intersect([BlkPortInfo.Outports.Hdl],StartPortHdl);
                                BlkPortName=BlkPortInfo.Outports(IA).Name;
                                VariantPortNames={VariantPortInfo.Outports.Name};
                                [~,IA]=intersect(VariantPortNames,BlkPortName);
                                if~isempty(IA)
                                    LineHdl=get_param(VariantPortInfo.Outports(IA).Hdl,'Line');
                                end
                            end
                        end
                    end
                end
            end

        end
    end
end