classdef autoblksEngFlwSystemClass<handle




    properties(SetAccess=private)
        SystemHdl;
RefBlkInfo
AllMassFracs
        AirMassFracNames={'O2MassFrac','N2MassFrac','H2OMassFrac'};
        AirMassFracs=[0.233;0.767;0];
        AirObj autoblksGasMixture;
        AllBlksSetup=false;
        BlkCompletedMap containers.Map;
        BlkObj containers.Map;
FlwBlks
MassFracBusBlks

        TurnOnMassFracTracking=true;
    end

    methods

        function obj=autoblksEngFlwSystemClass(SystemHandle)
            obj.RefBlkInfo={'autolibfundflw/Control Volume System',{};...
            'autolibfundflw/Flow Restriction',{};...
            'autolibfundflw/Heat Exchanger',{};...
            'autolibfundflw/Flow Boundary',@(Block,BlkObj)autoblksfundflwfb(Block,'MassFracSetup',BlkObj);...
            'autolibcoreeng/SI Core Engine',@(Block,BlkObj)autoblkssicoreengine(Block,'MassFracSetup',BlkObj);...
            'autolibcoreeng/CI Core Engine',@(Block,BlkObj)autoblkscicoreengine(Block,'MassFracSetup',BlkObj);...
            'autolibboost/Compressor',{};...
            'autolibboost/Turbine',{}};
            obj.SystemHdl=SystemHandle;
            obj.AllBlksSetup=false;
            obj.BlkCompletedMap=containers.Map('KeyType','double','ValueType','logical');
            obj.BlkObj=containers.Map('KeyType','double','ValueType','any');
            obj.AllMassFracs=GetBusInfo(SystemHandle);
            obj.AirObj=autoblksGasMixture('AirMassFrac',obj.AirMassFracNames,obj.AirMassFracs);

            SetupBlockMassFractions(obj);
        end


        function MassFracInfo=GetMassFracInfo(obj,BlkHdl)
            if obj.isFlwBlkChanged
                obj.SetupBlockMassFractions;
            end

            if obj.BlkObj.isKey(BlkHdl)
                obj.BlkCompletedMap(BlkHdl)=true;
                MassFracInfo=obj.BlkObj(BlkHdl);
            else
                MassFracInfo={};
            end


            if all(cell2mat(obj.BlkCompletedMap.values))&&~obj.AllBlksSetup
                obj.AllBlksSetup=true;
            end
        end


        function AllMassFracs=GetAllMassFracs(obj,~)
            if obj.isFlwBlkChanged
                obj.SetupBlockMassFractions;
            end
            AllMassFracs=obj.AllMassFracs;
        end


        function Flag=isFlwBlkChanged(obj)
            CurrMassFracBusBlks=obj.findMassFracBusBlks;
            Flag=~isequal(obj.MassFracBusBlks,CurrMassFracBusBlks)|...
            ~all(ishandle(obj.FlwBlks));

        end


        function BlkHdls=findMassFracBusBlks(obj)
            BlkHdls=find_system(obj.SystemHdl,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all','FollowLinks','on','ReferenceBlock','autolibfundflwcommon/Mass Fraction Bus');
        end


        function SetupBlockMassFractions(obj)

            obj.FlwBlks=[];
            obj.BlkObj=containers.Map('KeyType','double','ValueType','any');
            obj.BlkCompletedMap=containers.Map('KeyType','double','ValueType','logical');


            for i=1:size(obj.RefBlkInfo,1)


                NewBlks=find_system(obj.SystemHdl,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','FollowLinks','on','ReferenceBlock',obj.RefBlkInfo{i,1});
                obj.FlwBlks=[obj.FlwBlks;NewBlks];
                for j=1:length(NewBlks)
                    obj.BlkObj(NewBlks(j))=autoblksEngFlwBlkClass(NewBlks(j),obj.RefBlkInfo{i,2});
                end
            end

            obj.MassFracBusBlks=obj.findMassFracBusBlks;


            for i=1:length(obj.FlwBlks)
                if~obj.BlkCompletedMap.isKey(obj.FlwBlks(i))
                    obj.BlkCompletedMap(obj.FlwBlks(i))=false;
                end
            end


            EngFlwBlkObjs=obj.BlkObj.values;
            NetworkBlks=zeros(size(EngFlwBlkObjs));
            PortHdls=cell(size(NetworkBlks));
            InternalPortConnHdls=PortHdls;
            for i=1:length(NetworkBlks)
                NetworkBlks(i)=EngFlwBlkObjs{i}.BlkHdl;
                PortHdls{i}=EngFlwBlkObjs{i}.PortHdls;
                InternalPortConnHdls{i}=EngFlwBlkObjs{i}.InternalPortConnHdls;
            end
            BlkNetwork=autolibfind2wayportwnetwork(NetworkBlks,PortHdls,InternalPortConnHdls);

            if~isempty(EngFlwBlkObjs)
                PortObjs=EngFlwBlkObjs{1}.PortObjs;

                for i=2:length(EngFlwBlkObjs)
                    PortObjs=[PortObjs,EngFlwBlkObjs{i}.PortObjs];
                end
                PortObjMap=containers.Map({PortObjs.PortHdl},num2cell(PortObjs));

                PortNetwork=cell(size(BlkNetwork));
                for i=1:length(PortNetwork)
                    PortNetwork{i}(1)=PortObjMap(BlkNetwork(i).AllPorts(1));
                    for j=2:length(BlkNetwork(i).AllPorts)
                        PortNetwork{i}(j)=PortObjMap(BlkNetwork(i).AllPorts(j));
                    end
                end


                for i=1:length(PortNetwork)
                    SetPortMassFracs(PortNetwork{i},obj.TurnOnMassFracTracking);
                end


                for i=1:length(obj.FlwBlks)
                    TempObj=obj.BlkObj(obj.FlwBlks(i));
                    TempObj.AirMassFracs=obj.AirMassFracs;
                    TempObj.AirMassFracNames=obj.AirMassFracNames;
                    TempObj.AirO2MassFrac=obj.AirMassFracs(strcmp(obj.AirMassFracNames,'O2MassFrac'));
                    TempObj.SetBlkMassFracs;
                end
            end
        end
    end
end


function SetPortMassFracs(NetworkPortObjs,TurnOnMassFracTracking)


    RequiredMassFracs={};
    for i=1:length(NetworkPortObjs)
        RequiredMassFracs=[RequiredMassFracs,NetworkPortObjs(i).MassFracReqSrc,...
        NetworkPortObjs(i).MassFracReqSink,...
        NetworkPortObjs(i).ParentBlkObj.MassFracReqSrc,...
        NetworkPortObjs(i).ParentBlkObj.MassFracReqSink];
    end


    SrcMassFracs={};
    for i=1:length(NetworkPortObjs)
        SrcMassFracs=[SrcMassFracs,NetworkPortObjs(i).MassFracSrc,...
        NetworkPortObjs(i).ParentBlkObj.MassFracSrc];
    end


    SinkMassFracs={};
    for i=1:length(NetworkPortObjs)
        SinkMassFracs=[SinkMassFracs,NetworkPortObjs(i).MassFracSink,...
        NetworkPortObjs(i).ParentBlkObj.MassFracSink];
    end


    OptionalMassFracs=intersect(SrcMassFracs,SinkMassFracs);
    NetworkMassFracs=cellstr(unique([RequiredMassFracs,OptionalMassFracs]));


    if any(strcmp(NetworkMassFracs,'O2MassFrac'))
        NetworkMassFracs=setxor(NetworkMassFracs,'AirMassFrac','stable');
        NetworkMassFracs=setxor(NetworkMassFracs,'BrndGasMassFrac','stable');
        NetworkMassFracs=unique([NetworkMassFracs,{'N2MassFrac','H2OMassFrac','COMassFrac','CO2MassFrac'}],'stable');
    end


    if any(strcmp(NetworkMassFracs,'NOMassFrac'))||any(strcmp(NetworkMassFracs,'NO2MassFrac'))
        NetworkMassFracs=setxor(NetworkMassFracs,'NOxMassFrac','stable');
        NetworkMassFracs=unique([NetworkMassFracs,{'N02MassFrac','NOMassFrac'}],'stable');
    end


    if isempty(NetworkMassFracs)||~TurnOnMassFracTracking
        NetworkMassFracs={'None'};
    end


    for i=1:length(NetworkPortObjs)
        NetworkPortObjs(i).SetMassFracs(NetworkMassFracs);
    end
end


function AllMassFracs=GetBusInfo(System)


    System=get_param(System,'handle');
    BusBlks=find_system(System,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','ReferenceBlock','autolibfundflwcommon/Mass Fraction Bus');
    BusBlk=find_system(BusBlks(1),'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','Name','Bus Creator');
    AllMassFracs=get_param(BusBlk,'InputSignalNames');
end
