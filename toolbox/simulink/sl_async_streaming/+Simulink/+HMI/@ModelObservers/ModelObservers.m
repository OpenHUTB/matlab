




classdef ModelObservers


    properties(Dependent=true,Access=public)
        Model;
        Signals;
    end


    methods


        function obj=ModelObservers(top_model)
            try
                if nargin>0
                    obj.Model=top_model;
                end
            catch me
                throwAsCaller(me);
            end
        end


        function this=set.Model(this,val)
            if~ischar(val)
                DAStudio.error('Simulink:HMI:ModelObserversInvalidModelName');
            end
            this.model_=val;
        end
        function val=get.Model(this)
            val=this.model_;
        end


        function this=set.Signals(this,val)
            if~isa(val,'Simulink.HMI.SignalObserver')
                DAStudio.error(...
                'Simulink:HMI:ModelObserversInvalidSignals');
            end
            this.signals_=val;
        end
        function val=get.Signals(this)
            val=this.signals_;
        end


        function[sigs,clients]=getSignalsAndClients(this)


            if isempty(this.signals_)
                sigs=[];
                clients=[];
                return;
            end
            sigs=Simulink.HMI.InstrumentedSignals(this.model_);
            clients=Simulink.HMI.StreamingClients(this.model_);
            for idx=1:length(this.signals_)
                [sig,refMdl]=addInstrumentedSignal(...
                this,sigs,this.signals_(idx));
                client=Simulink.HMI.SignalClient;
                client.UUID=this.signals_(idx).UUID;
                client.SignalInfo=sig;
                client.ReferenceModel=refMdl;
                client.ObserverType=this.signals_(idx).ObserverType;
                client.ObserverParams=this.signals_(idx).ObserverParams;
                client.UpdateRate=this.signals_(idx).UpdateRate;
                add(clients,client);
            end
        end


        function sigs=getAlignedObservers(this)


            [sigs,~]=this.getSignalsAndClients();
        end

    end


    methods(Static)


        function obj=createFromSignalsAndClients(~,clients)


            import Simulink.HMI.SignalObserver;
            if isempty(clients)
                obj=[];
                return;
            end

            obj=Simulink.HMI.ModelObservers(clients.Model);
            len=clients.Count;
            for idx=1:len
                client=get(clients,idx);
                obj.signals_(end+1)=SignalObserver.createFromClient(client);
            end
        end

    end


    methods(Hidden=true)


        function[sig,refMdl]=addInstrumentedSignal(this,sigs,source)

            import Simulink.SimulationData.BlockPath;
            import Simulink.HMI.BlockPathUtils;
            [path,ssid,sub_path]=...
            BlockPathUtils.getPathMetaData(source.blockPath_);
            bpath=Simulink.SimulationData.BlockPath.manglePath(path{end});
            refMdl=BlockPathUtils.createPathFromMetaData(...
            path(1:end-1),ssid(1:end-1),'');
            mdl=BlockPath.getModelNameForPath(bpath);


            if isempty(ssid)
                sid={};
            else
                sid=ssid(end);
            end
            sigPath=BlockPathUtils.createPathFromMetaData(...
            {bpath},sid,sub_path);



            if~strcmp(mdl,this.model_)
                try
                    sigs=get_param(mdl,'InstrumentedSignal');
                catch me %#ok<NASGU>
                    sig=[];
                    return;
                end
                if isempty(sigs)
                    sigs=Simulink.HMI.InstrumentedSignals(mdl);
                end
            end


            sig=this.findInstrumentedSignal(sigs,sigPath,source);
            if~isempty(sig)
                return;
            end


            sig=Simulink.HMI.SignalSpecification;
            sig.BlockPath=sigPath;
            sig.OutputPortIndex=source.OutputPortIndex;
            sig.SignalName_=getSignalNameFromModel(sig);
            sig.SubSysPath_=getScopedPath(source,mdl);
            if source.LoggingInfo.DecimateData
                sig.Decimation_=source.LoggingInfo.Decimation;
            end
            if source.LoggingInfo.LimitDataPoints
                sig.MaxPoints_=source.LoggingInfo.MaxPoints;
            end
            add(sigs,sig);
            if~strcmp(mdl,this.model_)
                set_param(mdl,'InstrumentedSignals',sigs);
            end
        end


        function sig=findInstrumentedSignal(~,sigs,bp,source)

            sig=[];


            expDec=1;
            expMaxPts=0;
            if source.LoggingInfo.DecimateData
                expDec=source.LoggingInfo.Decimation;
            end
            if source.LoggingInfo.LimitDataPoints
                expMaxPts=source.LoggingInfo.MaxPoints;
            end


            len=sigs.Count;
            for idx=1:len
                curSig=get(sigs,idx);
                if curSig.OutputPortIndex==source.OutputPortIndex&&...
                    curSig.Decimation_==expDec&&...
                    curSig.MaxPoints_==expMaxPts&&...
                    isequal(bp,curSig.BlockPath)
                    sig=curSig;
                    return;
                end
            end
        end
    end


    properties(Hidden=true)
        model_='';
        signals_=Simulink.HMI.SignalObserver.empty;
    end
end



