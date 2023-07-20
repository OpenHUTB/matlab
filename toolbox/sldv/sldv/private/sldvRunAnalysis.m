function[status,fileNames,newModelH,msg,fullCovAlreadyAcheived]=sldvRunAnalysis(obj,...
    opts,...
    showUI,...
    initialCovData,...
    preExtract,...
    customEnhancedMCDCOpts,...
    client)









    if slfeature('SldvTaskingArchitecture')
        dv.tasking.ServiceHandler();
    end

    if(nargin<7)
        client=Sldv.SessionClient.DVCommandLine;
    end

    if(nargin<6)
        customEnhancedMCDCOpts=[];
    end

    if(nargin<5)
        preExtract=[];
    else






        if isfield(preExtract,'extractH')
            extractedModelPath=get_param(preExtract.extractH,'FileName');
        else
            extractedModelPath=[];
        end
    end


    status=0;
    fileNames=Sldv.Utils.initDVResultStruct();
    newModelH=[];
    msg='';
    fullCovAlreadyAcheived=false;

    [errStr,modelH,blockH]=cmd_resolveobj(obj);
    if~isempty(errStr)
        sldvError('Sldv:SldvRun:Obj',errStr,showUI);
        return;
    end

    if(strcmp(get_param(modelH,'isHarness'),'on')&&...
        ~isempty(blockH)&&...
        ~Simulink.harness.internal.isHarnessCUT(blockH))
        errStr=getString(message('Sldv:checkArgsOptions:UnsupSubsystemInTestHarness'));
        sldvError('Sldv:SldvRun:Obj',errStr,showUI);
        return;
    end








    isDvirSim=slavteng('feature','DvirSim')==1;
    if(~showUI&&~isDvirSim)||ModelAdvisor.isRunning
        interceptor_scope_definer=Simulink.output.registerProcessor(Simulink.output.VoidInterceptorCb());%#ok<NASGU>
    end


    if(~isempty(modelH))
        sldv_run_stage=Simulink.output.Stage(message('Sldv:SldvRun:SLDV_RUN_STAGE_NAME').getString(),...
        'ModelName',get_param(modelH,'Name'),'UIMode',showUI);%#ok<NASGU>
    end

    token=Sldv.Token.get;
    if token.isInUse
        status=0;
        msg=getString(message('Sldv:SldvRun:OnlyOneAnalysis'));
        if showUI
            dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
            errordlg(msg,dialogTitle);
        else
            error('Sldv:Setup:MultipleAnalysis',msg);
        end
        return;
    end

    clearResults(modelH);


    removeModelHighlighting(modelH);


    if isempty(opts)
        opts=sldvoptions(modelH);
    end


    sldvSession=sldvGetActiveSession(modelH);
    if~isempty(sldvSession)


        sldvSession.reset(blockH,opts,showUI,initialCovData,client);
    else
        sldvSession=sldvCreateSession(modelH,blockH,opts,showUI,initialCovData,client);
        assert(~isempty(sldvSession)&&isvalid(sldvSession));
    end




    try

        if~isempty(preExtract)
            preExtract.extractH=load_system(extractedModelPath);
        end
        [status,newModelH,msg,fullCovAlreadyAcheived,fileNames]=...
        sldvSession.extractAndRunCompatibility(preExtract,customEnhancedMCDCOpts);

        if~status

            checkPartialCompatibleWorkflow(modelH,msg);
        end
    catch MEx
        status=0;


        if(strcmp(MEx.identifier,'Sldv:Session:invalidObj'))
            return;
        end
        rethrow(MEx);
    end
    if~status
        return;
    end


    sldvshareprivate('avtcgirunsupcollect','clear',modelH);
    msg=[];

    mdlFileNames=fileNames;
    try
        [status,msg,fileNames]=sldvSession.runAnalysis();
    catch MEx

        status=0;



        return;
    end
    fileNames.ExtractedModel=mdlFileNames.ExtractedModel;
    fileNames.BlockReplacementModel=mdlFileNames.BlockReplacementModel;


    if~Sldv.utils.Options.isTestgenTargetForModel(opts)
        sldvSession.deleteATSHarness();
    end

    if~status
        return;
    end

    status=bool2double(status);

    return;




    function clearResults(modelH)



        handles=get_param(modelH,'AutoVerifyData');
        if isfield(handles,'res_dialog')
            res_dialog=handles.res_dialog;
            if~isempty(res_dialog)
                try
                    res_dialog.delete();
                catch Mex



                end
            end
        end
        if isfield(handles,'analysisFilter')
            if slavteng('feature','MultiFilter')
                filterExplorer=handles.analysisFilter;
                if~isempty(filterExplorer)
                    try
                        Sldv.FilterExplorer.close(filterExplorer);
                    catch Mex %#ok<NASGU>
                    end
                end
            else
                filter=handles.analysisFilter;
                if~isempty(filter)
                    try
                        filter.reset;
                        filter.delete;
                    catch Mex %#ok<NASGU>
                    end
                end
            end
        end
    end

    function removeModelHighlighting(modelH)


        if showUI
            handles=get_param(modelH,'AutoVerifyData');
            if isfield(handles,'modelView')&&handles.modelView.isvalid

                SLStudio.Utils.RemoveHighlighting(modelH);

                delete(handles.modelView);
                handles=rmfield(handles,'modelView');
                set_param(modelH,'AutoVerifyData',handles);
            end
        end
    end


    function yesNo=checkPartialCompatibleWorkflow(modelH,msg)




        yesNo=false;

        if ischar(msg)&&strcmp(msg,getString(message('Sldv:Setup:OnlyOneAnalysisRun')))
            return;
        end

        avDataHandle=get_param(modelH,'AutoVerifyData');
        if isfield(avDataHandle,'ui')&&~isempty(avDataHandle.ui)&&...
            isa(avDataHandle.ui,'AvtUI.Progress')

            testComp=avDataHandle.ui.testComp;
            if(~isempty(testComp)&&ishandle(testComp)&&...
                isa(testComp,'SlAvt.TestComponent'))

                compatStatus=testComp.compatStatus;
                yesNo=strcmp(compatStatus,'DV_COMPAT_PARTIALLY_SUPPORTED')&&...
                strcmp(testComp.activeSettings.AutomaticStubbing,'off');
            end
        end


        if~yesNo
            return;
        end

        if showUI
            testComp.progressUI.breakOnCompat=true;

            analyzeMode=testComp.activeSettings.Mode;
            if strcmp(analyzeMode,'TestGeneration')
                analyzeTag=DAStudio.message('Sldv:dialog:sldvDVOptionGenTests');
            elseif strcmp(analyzeMode,'PropertyProving')
                analyzeTag=DAStudio.message('Sldv:dialog:sldvDVOptionProveProps');
            else
                analyzeTag=DAStudio.message('Sldv:dialog:sldvDVOptionDetectErrs');
            end
            advice=sprintf(getString(message('Sldv:Setup:ContinueToAnalysis',analyzeTag)));

            testComp.progressUI.appendToLog(advice);
            testComp.progressUI.refreshLogArea;
        end
    end



end
