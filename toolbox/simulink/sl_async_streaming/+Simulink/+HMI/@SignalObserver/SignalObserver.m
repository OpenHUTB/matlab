



classdef SignalObserver<Simulink.SimulationData.SignalObserverInfo


    properties(Dependent=true,Access=public)
        ObserverType;
        ObserverParams;
        UpdateRate;
    end


    methods


        function obj=SignalObserver(varargin)
            obj=obj@Simulink.SimulationData.SignalObserverInfo(varargin{:});
            obj.UUID=sdi.Repository.generateUUID();
        end


        function this=set.ObserverType(this,val)
            if~ischar(val)
                DAStudio.error('Simulink:HMI:SignalObsInvalidType');
            end
            this.observerType_=val;
        end

        function val=get.ObserverType(this)
            val=this.observerType_;
        end


        function this=set.ObserverParams(this,val)
            if~isstruct(val)||~isscalar(val)
                DAStudio.error('Simulink:HMI:SignalObsInvalidParams');
            end
            this.observerParams_=val;
        end

        function val=get.ObserverParams(this)
            val=this.observerParams_;
        end


        function this=set.UpdateRate(this,val)
            if~isnumeric(val)||~isscalar(val)||val<1||...
                double(uint32(val))~=double(val)
                DAStudio.error('Simulink:HMI:SignalObsInvalidRate');
            end
            this.updateRate_=uint32(val);
        end

        function val=get.UpdateRate(this)
            val=this.updateRate_;
        end


        function label=getLabel(this)

            label=this.getSignalNameFromPort();
            if isempty(label)
                len=this.blockPath_.getLength();
                blk=this.blockPath_.getBlock(len);
                label=sprintf('%s:%d',...
                get_param(blk,'Name'),...
                this.outputPortIndex_);
            end
        end

    end


    methods(Static)


        function obs=createFromClient(client)


            obs=Simulink.HMI.SignalObserver;
            obs.UUID=client.UUID;
            obs.UpdateRate=client.UpdateRate;
            obs.ObserverType=client.ObserverType;
            obs.ObserverParams=client.ObserverParams;

            sig=client.SignalInfo;
            if~isempty(sig)
                obs.BlockPath=getFullSignalPath(client);
                obs.OutputPortIndex=sig.OutputPortIndex;
                if isempty(sig.SignalName_)
                    obs.signalName_=sig.getSignalNameFromModel();
                else
                    obs.signalName_=sig.SignalName_;
                end
                obs.CachedPortHandle_=sig.CachedBlockHandle_;
                obs.CachedPortIdx_=sig.CachedPortIdx_;
                obs.BindingRule_=sig.BindingRule_;
                if sig.Decimation_~=1
                    obs.LoggingInfo.DecimateData=true;
                    obs.LoggingInfo.Decimation=sig.Decimation_;
                end
                if sig.MaxPoints_
                    obs.LoggingInfo.LimitDataPoints=true;
                    obs.LoggingInfo.MaxPoints=sig.MaxPoints_;
                end
            end
        end

    end


    methods(Hidden=true)


        function sysPath=getScopedPath(this,mdl)


            sysPath=mdl;
            import Simulink.HMI.SignalInterface;
            try
                if SignalInterface.isHMIObserver(this)
                    mdl=this.ObserverParams.ModelName;
                    mi=Simulink.HMI.getModelInterface(mdl);
                    hmiId=this.ObserverParams.HMI_UUID;
                    hmii=mi.HMISuite.getHMIInstance(hmiId);
                    if~isempty(hmii)&&~isempty(hmii.Bindings.Path)
                        sysPath=hmii.Bindings.Path;
                    end
                end
            catch me %#ok<NASGU>



                sysPath=mdl;
            end
        end
    end


    properties(Hidden=true)
        observerType_='';
        observerParams_=struct();
        updateRate_=8;
        UUID;
    end


    properties(Transient=true,Hidden=true)
        CachedPortHandle_;
        CachedPortIdx_;
        BindingRule_='';
    end
end

