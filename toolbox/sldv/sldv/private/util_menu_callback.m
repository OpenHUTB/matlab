function status=util_menu_callback(method,callbackInfo,varargin)





    status=true;
    switch(method)
    case 'show_subsystem_params'
        show_subsystem_params_callback(callbackInfo);
    case 'compat'
        isSSmode=false;
        compatibility_callback(callbackInfo,isSSmode);
    case 'subsys_compat'
        isSSmode=true;
        isSFmode=false;
        compatibility_callback(callbackInfo,isSSmode,isSFmode);
    case 'sf_atomicsubchart_compat'
        subsystemH=callbackInfo;
        isSSmode=false;
        isSFmode=true;
        compatibility_callback(subsystemH,isSSmode,isSFmode);
    case 'testgen'
        isSSmode=false;
        testgen_callback(callbackInfo,isSSmode);
    case 'subsys_testgen'
        isSSmode=true;
        testgen_callback(callbackInfo,isSSmode);
    case 'sim_testgen'
        isSSmode=true;
        doSimTopModel=true;
        testgen_callback(callbackInfo,isSSmode,doSimTopModel);
    case 'sf_atomicsubchart_testgen'
        subsystemH=callbackInfo;
        testgen_sf_callback(subsystemH);
    case 'detectErrors'
        isSSmode=false;
        detectErrors_callback(callbackInfo,isSSmode);
    case 'subsys_detectErrors'
        isSSmode=true;
        detectErrors_callback(callbackInfo,isSSmode);
    case 'sf_atomicsubchart_detecterrors'
        subsystemH=callbackInfo;
        detectErrors_sf_callback(subsystemH);
    case 'prove'
        isSSmode=false;
        prove_callback(callbackInfo,isSSmode);
    case 'subsys_prove'
        isSSmode=true;
        prove_callback(callbackInfo,isSSmode);
    case 'sf_atomicsubchart_prove'
        subsystemH=callbackInfo;
        prove_sf_callback(subsystemH);
    case 'options'
        isSSmode=false;
        settings_callback(callbackInfo,isSSmode);
    case 'optionsReferencedModel'
        settings_callback_referenced_model(callbackInfo);
    case 'subsys_options'
        isSSmode=true;
        settings_callback(callbackInfo,isSSmode);
    case 'sf_atomicsubchart_options'
        settings_callback(callbackInfo,false,true);
    case 'load_results_file'
        status=load_result_callback(callbackInfo);
    case 'load_active_results'
        active_results_callback(callbackInfo);
    case 'component_advisor'
        component_advisor_callback(callbackInfo);
    case 'testgen_missing_coverage'
        isSSmode=false;
        testgen_missing_coverage_callback(callbackInfo,isSSmode);
    case{'compat_code','compat_code_modelref'}
        isSSmode=false;
        isSFmode=false;
        compatibility_callback(callbackInfo,isSSmode,isSFmode);
    case{'testgen_code','testgen_code_modelref'}
        isSSmode=false;
        testgen_callback(callbackInfo,isSSmode);
    otherwise
        error(message('Sldv:util_menu_callback:UnknownMethod',method));
    end

end

function[pinnedSystemObj,pinnedSystemBlockPathObj]=getToolstripPinnedSubsystem(cbinfo)
    pinnedSystemObj=cbinfo.studio.App.getPinnedSystem('selectSystemDesignVerifierAction');


    appContext=Sldv.ui.toolstrip.internal.getappcontextobj(cbinfo);
    pinnedSystemBlockPathObj=appContext.pinnedBlockPath;
end

