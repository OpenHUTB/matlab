function[inPortInfo,outPortInfo,modelCompileInfo]=...
    getModelCompiledIOInfo(model,parameterSettings)





    modelCompileInfo=struct('sampleTime',[],...
    'modelSampleDetails',[]);

    if ischar(model)
        try
            modelH=get_param(model,'Handle');
        catch myException %#ok<NASGU>
            modelH=[];
        end
    else
        modelH=model;
    end

    if exist('sldvprivate','file')==2
        try
            testcomp=Sldv.Token.get.getTestComponent;
        catch myException %#ok<NASGU>
            testcomp=[];
        end
    else
        testcomp=[];
    end

    if~isempty(testcomp)&&ishandle(testcomp)&&~isempty(testcomp.mdlFlatIOInfo)
        inPortInfo=testcomp.mdlFlatIOInfo.Inport;
        outPortInfo=testcomp.mdlFlatIOInfo.Outport;
        modelCompileInfo.sampleTime=testcomp.mdlFundamentalTs;
        return;
    end

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    old_autosave_state=get_param(0,'AutoSaveOptions');
    new_autosave_state=old_autosave_state;
    new_autosave_state.SaveOnModelUpdate=0;
    new_autosave_state.SaveBackupOnVersionUpgrade=0;
    set_param(0,'AutoSaveOptions',new_autosave_state);

    origDirtyFlag=get_param(modelH,'Dirty');
    origConfigSet=getActiveConfigSet(modelH);

    Sldv.utils.replaceConfigSetRefWithCopy(modelH);

    parameterSettings=...
    Sldv.utils.checkParametersForCompile(modelH,parameterSettings);

    model=get_param(modelH,'Name');
    Sldv.DataUtils.set_cache_compiled_bus(modelH,'on');
    mException=[];
    strictBusErros=false;
    try

        evalc('feval(model,[],[],[],''compileForSizes'');');
    catch Mex
        mException=Mex;
    end

    if~isempty(mException)
        if isfield(parameterSettings,'StrictBusMsg')&&...
            sldvshareprivate('util_is_related_exc',...
            mException,Sldv.utils.errorIdsForStrictBusMsg)

            disp(getString(message('Sldv:shared:DataUtils:MdlFailedToCompile')));
            disp(getString(message('Sldv:shared:DataUtils:TurningStrictBusCheckOff')));
            strictBusErros=true;
            set_param(modelH,'StrictBusMsg',parameterSettings.('StrictBusMsg').originalvalue);
            Sldv.DataUtils.set_cache_compiled_bus(modelH,'off');
            mException=[];
            try
                evalc('feval(model,[],[],[],''compileForSizes'');');
            catch Mex
                mException=Mex;
            end
        end
    end

    if~isempty(mException)

        if isfield(parameterSettings,'MultiTaskRateTransMsg')&&...
            sldvshareprivate('util_is_related_exc',mException,'Simulink:DataTransfer:IllegalIPortRateTrans')
            finalExc=MException('Sldv:SldvDataUtils:GetModelCompiledIOInfo:IllegalModelRefHarness',...
            getString(message('Sldv:DataUtils:IllegalModelRefHarness',model)));
        else
            finalExc=MException('Sldv:SldvDataUtils:GetModelCompiledIOInfo:ModelDoesNotCompile',...
            getString(message('Sldv:DataUtils:ModelDoesNotCompile',model)));

        end
        finalExc=finalExc.addCause(mException);
    else
        finalExc=[];
    end

    if isempty(finalExc)
        try
            mdlFlatIOInfo=sldvshareprivate('mdl_generate_inportinfo',modelH,testcomp,false,strictBusErros);
            inPortInfo=mdlFlatIOInfo.Inport;
            outPortInfo=mdlFlatIOInfo.Outport;
            mdlObj=get_param(modelH,'Object');
            modelCompileInfo.sampleTime=sldvshareprivate('getRuntimeSampleTimes',mdlObj.getSampleTimeValues());
            modelCompileInfo.modelSampleDetails=Simulink.BlockDiagram.getSampleTimes(modelH);
        catch Mex
            finalExc=Mex;
        end
        try
            evalc('feval(model,[],[],[],''term'');');
        catch mException
            finalExc=MException('Sldv:SldvDataUtils:GetModelCompiledIOInfo:ModelDoesNotTerminateCompile',...
            getString(message('Sldv:DataUtils:ModelDoesNotTerminateCompile',model)));
            finalExc=finalExc.addCause(mException);
        end
    end


    Sldv.utils.restoreConfigSet(modelH,origConfigSet);
    set_param(modelH,'Dirty',origDirtyFlag);

    set_param(0,'AutoSaveOptions',old_autosave_state);

    if~isempty(finalExc)
        throw(finalExc);
    end
end
