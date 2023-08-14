




classdef SignalSpecification


    properties(Dependent=true,Access=public)

        BlockPath;


        OutputPortIndex;


FrameProcessingMode
    end


    methods


        function obj=SignalSpecification(opts)
            mlock;
            if nargin>0
                for fname=fields(opts).'
                    obj.(fname{1})=opts.(fname{1});
                end
            else
                obj.UUID=sdi.Repository.generateUUID();
            end
        end


        function this=set.BlockPath(this,val)
            if ischar(val)||iscellstr(val)
                val=Simulink.BlockPath(val);
            end
            validateattributes(val,{'Simulink.BlockPath'},{'scalar'});
            import Simulink.HMI.BlockPathUtils;
            [bpath,sid,this.SubPath_]=BlockPathUtils.getPathMetaData(val);
            if isempty(bpath)
                this.BlockPath_='';
            else
                this.BlockPath_=bpath{end};
            end
            if isempty(sid)
                this.SID_='';
            else
                this.SID_=sid{end};
            end
            this.SignalName_=getSignalNameFromModel(this);
        end

        function val=get.BlockPath(this)
            import Simulink.HMI.BlockPathUtils;
            val=BlockPathUtils.createPathFromMetaData(...
            {this.BlockPath_},{this.SID_},this.SubPath_);
        end


        function this=set.OutputPortIndex(this,val)
            validateattributes(val,{'numeric'},{'scalar','integer','>=',0});
            this.OutputPortIndex_=double(val);

            blockHandle=getBlockHandle(this);
            this.LogicalPortIndex_=...
            double(Simulink.sdi.getLogicalPortIndex(blockHandle,val));

            this.SignalName_=getSignalNameFromModel(this);
        end

        function val=get.OutputPortIndex(this)
            if this.LogicalPortIndex_
                blockHandle=getBlockHandle(this);
                if blockHandle
                    val=Simulink.sdi.getGraphicalPortIndexFromLogicalIndex(...
                    blockHandle,this.LogicalPortIndex_);
                    return
                end
            end

            val=this.OutputPortIndex_;
        end


        function this=set.FrameProcessingMode(this,val)
            if isstring(val)&&isscalar(val)
                val=char(val);
            end
            validatestring(val,{'frame','sample'});

            this.IsFrameBased_=double(strcmpi(char(val),'frame'));
        end

        function val=get.FrameProcessingMode(this)
            if this.IsFrameBased_
                val="frame";
            else
                val="sample";
            end
        end


        function this=applyRebindingRules(this)





            this=Simulink.HMI.SignalSpecification.bindSignal(this);
            if strcmp(this.BindingRule_,'not found')
                return
            end



            obj=get_param(this.CachedBlockHandle_,'Object');
            commented=get_param(obj.getFullName,'Commented');
            if strcmp(commented,'on')
                this.BindingRule_='commented';
            elseif strcmp(commented,'through')
                this.BindingRule_='through';
            end



            blockPath=Simulink.BlockPath(obj.getFullName);
            blockPath.SubPath=this.SubPath_;
            this.BlockPath=blockPath;





            if strcmp(this.DomainType_,'sf_state')&&...
                strcmp(this.DomainParams_.Activity,'Self')&&...
                (endsWith(this.SignalName_,':ActiveChild')||...
                endsWith(this.SignalName_,':ActiveLeaf'))
                this.BindingRule_='not bound';
            end
        end


        function bpath=getAlignedBlockPath(this)
            bpath=this.BlockPath_;
            if Simulink.HMI.SignalSpecification.isCachedBlockValid(this)
                blk=get_param(this.CachedBlockHandle_,'Object');
                bpath=Simulink.SimulationData.BlockPath.manglePath(blk.getFullName());
            end
        end


        function sigName=getSignalNameFromModel(this)

            sigName='';



            if Simulink.HMI.SignalSpecification.isSFSignal(this)
                sigName=this.SignalName_;
                return;
            end

            if~isempty(this.SubPath_)
                sigName=this.SubPath_;
                return;
            end


            blk=getAlignedBlockPath(this);
            try
                sw=warning('off','all');
                tmp=onCleanup(@()warning(sw));
                ph=get_param(blk,'PortHandles');
            catch me %#ok<NASGU>
                return;
            end


            if Simulink.HMI.SignalSpecification.isCachedBlockValid(this)
                pIdx=this.CachedPortIdx_;
            else
                pIdx=this.OutputPortIndex;
            end
            if length(ph.Outport)<pIdx||pIdx<1
                return;
            end


            import Simulink.SimulationData.BlockPath;
            if strcmp(get_param(ph.Outport(pIdx),'ShowPropagatedSignals'),'on')
                sigName=get_param(ph.Outport(pIdx),'PropagatedSignals');
            else
                sigName=get_param(ph.Outport(pIdx),'Name');
            end
            sigName=BlockPath.manglePath(sigName);%#ok<PROP>
        end


        function els=getBusElements(this)


            import Simulink.HMI.SignalSpecification;
            els={};
            if~isempty(this.SubPath_)
                return;
            end

            sw=warning('off','all');
            tmp=onCleanup(@()warning(sw));

            ports=get_param(this.BlockPath_,'PortHandles');
            ph=ports.Outport(this.OutputPortIndex);
            sigHier=get_param(ph,'SignalHierarchy');
            if~isempty(sigHier)
                for idx=1:length(sigHier.Children)
                    els=SignalSpecification.addBusElements(...
                    sigHier.SignalName,sigHier.Children(idx),els);
                end
            end
        end


        function bRet=isInstrumented(~)

            bRet=true;
        end


        function hash=getHash(this)
            if~Simulink.HMI.SignalSpecification.isCachedBlockValid(this)
                blkPathAsString='';
                blockPath=this.BlockPath;
                for idx=1:blockPath.getLength()
                    blkPathAsString=strcat(blkPathAsString,blockPath.getBlock(idx));
                end
                hash=[blkPathAsString,'$$',blockPath.SubPath,'$$',int2str(this.OutputPortIndex)];
            else
                hash=[num2str(this.CachedBlockHandle_,64),'$$',int2str(this.CachedPortIdx_)];
            end
        end
    end


    methods(Static)


        function this=bindSignal(this)



            this=Simulink.HMI.SignalSpecification.checkAndApplyPath(...
            this,this.BlockPath_,'blockpath');
            if~Simulink.HMI.SignalSpecification.isCachedBlockValid(this)


                this=Simulink.HMI.SignalSpecification.applySIDBinding(this);
                if~Simulink.HMI.SignalSpecification.isCachedBlockValid(this)


                    this=Simulink.HMI.SignalSpecification.applySignalNameBinding(this);
                    if~Simulink.HMI.SignalSpecification.isCachedBlockValid(this)



                        this.BindingRule_='not found';
                        return
                    end
                end
            end


            if strcmp(this.DomainType_,'sf_state')||...
                strcmp(this.DomainType_,'sf_data')


                this=Simulink.HMI.SignalSpecification.applySFBinding(this);
            end
        end


        function ret=isCachedBlockValid(objOrStruct)
            ret=~isempty(objOrStruct.CachedBlockHandle_)&&objOrStruct.CachedBlockHandle_;
            if ret
                try
                    get_param(objOrStruct.CachedBlockHandle_,'Name');
                catch me %#ok<NASGU>
                    ret=false;
                end
            end
        end


        function ret=isSFSignal(this)
            ret=~isempty(this.DomainType_)&&...
            (strcmp(this.DomainType_,'sf_chart')||...
            strcmp(this.DomainType_,'sf_state')||...
            strcmp(this.DomainType_,'sf_data'));
        end
    end


    methods(Static,Access=private)


        function this=applySIDBinding(this)

            bp=Simulink.HMI.BlockPathUtils.createPathFromMetaData(...
            {this.BlockPath_},{this.SID_},this.SubPath_);
            bp=bp.refreshFromSSIDcache(false);
            if bp.getLength()==1
                this=Simulink.HMI.SignalSpecification.checkAndApplyPath(...
                this,bp.getBlock(1),'sid');
            end
        end


        function this=applySignalNameBinding(this)

            if~isempty(this.SignalName_)
                if isempty(this.SubSysPath_)
                    import Simulink.SimulationData.BlockPath;
                    subSys=BlockPath.getModelNameForPath(this.BlockPath_);
                else
                    subSys=this.this.SubSysPath_;
                end


                ports=find_system(subSys,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FindAll','on',...
                'FollowLinks','on',...
                'Type','port',...
                'Name',this.SignalName_);
                if length(ports)==1
                    bpath=get_param(ports,'Parent');
                    portIdx=get_param(ports,'PortNumber');
                    this=Simulink.HMI.SignalSpecification.checkAndApplyPath(...
                    this,bpath,'name',portIdx);
                end
            end
        end


        function this=applySFBinding(this)

            ssid=strcat(':',this.DomainParams_.SSID);
            obj=sfprivate('ssIdToHandle',ssid,this.CachedBlockHandle_);
            if isempty(obj)


                this.BindingRule_='not found';
                return
            end
            activity=this.DomainParams_.Activity;
            [signalName,subPath]=sfprivate('get_activity_logging_name',obj,activity);
            this.SubPath_=subPath;
            this.SignalName_=signalName;
        end


        function this=checkAndApplyPath(this,blk,rule,portIdx)


            this.CachedBlockHandle_=[];


            try
                hBlk=get_param(blk,'Handle');
            catch me %#ok<NASGU>
                return
            end


            if nargin<4
                if this.LogicalPortIndex_>0
                    portIdx=...
                    double(Simulink.sdi.getGraphicalPortIndexFromLogicalIndex(hBlk,this.LogicalPortIndex_));
                else
                    portIdx=this.OutputPortIndex_;
                end
            end


            if isempty(this.SubPath_)
                ports=get(hBlk,'Ports');
                numPorts=sum(ports(2:end));
                if portIdx>numPorts||~portIdx
                    return;
                end
            end


            if~isempty(this.SubSysPath_)
                rel=Simulink.HMI.BlockPathUtils.getPathRelationship(...
                this.SubSysPath_,blk);
                if~strcmp(rel,'child')
                    return;
                end
            end


            this.CachedBlockHandle_=hBlk;
            this.CachedPortIdx_=portIdx;
            this.BindingRule_=rule;
        end
    end


    methods(Static,Hidden)

        function els=addBusElements(parent,element,els)

            import Simulink.HMI.SignalSpecification;
            sigName=strcat(parent,'.',element.SignalName);
            if isempty(element.Children)
                els{end+1}=sigName;
            else
                for idx=1:length(element.Children)
                    els=SignalSpecification.addBusElements(...
                    sigName,element.Children(idx),els);
                end
            end
        end


        function uuid=setgetPortUUID(portH,newUUID)

            if nargin<2
                newUUID='';
            end
            if isempty(newUUID)
                portUUIDMap=Simulink.HMI.SignalSpecification.setgetPortUUIDMap;

                if isKey(portUUIDMap,portH)
                    uuid=portUUIDMap(portH);
                else

                    uuid='';
                end
            else

                uuid=newUUID;
                Simulink.HMI.SignalSpecification.setgetPortUUIDMap(portH,newUUID);
            end
        end



        function output=setgetPortUUIDMap(portH,newUUID)
            persistent portUUIDMap;
            if isempty(portUUIDMap)
                portUUIDMap=containers.Map('KeyType','double','ValueType','char');
            end
            output=portUUIDMap;
            if nargin>1
                Simulink.HMI.SignalSpecification.updateBidirectionalPortToUUIDMapping(portH,newUUID);
            end
        end



        function output=setgetUUIDPortMap(portH,newUUID)
            persistent uuidPortMap;
            if isempty(uuidPortMap)
                uuidPortMap=containers.Map('KeyType','char','ValueType','double');
            end
            output=uuidPortMap;
            if nargin>1
                Simulink.HMI.SignalSpecification.updateBidirectionalPortToUUIDMapping(portH,newUUID);
            end
        end

        function updateBidirectionalPortToUUIDMapping(newPortH,newUUID)








            uuidPortMap=Simulink.HMI.SignalSpecification.setgetUUIDPortMap;
            portUUIDMap=Simulink.HMI.SignalSpecification.setgetPortUUIDMap;



            if uuidPortMap.isKey(newUUID)
                oldPort=uuidPortMap(newUUID);
                portUUIDMap.remove(oldPort);
                uuidPortMap.remove(newUUID);
            end



            if portUUIDMap.isKey(newPortH)
                oldUUID=portUUIDMap(newPortH);
                portUUIDMap.remove(newPortH);
                uuidPortMap.remove(oldUUID);
            end


            portUUIDMap(newPortH)=newUUID;
            uuidPortMap(newUUID)=newPortH;
        end

    end


    methods(Hidden)

        function this=setPortHandle(this,portH,shouldUpdateProperties)
















            if nargin<3


                shouldUpdateProperties=true;
            end
            if shouldUpdateProperties
                blk=get_param(portH,'Parent');
                portIdx=get_param(portH,'PortNumber');
                this.BlockPath=Simulink.BlockPath(blk);
                this.OutputPortIndex=portIdx;
                this.CachedBlockHandle_=get_param(blk,'Handle');
                this.CachedPortIdx_=portIdx;
            end
            this.PortHandle=portH;
            this=updatePortUUIDMap(this);
        end


        function varargout=updatePortHandle(this)









            try
                blkPath=getAlignedBlockPath(this);
                ports=get_param(blkPath,'PortHandles');
                outports=ports.Outport;
                portH=outports(this.OutputPortIndex);
            catch me %#ok<NASGU>
                if nargout
                    varargout={this};
                end
                return
            end
            this.PortHandle=portH;
            this=updatePortUUIDMap(this);
            if nargout
                varargout={this};
            end
        end


        function this=updatePortUUIDMap(this)




            portH=this.PortHandle;
            blkh=get_param(portH,'ParentHandle');
            portIdx=get_param(portH,'PortNumber');
            if ishandle(portH)

                Simulink.HMI.InstrumentedSignals.setUUIDForBlock(blkh,portIdx,this.UUID);
            end
        end


        function ret=getBlockHandle(this)
            if Simulink.HMI.SignalSpecification.isCachedBlockValid(this)
                ret=this.CachedBlockHandle_;
            else
                try
                    ret=get_param(this.BlockPath_,'Handle');
                catch me %#ok<NASGU>
                    ret=0;
                end
            end
        end
    end


    properties(Hidden=true)
        UUID;
        BlockPath_='';
        SID_='';
        SubPath_='';
        OutputPortIndex_=1;
        LogicalPortIndex_=0;
        SignalName_='';
        SubSysPath_='';
        Decimation_=1;
        MaxPoints_=0;
        TargetBufferedStreaming_=0;
        IsFrameBased_=0;
        HideInSDI_=0;
        DomainType_='';
        VisualType_='';
        DomainParams_=struct();
    end


    properties(Transient=true,Hidden=true)
        CachedBlockHandle_;
        CachedPortIdx_;
        BindingRule_='';
        PortHandle=-1;
        IsBoolean=false;
    end
end