function[componentH,componentBlockPathObj]=getSelectedComponentH(callbackInfo)

    if~callbackInfo.isContextMenu
        [pinnedSubsystem,componentBlockPathObj]=getToolstripPinnedSubsystem(callbackInfo);
        if~isempty(pinnedSubsystem)
            componentH=pinnedSubsystem.Handle;
        else
            selection=callbackInfo.getSelection();
            switch length(selection)
            case 0

                componentH=SLStudio.Utils.getSLHandleForSelectedHierarchicalBlock(callbackInfo);
                componentBlockPathObj=[];
            case 1

                componentH=selection.Handle;
                parentHid=callbackInfo.studio.App.getActiveEditor.getHierarchyId;


                componentBlockPathObj=Simulink.BlockPath.fromHierarchyIdAndHandle(parentHid,componentH);
            otherwise

                componentH=SLStudio.Utils.getSLHandleForSelectedHierarchicalBlock(callbackInfo);
                componentBlockPathObj=[];
            end
        end
    else

        blockObj=callbackinfo_get_selection(callbackInfo);
        componentH=blockObj.Handle;


        parentHid=callbackInfo.studio.App.getActiveEditor.getHierarchyId;
        componentBlockPathObj=Simulink.BlockPath.fromHierarchyIdAndHandle(parentHid,componentH);
    end
end

function sfSubsystemH=getSelectedSFSubsystemH(callbackInfo)
    if~callbackInfo.isContextMenu
        pinnedSubsystem=getToolstripPinnedSubsystem(callbackInfo);
        if~isempty(pinnedSubsystem)
            subsys=pinnedSubsystem.Id;
        else
            subsys=callbackInfo.getSelection.Id;
        end
    else
        subsys=callbackInfo.getSelection.Id;
    end


    sfSubsystemH=sf('get',subsys,'.simulink.blockHandle');
end

function compatibility_callback(callbackInfo,isSSmode,isSFmode)
    if nargin<3
        isSFmode=false;
    end

    if isSSmode
        [componentH,componentBlockPathObj]=getSelectedComponentH(callbackInfo);
        modelH=callbackInfo.model.Handle;
    elseif isSFmode
        componentH=getSelectedSFSubsystemH(callbackInfo);
        modelH=bdroot(componentH);
        componentBlockPathObj=[];
    else
        modelH=callbackInfo.model.Handle;
        componentH=[];
        componentBlockPathObj=[];
    end


    if~isempty(componentBlockPathObj)&&sldvprivate('isBlockPathActive',componentBlockPathObj)==false
        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
        errMsg=getString(message('Sldv:Setup:ComponentForAnalysisCommentedInactive'));
        errordlg(errMsg,dialogTitle);
        return;
    end




    errMsg=sldvprivate('mdl_check_observer_port',modelH);
    if~isempty(errMsg)
        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
        errordlg(errMsg,dialogTitle);
        return;
    end


    sldvSession=sldvGetActiveSession(modelH);


    if~isempty(sldvSession)&&...
        (sldvSession.isCompatibilityRunning||sldvSession.isAnalysisRunning)
        msg=getString(message('Sldv:SldvRun:OnlyOneAnalysis'));
        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
        errordlg(msg,dialogTitle);
        return;
    end

    [slavtcc,configSet]=configcomp_get(modelH);

    doCompatibility=false;
    if~isempty(slavtcc)
        opts=sldvoptions(modelH);
        commitBuild=slprivate('checkSimPrm',configSet);
        if commitBuild
            doCompatibility=true;
        end
    else
        opts=sldvoptions;
        doCompatibility=true;
    end



    client=Sldv.SessionClient.DVGUI;
    showUI=true;
    initialCovData=[];

    if isempty(sldvSession)
        sldvSession=sldvCreateSession(modelH,componentH,opts,showUI,initialCovData,client);

        assert(~isempty(sldvSession)&&isvalid(sldvSession));
    else
        sldvSession.reset(componentH,opts,showUI,initialCovData,client);
    end




    if doCompatibility

        try
            filterExistingCov=true;
            reuseTranslationCache=false;
            standaloneCompat=true;
            status=sldvSession.checkCompatibility(filterExistingCov,reuseTranslationCache,[],standaloneCompat);
        catch MEx
            status=false;%#ok<NASGU>





            if(strcmp(MEx.identifier,'Sldv:Session:invalidObj'))
                return;
            end
            rethrow(MEx);
        end




        if((true==status)||...
            strcmp(sldvSession.getCompatibilityStatus(),'DV_COMPAT_PARTIALLY_SUPPORTED'))

            try
                sldvSession.clearStopRequest();
            catch MEx %#ok<NASGU>







                return;
            end
        end
    end

