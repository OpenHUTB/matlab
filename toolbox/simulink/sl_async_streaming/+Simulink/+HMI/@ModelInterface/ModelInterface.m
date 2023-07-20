



classdef ModelInterface<handle


    properties(Dependent=true,Access=public)


        Model;


        SignalInterface;

    end


    methods


        function val=get.Model(this)
            val=this.Model_;
        end


        function val=get.SignalInterface(this)
            val=this.SignalInterface_;
        end

    end


    methods(Hidden=true)


        function obj=ModelInterface(mdl)

            obj.Model_=mdl;
            obj.SignalInterface_=Simulink.HMI.SignalInterface(mdl);
            obj.addListeners();
        end


        function delete(this)

            this.removeListeners();
        end


        function onOpenModel(this)

            this.addListeners();
        end


        function addListeners(this)



            this.removeListeners();


            try
                hBD=get_param(this.Model_,'UDDObject');
            catch me %#ok<NASGU>
                return;
            end


            this.Listeners_=Simulink.listener(...
            hBD,...
            'CloseEvent',...
            @(bd,lo)onModelClose(this,bd,lo));
        end


        function removeListeners(this)

            for idx=1:length(this.Listeners_)
                delete(this.Listeners_(idx));
            end
            this.Listeners_=[];
        end


        function onModelClose(this,~,~)

            mgr=Simulink.HMI.InterfaceMgr.getInterfaceMgr();
            mgr.removeModel(this.Model_);
        end


        function renameModel(this,~,newName)

            this.Model_=newName;
            this.SignalInterface_.renameModel(newName);
        end

    end
    methods(Static=true,Hidden=true)

        function onModelStart(mdl,varargin)

            sdiEngine=Simulink.sdi.Instance.getSetEngine();
            ret=~isempty(sdiEngine)||sdi.Repository.hasBeenCreated();
            if ret||strcmpi(get_param(mdl,'InspectSignalLogs'),'on')
                Simulink.HMI.SignalInterface.onModelStart(mdl,varargin{:});
                eng=Simulink.sdi.Instance.engine();
                Simulink.sdi.internal.registerMetaDataUpdates(eng);
            end
            if bdIsLoaded(mdl)
                modelHandle=get_param(mdl,'Handle');


                if strcmpi(get_param(mdl,'SimulationMode'),'normal')
                    Simulink.HMI.ModelInterface.updateReferenceModels(mdl);
                end


                Simulink.HMI.DashboardBindingStore.onModelStart(modelHandle);


                targetComputer='';
                if nargin>1&&isfield(varargin{1},'TargetComputer')
                    targetComputer=varargin{1}.TargetComputer;
                end
                Simulink.HMI.AsyncQueueObserverAPI.notifyModelStartComplete(mdl,targetComputer);
            end
        end




        function updateReferenceModels(mdl)

            sw=warning('off');
            tmp=onCleanup(@()warning(sw));
            try
                mdls=get_param(mdl,'CompiledModelBlockNormalModeVisibility');
            catch me %#ok<NASGU>
                mdls=[];
            end
            if isempty(mdls)
                return;
            end


            refMdls=fieldnames(mdls);
            for idx=1:length(refMdls)
                modelHandle=get_param(refMdls{idx},'Handle');
                Simulink.HMI.DashboardBindingStore.onModelStart(modelHandle);
            end
        end




        function updateParams(blk)
            modelName=bdroot(blk);
            modelHandle=get_param(modelName,'Handle');
            mgr=Simulink.HMI.InterfaceMgr.getInterfaceMgr();
            webhmi=mgr.getWebHMI(modelHandle);
            if~isempty(webhmi)

                path=blk(length(modelName)+2:end);


                webhmi.updateWidgetsForParameterChange(path);
            end
        end

    end

    properties(Hidden=true)
        Model_;
        SignalInterface_;
        Listeners_=[];
    end

end


