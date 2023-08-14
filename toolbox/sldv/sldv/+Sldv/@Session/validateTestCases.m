





function validatedSldvData=validateTestCases(obj,sldvData,useParallel)



    status=~((Sldv.SessionState.None==obj.mState)||...
    (Sldv.SessionState.Terminated==obj.mState));
    if~status

        return;
    end


    slOutputStage=[];%#ok<NASGU>
    if(strcmp('TestGeneration',obj.mSldvOpts.Mode))
        slOutputStage=Simulink.output.Stage(message('Sldv:SldvRun:SLDV_RUN_TEST_GENERATION_STAGE_NAME').getString(),...
        'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);%#ok<NASGU>

    elseif(strcmp('PropertyProving',obj.mSldvOpts.Mode))
        slOutputStage=Simulink.output.Stage(message('Sldv:SldvRun:SLDV_RUN_PROPERTY_PROVING_STAGE_NAME').getString(),...
        'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);%#ok<NASGU>
    end



    status=obj.acquireSldvToken();
    if~status
        msg=getString(message('Sldv:Setup:OnlyOneAnalysisRun'));
        obj.reportError('Sldv:Setup:MultipleAnalysis',msg);
        return;
    end


    tokenCleanup=onCleanup(@()obj.cleanupCompatibility());


    [status,msg]=obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
    if~status
        obj.reportError('Sldv:Setup:TestComp',msg);
        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end

    testComp=obj.mTestComp;


    [~,msg]=sldvprivate('checkSldvOptions',testComp.activeSettings,...
    true,obj.mModelH,obj.mBlockH,obj.mShowUI);
    if~isempty(msg)
        obj.reportError('Sldv:Setup:Options',msg);
        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end



    obj.mSldvToken.setTestComponent(testComp);





    csLock=Sldv.ConfigSetLock(obj.mModelH);%#ok<NASGU>

    try

        sldvTranslator=Sldv.Translator(obj.mModelH,[],obj.mSldvOpts,false,[],testComp,true,true);


        [status,~,~]=sldvTranslator.translate();

        if~status
            error("Translation did not complete properly");
        end
    catch ME
        ME=MException('Sldv:Session:invalidObj','SLDV Session is no longer valid');

        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        throw(ME);
    end

    try
        validator=Sldv.Validator.StandaloneValidator(obj.mModelH,sldvData,testComp,useParallel);



        validatedSldvData=validator.runValidator();

    catch MEx

        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        rethrow(MEx)
    end
end