end



function testgen_callback(callbackInfo,isSSmode,doSimTopModel)
    if nargin<3
        doSimTopModel=false;
    end
    isSFmode=false;

    analyze_callback(callbackInfo,'TestGeneration',isSSmode,isSFmode,doSimTopModel);
end


function testgen_sf_callback(subsystemH)
    analyze_callback(subsystemH,'TestGeneration',false,true);
end



function detectErrors_callback(callbackInfo,isSSmode)
    analyze_callback(callbackInfo,'DesignErrorDetection',isSSmode);
end


function detectErrors_sf_callback(subsystemH)
    analyze_callback(subsystemH,'DesignErrorDetection',false,true);
end



function prove_callback(callbackInfo,isSSmode)
    analyze_callback(callbackInfo,'PropertyProving',isSSmode);
end



function prove_sf_callback(subsystemH)
    analyze_callback(subsystemH,'PropertyProving',false,true);
end



function analyze_callback(callbackInfo,analysisMode,isSSmode,isSFmode,doTopModelSim)





    if slfeature('SldvTaskingArchitecture')
        dv.tasking.ServiceHandler();
    end

    if nargin<5
        doTopModelSim=false;
    end
    if nargin<4
        isSFmode=false;
    end
    if isSSmode
        [componentH,componentBlockPathObj]=getSelectedComponentH(callbackInfo);
        modelH=bdroot(componentH);
    elseif isSFmode
        componentH=getSelectedSFSubsystemH(callbackInfo);
        modelH=bdroot(componentH);
        componentBlockPathObj=[];
    else
        modelH=callbackInfo.model.Handle;
        componentH=[];
        componentBlockPathObj=[];
    end


    if~isempty(componentBlockPathObj)&&sldvprivate('isBlockPathActive',componentBlockPathObj)==false
        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
        errMsg=getString(message('Sldv:Setup:ComponentForAnalysisCommentedInactive'));
        errordlg(errMsg,dialogTitle);
        return;
    end




    errMsg=sldvprivate('mdl_check_observer_port',modelH);
    if~isempty(errMsg)
        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
        errordlg(errMsg,dialogTitle);
        return;
    end


    sldvSession=sldvGetActiveSession(modelH);


    if~isempty(sldvSession)&&...
        (sldvSession.isCompatibilityRunning||sldvSession.isAnalysisRunning)
        msg=getString(message('Sldv:SldvRun:OnlyOneAnalysis'));
        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
        errordlg(msg,dialogTitle);
        return;
    end

    runAnalysis=false;
    [slavtcc,configSet]=configcomp_get(modelH);
    if~isempty(slavtcc)
        currOpts=sldvoptions(modelH);
        if strcmp(currOpts.Mode,analysisMode)
            opts=currOpts;
        else
            opts=currOpts.deepCopy;
            opts.Mode=analysisMode;
        end
        commitBuild=slprivate('checkSimPrm',configSet);
        if commitBuild
            runAnalysis=true;
        end
    else
        opts=sldvoptions;
        opts.Mode=analysisMode;
        runAnalysis=true;
    end


    if doTopModelSim
        opts.ExtendUsingSimulation='on';
        ocExtend=onCleanup(@()clearExtendUsingSimulation(opts));
    end



    client=Sldv.SessionClient.DVGUI;
    showUI=true;
    initialCovData=[];
    if~isempty(sldvSession)


        sldvSession.reset(componentH,opts,showUI,initialCovData,client,componentBlockPathObj);
    else
        sldvSession=sldvCreateSession(modelH,componentH,opts,showUI,initialCovData,client,componentBlockPathObj);

        assert(~isempty(sldvSession)&&isvalid(sldvSession));
    end




    if(true==runAnalysis)










        sldvSession.createSldvExecutionDiagStage();


        try
            [compatibilityStatus,~,msg]=sldvSession.checkCompatibility();
        catch MEx
            compatibilityStatus=false;%#ok<NASGU>




            sldvSession.destroySldvExecutionDiagStage();






            if(strcmp(MEx.identifier,'Sldv:Session:invalidObj'))
                return;
            end
            rethrow(MEx);
        end


        if(true==compatibilityStatus)
            try
                [status,~]=sldvSession.launchAnalysis();
                if~status
                    sldvSession.destroySldvExecutionDiagStage();
                end

            catch MEx %#ok<NASGU>






                sldvSession.destroySldvExecutionDiagStage();






                return;
            end
        else



            sldvSession.destroySldvExecutionDiagStage();




            if(true==checkPartialCompatibleWorkflow(modelH,msg))



                try
                    sldvSession.clearStopRequest();
                catch MEx %#ok<NASGU>







                    return;
                end
            end
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

        testComponent=avDataHandle.ui.testComp;
        if(~isempty(testComponent)&&...
            ishandle(testComponent)&&...
            isa(testComponent,'SlAvt.TestComponent'))
            compatStatus=testComponent.compatStatus;
            yesNo=strcmp(compatStatus,'DV_COMPAT_PARTIALLY_SUPPORTED')&&...
            strcmp(testComponent.activeSettings.AutomaticStubbing,'off');
        end
    end


    if~yesNo
        return;
    end
    testComponent.progressUI.breakOnCompat=true;



    analyzeMode=testComponent.activeSettings.Mode;
    if strcmp(analyzeMode,'TestGeneration')
        analyzeTag=DAStudio.message('Sldv:dialog:sldvDVOptionGenTests');
    elseif strcmp(analyzeMode,'PropertyProving')
        analyzeTag=DAStudio.message('Sldv:dialog:sldvDVOptionProveProps');
    else
        analyzeTag=DAStudio.message('Sldv:dialog:sldvDVOptionDetectErrs');
    end

    advice=sprintf(getString(message('Sldv:Setup:ContinueToAnalysis',analyzeTag)));

    testComponent.progressUI.appendToLog(advice);
    testComponent.progressUI.refreshLogArea;
