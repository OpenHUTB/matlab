classdef autoblksEngFlwBlkClass<handle

    properties(SetAccess=private)
BlkHdl
        BlkMassFracSetupFcn={};
PortHdls
InternalPortConnHdls
        PortObjs autoblksEngFlwPortClass

PortInfo

    end

    properties(SetAccess=public)
MassFracs
MassFracInitCond

        PortNames='-All';
        InternalConnPortNames='-All';
        MassFracReqSrc={};
        MassFracReqSink={};
        MassFracSrc={};
        MassFracSink={};

AirMassFracNames
AirMassFracs
AirO2MassFrac
    end

    methods

        function obj=autoblksEngFlwBlkClass(varargin)

            obj.BlkHdl=varargin{1};
            if nargin>=2
                obj.BlkMassFracSetupFcn=varargin{2};
            end


            obj.PortInfo=containers.Map('KeyType','char','ValueType','any');


            if~isempty(obj.BlkMassFracSetupFcn)
                obj.BlkMassFracSetupFcn(obj.BlkHdl,obj);
            end
            obj.SetupPortInfo;


            obj.MassFracs={};
            obj.MassFracInitCond=[];
        end


        function SetupPortInfo(obj)
            [AllPortNames,AllPortHdls]=GetPortInfo(obj);
            obj.PortNames=cellstr(obj.PortNames);


            if strcmpi(obj.PortNames,'-All')
                obj.PortNames=AllPortNames;
                obj.PortHdls=AllPortHdls;
            elseif~isempty(obj.PortNames)
                [~,IA]=intersect(AllPortNames,obj.PortNames,'stable');
                obj.PortHdls=AllPortNames(IA);
            end


            if strcmpi(obj.InternalConnPortNames,'-All')
                obj.InternalPortConnHdls=obj.PortHdls;
                obj.InternalConnPortNames=cellstr(obj.PortNames);
            elseif~isempty(obj.InternalConnPortNames)
                [~,IA]=intersect(obj.PortNames,obj.InternalConnPortNames,'stable');
                obj.InternalPortConnHdls=obj.PortHdls(IA);
            end


            for i=1:length(obj.PortNames)
                if~obj.PortInfo.isKey(obj.PortNames{i})
                    obj.PortInfo(obj.PortNames{i})={};
                end
                obj.PortObjs(i)=autoblksEngFlwPortClass(obj,obj.PortNames{i},obj.PortInfo(obj.PortNames{i}));
            end
        end


        function PortProp(obj,PortName,varargin)
            if~obj.PortInfo.isKey(PortName)
                obj.PortInfo(PortName)=varargin;
            else
                obj.PortInfo(PortName)=[obj.PortInfo(PortName),varargin];
            end
        end


        function SetBlkMassFracs(obj)
            PortMassFracs={};
            for i=1:length(obj.PortObjs)
                PortMassFracs=[PortMassFracs,obj.PortObjs(i).MassFracs];
            end
            obj.MassFracs=unique(PortMassFracs);

            obj.MassFracInitCond=zeros(length(obj.MassFracs),1);
            SelIdx=strcmp(obj.MassFracs,'AirMassFrac');
            obj.MassFracInitCond(SelIdx)=1;
            for i=1:length(obj.AirMassFracs)
                SelIdx=strcmp(obj.MassFracs,obj.AirMassFracNames{i});
                obj.MassFracInitCond(SelIdx)=obj.AirMassFracs(i);
            end
        end

    end

    methods(Access=private)

        function[AllPortNames,AllPortHdls]=GetPortInfo(obj)
            PortHdlInfo=get_param(obj.BlkHdl,'PortHandles');
            LConnPortNames=cellstr(autoblksgetblkportnames(obj.BlkHdl,PortHdlInfo.LConn,'LConn'));
            RConnPortNames=cellstr(autoblksgetblkportnames(obj.BlkHdl,PortHdlInfo.RConn,'RConn'));
            AllPortNames=[LConnPortNames;RConnPortNames];
            AllPortHdls=[PortHdlInfo.LConn,PortHdlInfo.RConn];
        end

    end

end
