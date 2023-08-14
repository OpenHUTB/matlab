function[this,bInvalidSignals]=validate(this,...
    modelName,...
    bValidateHier,...
    bReqLoggedPorts,...
    bTopMdlOnly,...
    invalidAction)
































    if nargin>1
        modelName=convertStringsToChars(modelName);
    end

    if nargin>5
        invalidAction=convertStringsToChars(invalidAction);
    end

    if nargin<3
        bValidateHier=false;
    end
    if nargin<4
        bReqLoggedPorts=false;
    end
    if nargin<5
        bTopMdlOnly=false;
    end
    if nargin<6
        invalidAction='error';
    end


    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'validate');
    end


    [this.signals_,bInvalidSignals]=...
    Simulink.SimulationData.ModelLoggingInfo.checkForDuplicates(...
    this.signals_,invalidAction);


    if nargin>1
        if~strcmp(modelName,this.model_)


            id='Simulink:Logging:MdlLogInfoMismatchModelName';
            if strcmpi(invalidAction,'error')
                DAStudio.error(...
                id,...
                modelName,...
                this.model_);
            elseif strcmpi(invalidAction,'warnAndRemove')
                DAStudio.warning(...
                id,...
                modelName,...
                this.model_);
            end


            this=this.updateModelName(modelName);
        end
    end



    closeMdlObj=Simulink.SimulationData.ModelCloseUtil;%#ok<NASGU>


    try
        load_system(this.model_);
    catch me
        id='Simulink:Logging:MdlLogInfoInvalidTopModel';
        err=MException(id,DAStudio.message(id,this.model_));
        err=err.addCause(me);
        throw(err);
    end








    warn_state=warning('off','all');
    this=this.refreshFromSSIDcache(true,bTopMdlOnly);
    warning(warn_state);


    bIncTestPoints=this.supportsTestPointSignals();



    idxToRemove=[];
    for idx=1:length(this.signals_)



        if bTopMdlOnly&&~this.signalIsInTopMdl(idx)
            continue;
        end


        len=this.signals_(idx).blockPath_.getLength();
        if this.signalIsInTopMdl(idx)&&this.getLogAsSpecifiedInModel(this.model_)
            continue;
        elseif len>1&&...
            this.getLogAsSpecifiedInModel(...
            this.signals_(idx).blockPath_.getBlock(1),...
            false)
            continue;
        end


        try
            this.signals_(idx)=this.signals_(idx).validate(...
            this.model_,...
            idx,...
            bValidateHier,...
            bReqLoggedPorts,...
            bIncTestPoints);
        catch me




            if this.signals_(idx).loggingInfo_.dataLogging_
                if strcmpi(invalidAction,'error')
                    throw(me);
                end
                if strcmpi(invalidAction,'warnAndRemove')
                    warning(me.identifier,me.message);
                end
            end

            bInvalidSignals=true;
            idxToRemove=[idxToRemove,idx];%#ok<AGROW>
        end
    end


    this=this.removeSignals_(idxToRemove);


    this=this.setFinalBpCache(this.signals_);


    idxToRemove=[];
    for idx=1:length(this.logAsSpecifiedByModels_)


        if strcmp(this.logAsSpecifiedByModels_{idx},this.model_)
            continue;
        end;


        blkMdl=...
        Simulink.SimulationData.BlockPath.getModelNameForPath(...
        this.logAsSpecifiedByModels_{idx});
        if~strcmp(blkMdl,this.model_)
            Simulink.SimulationData.ModelLoggingInfo.reportInvalidSetting(...
            invalidAction,...
            'Simulink:Logging:MdlLogInfoValidateLogAsSpecBlkPath',...
            this.model_,...
            this.logAsSpecifiedByModels_{idx});
            bInvalidSignals=true;
            idxToRemove=[idxToRemove,idx];%#ok<AGROW>
            continue;
        end


        try
            blockType=...
            get_param(this.logAsSpecifiedByModels_{idx},...
            'BlockType');
        catch me


            if strcmpi(invalidAction,'error')

                errID='Simulink:Logging:MdlLogInfoValidateLogAsSpecBlkPath';
                newError=MException(...
                errID,...
                DAStudio.message(errID,...
                this.model_,...
                this.logAsSpecifiedByModels_{idx}));
                newError=newError.addCause(me);
                throw(newError);
            end
            if strcmpi(invalidAction,'warnAndRemove')
                warning(message('Simulink:Logging:MdlLogInfoValidateLogAsSpecBlkPath',...
                this.model_,this.logAsSpecifiedByModels_{idx}));
            end

            bInvalidSignals=true;
            idxToRemove=[idxToRemove,idx];%#ok<AGROW>
            continue;
        end


        if~strcmp(blockType,'ModelReference')
            Simulink.SimulationData.ModelLoggingInfo.reportInvalidSetting(...
            invalidAction,...
            'Simulink:Logging:MdlLogInfoValidateLogAsSpecBlkPath',...
            this.model_,...
            this.logAsSpecifiedByModels_{idx});
            bInvalidSignals=true;
            idxToRemove=[idxToRemove,idx];%#ok<AGROW>
            continue;
        end

    end


    if~isempty(idxToRemove)
        this.logAsSpecifiedByModels_(idxToRemove)=[];
    end



    this=this.cacheSSIDs(...
    false,...
    false);

    assert(isequal(length(this.finalBpCache),length(this.signals_)));

end