end




function settings_callback(callbackInfo,isSSmode,isSFmode)
    if nargin<3
        isSFmode=false;
    end
    if isSSmode
        subsystemH=getSelectedComponentH(callbackInfo);
        modelH=bdroot(subsystemH);
    elseif isSFmode
        subsystemH=getSelectedSFSubsystemH(callbackInfo);
        modelH=bdroot(subsystemH);
    else
        modelH=callbackInfo.model.Handle;
        subsystemH=[];
    end
    configcomp_open(modelH,subsystemH);
end



function settings_callback_referenced_model(callbackInfo)

    block=find_system(callbackInfo.model.Handle,'SearchDepth',1,'BlockType','ModelReference');
    referencedModel=get_param(block,'ModelName');
    subsystemH=[];
    if~bdIsLoaded(referencedModel)
        open_system(referencedModel);
    end
    configcomp_open(referencedModel,subsystemH);
end



function status=load_result_callback(callbackInfo)

    modelH=callbackInfo.model.Handle;
    inp_modelName=get_param(modelH,'Name');
    status=true;

    path=get_datafile_default_path(modelH,inp_modelName);
    file_fltr=strcat(path,filesep,'*.mat');


    try
        [fname,pname]=uigetfile(file_fltr);
    catch

        path=pwd;

        file_fltr=strcat(path,filesep,'*.mat');
        [fname,pname]=uigetfile(file_fltr);


    end

    if~(isequal(fname,0)||isequal(pname,0))


        progressBar=createLoadResultProgressInd;
        datafile=fullfile(pname,fname);


        showUI=true;
        [status,errormsg]=sldvloadresults(modelH,datafile,showUI);
        if(status==true)

            active_results_callback(callbackInfo);
            delete(progressBar);
        else
            delete(progressBar);
            errortitle=getString(message('Sldv:LoadResults:LoadResultError'));
            errordlg(errormsg,errortitle);
        end
    end
