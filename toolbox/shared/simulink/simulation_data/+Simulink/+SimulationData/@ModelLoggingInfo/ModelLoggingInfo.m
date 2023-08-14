





























classdef ModelLoggingInfo


    properties(Dependent=true,Access=public)


        Model;













        LoggingMode;












        LogAsSpecifiedByModels;



        Signals;

        isLoadingModel;
        isSavingModel;
    end


    properties(Dependent=true,Hidden=true)
        OverrideMode;
    end


    methods

        function this=ModelLoggingInfo(modelName)


            if nargin==0
                this.model_='';
            else
                this.Model=modelName;
            end


            this.signals_=...
            Simulink.SimulationData.SignalLoggingInfo.empty;


            this.OverrideMode=...
            Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings;



            this.logAsSpecifiedByModels_={};
            this.logAsSpecifiedByModelsSSIDs_={};

        end


        function this=set.Model(this,val)

            if isstring(val)
                val=char(val);
            end


            if~ischar(val)
                DAStudio.error(...
                'Simulink:Logging:MdlLogInfoInvalidModelName');
            end


            this.model_=val;
        end

        function val=get.Model(this)
            val=this.model_;
        end


        function this=set.Signals(this,val)


            if(~isempty(val)&&...
                ~isa(val,'Simulink.SimulationData.SignalLoggingInfo'))

                DAStudio.error(...
                'Simulink:Logging:MdlLogInfoInvalidSignals');
            end

            this=this.setSignals_(val);
        end

        function val=get.Signals(this)
            val=this.signals_;




            if isempty(val)
                val=...
                Simulink.SimulationData.SignalLoggingInfo.empty;
            end

        end


        function this=set.isSavingModel(this,val)
            if val
                opts=Simulink.internal.BDSaveOptions(bdroot);
                if~opts.isOPC
                    return;
                end
                if opts.isExportingToReleaseOrOlder('R2016a')

                    return;
                end


                this=this.updateModelName('$bdroot',true);
            else


                this=this.updateModelName(bdroot,true);
            end
        end


        function this=set.isLoadingModel(this,val)
            if~val


                this=this.updateModelName(bdroot,true);
            end
        end


        function this=set.LoggingMode(this,val)


            if ischar(val)&&strcmpi(val,'LogAllAsSpecifiedInModel')
                val=Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel;
            elseif ischar(val)&&strcmpi(val,'OverrideSignals')
                val=Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings;
            else
                DAStudio.error(...
                'Simulink:Logging:MdlLogInfoInvalidLoggingMode');
            end

            this.OverrideMode=val;
        end

        function val=get.LoggingMode(this)
            if this.overrideMode_==Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel
                val='LogAllAsSpecifiedInModel';
            else
                val='OverrideSignals';
            end
        end


        function this=set.OverrideMode(this,val)


            if ischar(val)
                if strcmpi(val,'LogAsSpecifiedInModel')
                    val=Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel;
                elseif strcmpi(val,'OverrideAll')
                    val=Simulink.SimulationData.LoggingOverrideMode.OverrideAll;
                elseif strcmpi(val,'UseLocalSettings')
                    val=Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings;
                else
                    DAStudio.error(...
                    'Simulink:Logging:MdlLogInfoInvalidOverrideMode');
                end
            end


            if~isscalar(val)||...
                ~isa(val,'Simulink.SimulationData.LoggingOverrideMode')
                DAStudio.error(...
                'Simulink:Logging:MdlLogInfoInvalidOverrideMode');
            end


            this.overrideMode_=uint32(val);

        end

        function val=get.OverrideMode(this)
            val=Simulink.SimulationData.LoggingOverrideMode(this.overrideMode_);
        end


        function this=set.LogAsSpecifiedByModels(this,val)


            if~iscellstr(val)
                DAStudio.error(...
                'Simulink:Logging:MdlLogInfoInvalidLogAsSpecified');
            end

            if~isempty(val)&&~isrow(val)
                val=reshape(val,1,numel(val));

                DAStudio.warning(...
                'Simulink:Logging:MdlLogInfoLogAsSpecifiedMustBeRowVec');
            end

            this.logAsSpecifiedByModels_=...
            Simulink.SimulationData.BlockPath.manglePath(val);




            this=this.cacheSSIDs(...
            false,...
            true);

        end

        function val=get.LogAsSpecifiedByModels(this)
            val=this.logAsSpecifiedByModels_;
        end


        idxs=findSignal(this,bpath,portIdx)


        this=verifySignalAndModelPaths(this,action)


        this=setLogAsSpecifiedInModel(this,mdlOrMdlBlk,bVal)


        bRet=getLogAsSpecifiedInModel(this,mdlOrMdlBlk,bRefreshPaths)

    end


    methods(Static=true)


        obj=createFromModel(model,varargin)
    end


    methods(Hidden=true,Static=true)


        function obj=createDefaultForNewModel(model)




            obj=Simulink.SimulationData.ModelLoggingInfo(model);
            obj.OverrideMode=...
            Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel;
            obj.logAsSpecifiedByModels_={model};
            obj.logAsSpecifiedByModelsSSIDs_={[]};

        end


        function obj=createDefaultForLegacyModel(model)






            obj=Simulink.SimulationData.ModelLoggingInfo(model);
            obj.OverrideMode=...
            Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings;
            obj=obj.setLogAsSpecifiedInModel(model,true);

        end


        [blks,findSysError]=utFindBlocksInModel(model,...
        variantOpt,...
        commentOpt,...
        linksOpt,...
        maskOpt,...
        bAllSubsystems,...
        blkType)


        idxs=findSignals(signals,bpath,portIdx)


        varargout=loadMdlForDefaultSignals(mdlBlock,...
        topModelName,...
        obj,...
        variantOpt)


        [res,findSysError]=getLoggedSignalsFromMdl(sys,...
        blkPrefix,...
        bRecurse,...
        variantOpt,...
        commentOpt,...
        linksOpt,...
        maskOpt,...
        bAllSubsystems,...
        bIncludeOff,...
        bIncludeTestPoints,...
        res,...
        subPath,...
        topModelName,...
        bNeverLoadMdl)


        res=getDefaultChartSignals(modelBlock,...
        blk,...
        bIncludeOff,...
        res,...
        subPath)


        [sigs,bInvalidSignals]=checkForDuplicates(sigs,invalidAction)


        function reportInvalidSetting(action,varargin)


            if strcmpi(action,'error')
                DAStudio.error(varargin{:});
            end
            if strcmpi(action,'warnAndRemove')
                warning(message(varargin{:}));
            end
        end
    end


    methods(Hidden=true)


        [this,bInvalidSignals]=validate(this,...
        modelName,...
        bValidateHier,...
        bReqLoggedPorts,...
        bTopMdlOnly,...
        invalidAction)


        this=removeSignal(this,idx)


        [defLog,sigInfo,sigIdx,bSigNameChange,this]=...
        getSettingsForSignal(this,...
        path,...
        portIdx,...
        sub_path,...
        bValidateLogging,...
        signalName,...
        useCache)


        [sigInfo,sigIdx,bSigNameChange,this]=...
        getSettingsForSignalUncached(this,...
        sigInfo,...
        sigIdx,...
        bSigNameChange,...
        bpath,...
        portIdx,...
        signalName)


        [sig,this]=updateSignalNameCache(this,sigIdx)


        function warnForRefSignalNameChange(this,idx,old_name)



            len=this.signals_(idx).blockPath_.getLength;
            blk=this.signals_(idx).blockPath_.getBlock(len);

            if this.signals_(idx).LoggingInfo.nameMode_==0
                DAStudio.warning(...
                'Simulink:Logging:RefMdlSignalNameChanged',...
                Simulink.SimulationData.BlockPath.getModelNameForPath(blk),...
                this.signals_(idx).outputPortIndex_,...
                blk,...
                old_name,...
                this.signals_(idx).signalName_,...
                this.Model);
            end
        end


        this=setSettingsForSignal(this,sig)



        res=getSignalsForMdlBlockOrStateflow(this,...
        block,...
        bHonorDefaults,...
        bIncludeAllSigs,...
        okIfMdlBlkDoesNotExist)


        bRet=mdlBlockIsValidAndMayLog(~,block)


        [defSigs,bUseDefaults]=...
        getMdlBlockOrChartDefaultSignalsIfNeeded(this,...
        block,...
        bIsStateflow,...
        bIncludeAllSigs,...
        bHonorDefaults)


        res=getApplicableOverrideSignals(this,...
        block,...
        bIsStateflow)


        dest=addUniqueSignalsToVectorAndTurnOff(~,source,dest)


        bRet=modelHasOverrideSignals(this,block)


        indices=getOverrideSignalIndices(this)


        this=removeAndWarnForUnavailRefSignals(this,idxToRemove)


        [bLogAsSpec,res]=getSignalsForSubsystem(this,bp)


        this=removeSignalsForTopMdl(this)


        this=removeSignalsForMdlBlock(this,modelBlock,bInvalidOnly)


        this=updateModelName(this,modelName,assumeSameSSIDs)





        ssId=getSSID(this,blkOrMdl)





        bRet=getLogAsSpecifedFast(this,blk)




        function assertSizeOfLogAsSpecifiedMatch(this)
            assert(isequal(...
            size(this.logAsSpecifiedByModelsSSIDs_),...
            size(this.logAsSpecifiedByModels_)));
        end




        this=syncSizeOfLogAsSpecifiedSSIDs(this)


        this=cacheSSIDs(this,bOpenMdl,bSkipSignals)


        this=refreshFromSSIDcache(this,bOpenMdl,bTopMdlOnly)


        this=copySettingsFrom(this,srcObj,srcPath,dstPath)


        this=enableLoggingOnPort(this,...
        bpath,...
        bEnable,...
        sigType,...
        bRecurse,...
        linksOpt,...
        maskOpt)


        this=utAddSignal(this,...
        bpath,portIdx,bLog,...
        bDecimate,decimation,...
        bLimitPts,maxPts,...
        bCustName,customName,...
        sub_path,...
        signal_name)


        structure=utStruct(this)


        [this,bChanged]=addOverrideForPort(this,bpath,portIdx)


        bTestPoints=supportsTestPointSignals(this)


        bInTop=signalIsInTopMdl(this,idx)


        function this=setSignals_(this,val)
            if isempty(val)
                this.signals_=Simulink.SimulationData.SignalLoggingInfo.empty;
            else
                this.signals_=val;
            end
        end


        function this=removeSignals_(this,idxToRemove)
            if~isempty(idxToRemove)
                this.signals_(idxToRemove)=[];
            end
            if isempty(this.signals_)
                this.signals_=Simulink.SimulationData.SignalLoggingInfo.empty;
            end
        end


        function this=setFinalBpCache(this,sigList)



            this.finalBpCache=cell(length(sigList),1);
            for idx=1:length(sigList)
                this.finalBpCache{idx}=sigList(idx).BlockPath.getLastPath();
            end
        end
    end


    properties(Hidden=true,Transient=true)


        finalBpCache={};
    end


    properties(Hidden=true)


        model_='';



        signals_=Simulink.SimulationData.SignalLoggingInfo.empty;




        overrideMode_=uint32(Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings);





        logAsSpecifiedByModels_={};



        logAsSpecifiedByModelsSSIDs_={};

    end
end