end

function path=get_datafile_default_path(modelH,modelName)
    options=sldvoptions(modelH);



    path=strrep(options.OutputDir,'$ModelName$',modelName);
    path=strrep(path,'\',filesep);
    path=strrep(path,'/',filesep);

    if strcmp(path(end),filesep)
        path=path(1:end-1);
    end
end

function progressBar=createLoadResultProgressInd
    try
        progressBar=DAStudio.WaitBar;
        progressBar.setWindowTitle(getString(message('Sldv:LoadResults:LoadResultProgress')));
        progressBar.setLabelText(DAStudio.message('Simulink:tools:MAPleaseWait'));
        progressBar.setCircularProgressBar(true);
        progressBar.show();
    catch Mex %#ok<NASGU>
        progressBar=[];
    end
end



function active_results_callback(callbackInfo)
    try
        modelH=callbackInfo.model.Handle;
        modelObj=get_param(modelH,'Object');
        hierChild=modelObj.getMixedHierarchicalChildren;
        isDVOutput=cellfun(@(x)x.isa("Simulink.DVOutput"),hierChild);
        if any(isDVOutput)
            child=hierChild{isDVOutput};
            found=true;
        end
        if(found)


            av_handle=get_param(modelH,'AutoVerifyData');
            if isfield(av_handle,'res_dialog')
                res_dialog=av_handle.res_dialog;
                if~isempty(res_dialog)
                    try
                        res_dialog.delete();
                    catch Mex %#ok<NASGU>



                    end
                end
            end

            res_dialog=DAStudio.Dialog(child);
            av_handle.res_dialog=res_dialog;

            set_param(modelH,'AutoVerifyData',av_handle);
        end
    catch Mex %#ok<NASGU>
    end
end



function show_subsystem_params_callback(callbackInfo)
    blockObj=callbackinfo_get_selection(callbackInfo);
    open_system(blockObj.Handle,'parameter');
end

function component_advisor_callback(callbackInfo)

    modelH=callbackInfo.model.Handle;

    comp_adv_stage=Simulink.output.Stage(message('Sldv:ComponentAdvisor:CA_STAGE_NAME').getString(),...
    'ModelName',get_param(modelH,'Name'),'UIMode',true);%#ok<NASGU> 

    try
        handles=get_param(modelH,'AutoVerifyData');


        if~isempty(handles)&&isfield(handles,'advisor')&&...
            isa(handles.advisor,'Sldv.Advisor.MdlHierAnalyzer')&&isvalid(handles.advisor)

            compHeirAnalyser=handles.advisor;


            if~isempty(compHeirAnalyser.getAdvisorUI)
                compHeirAnalyser.getAdvisorUI.show();
            else
                compHeirAnalyser.launch();
            end

        else

            compHeirAnalyser=Sldv.Advisor.MdlHierAnalyzer(modelH);

            handles.advisor=compHeirAnalyser;
            handles.modelName=get_param(modelH,'Name');
            set_param(modelH,'AutoVerifyData',handles);
            compHeirAnalyser.launch();
        end
    catch Mex
        Simulink.output.error(Mex);
    end
end

function testgen_missing_coverage_callback(callbackInfo,~)
    harnessH=callbackInfo.model.Handle;


    client=Sldv.SessionClient.DVGUI;
    sldvextendharness(harnessH,client);
end

function clearExtendUsingSimulation(opts)
    opts.ExtendUsingSimulation='off';
end


