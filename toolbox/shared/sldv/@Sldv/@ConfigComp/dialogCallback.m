function dialogCallback(hObj,hDlg,tag,action)





    ObjProp=tag(length('ConfigSet_SLDV_')+1:end);


    action=jsondecode(action);
    configSet=hDlg.getSource.getDialogSource;


    setting_unchanged=feval([ObjProp,'_callback'],hObj,hDlg,configSet,action.selectedTableRow);

    if action.enableApply&&setting_unchanged==false
        EnableApplyButton(hDlg);
    end



    function unchanged_flag=MainPanel_Analyze_callback(hObj,hDlg,~,~)


        mdlName=getDriver(hObj);
        unchanged_flag=true;
        if isempty(mdlName)

            return;
        end

        hCS=getActiveConfigSet(mdlName);
        modelH=get_param(mdlName,'Handle');
        if isempty(hObj.SubsystemToAnalyze)
            systemToAnalyzeH=modelH;
        else
            systemToAnalyzeH=get(hObj.SubsystemToAnalyze,'Handle');
        end

        objPropSaveSystemTestHarness=[hObj.productTag,'SaveSystemTestHarness'];
        valSaveSystemTestHarness=get(hObj,objPropSaveSystemTestHarness);
        if strcmp(valSaveSystemTestHarness,'on')
            sldvshareprivate('local_error_dlg',getString(message('Sldv:shared:configComp:SaveTestHarnessFileOpChked')));
            return;
        end



        commitBuild=slprivate('checkSimPrm',hCS);
        if commitBuild
            settings=Sldv.Options(modelH);
            if systemToAnalyzeH~=modelH
                blockH=systemToAnalyzeH;
            else
                blockH=[];
            end

            [status,errStr]=sldvprivate('checkSldvOptions',settings,false,modelH,blockH,true);
            if~status
                sldvshareprivate('local_error_dlg',errStr);
                return;
            end

            model=cr_to_space(getfullname(modelH));
            systemToAnalyze=cr_to_space(getfullname(systemToAnalyzeH));

            launchSLDVFcn(hDlg,'sldvrun',model,systemToAnalyze,settings);

        end


        function unchanged_flag=MainPanel_CheckCompatibility_callback(hObj,hDlg,~,~)


            mdlName=getDriver(hObj);
            unchanged_flag=true;
            if isempty(mdlName)

                return;
            end

            hCS=getActiveConfigSet(mdlName);
            modelH=get_param(mdlName,'Handle');
            if isempty(hObj.SubsystemToAnalyze)
                systemToCheckCompatH=modelH;
            else
                systemToCheckCompatH=get(hObj.SubsystemToAnalyze,'Handle');
            end



            commitBuild=slprivate('checkSimPrm',hCS);
            if commitBuild
                activityId='c';
                settings=Sldv.Options(modelH);
                if systemToCheckCompatH~=modelH
                    blockH=systemToCheckCompatH;
                else
                    blockH=[];
                end

                [status,errStr]=sldvprivate('checkSldvOptions',settings,activityId,modelH,blockH,true);
                if~status
                    sldvshareprivate('local_error_dlg',errStr);
                    return;
                end

                model=cr_to_space(getfullname(modelH));
                systemToCheckCompat=cr_to_space(getfullname(systemToCheckCompatH));

                launchSLDVFcn(hDlg,'sldvcompat',model,systemToCheckCompat,settings);
            end

            function launchSLDVFcn(hDlg,fcn,varargin)






                cleanTimer(hDlg);




                period=0.1;
                tmr=internal.IntervalTimer(period);


                execListener=event.listener(tmr,'Executing',@(src,evt)timerCallback(fcn,varargin{1:end},tmr));


                setappdata(hDlg,'Launcher',tmr);
                setappdata(hDlg,'ExecListener',execListener);


                setappdata(hDlg,'oc',onCleanup(@()cleanTimer(hDlg)));

                start(tmr);

                function timerCallback(fcn,model,systemToAnalyze,settings,tmr)





                    if slfeature('SldvTaskingArchitecture')
                        dv.tasking.ServiceHandler();
                    end

                    stop(tmr);


                    assert((strcmp(fcn,'sldvcompat'))||(strcmp(fcn,'sldvrun')));


                    modelH=get_param(model,'Handle');
                    blockH=[];
                    if~strcmp(model,systemToAnalyze)
                        blockH=get_param(systemToAnalyze,'Handle');
                    end




                    errMsg=sldvprivate('mdl_check_observer_port',modelH);
                    if~isempty(errMsg)
                        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
                        errordlg(errMsg,dialogTitle);
                        return;
                    end









                    sldvSession=sldvprivate('sldvGetActiveSession',modelH);


                    if~isempty(sldvSession)&&...
                        (sldvSession.isCompatibilityRunning||sldvSession.isAnalysisRunning)
                        msg=getString(message('Sldv:SldvRun:OnlyOneAnalysis'));
                        dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
                        errordlg(msg,dialogTitle);
                        return;
                    end



                    client=Sldv.SessionClient.DVConfigComp;
                    showUI=true;
                    initialCovData=[];
                    if~isempty(sldvSession)
                        sldvSession.reset(blockH,settings,showUI,initialCovData,client);
                    else
                        sldvSession=sldvprivate('sldvCreateSession',modelH,blockH,settings,showUI,initialCovData,client);

                        assert(~isempty(sldvSession)&&isvalid(sldvSession));
                    end














                    if(strcmp(fcn,'sldvrun'))
                        sldvSession.createSldvExecutionDiagStage();
                    end

                    try
                        if strcmp(fcn,'sldvcompat')
                            filterExistingCov=true;
                            reuseTranslationCache=false;
                            standaloneCompat=true;
                            compatibilityStatus=sldvSession.checkCompatibility(filterExistingCov,reuseTranslationCache,[],standaloneCompat);
                        else
                            compatibilityStatus=sldvSession.checkCompatibility();
                        end
                    catch MEx
                        compatibilityStatus=false;





                        sldvSession.destroySldvExecutionDiagStage();






                        if(strcmp(MEx.identifier,'Sldv:Session:invalidObj'))
                            return;
                        end

                        rethrow(MEx);
                    end






                    if((strcmp(fcn,'sldvrun'))&&compatibilityStatus)
                        try
                            sldvSession.launchAnalysis();
                        catch MEx




                            sldvSession.destroySldvExecutionDiagStage();






                            return;
                        end
                    end


                    function unchanged_flag=MainPanel_DVAnalysisFilterFileBrowse_callback(hObj,~,cs,~)



                        default='';

                        objProp=[hObj.productTag,'AnalysisFilterFileName'];
                        val=get_param(cs,objProp);

                        currPath=path;
                        currWD=pwd;

                        [currDir,currName]=fileparts(val);
                        if~isempty(currDir)
                            addpath(currDir);
                        end

                        currFile=which(currName);

                        if isempty(currFile)||strcmp(currFile,default)||strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                            currFile='';
                            currDir='';
                        end

                        if~isempty(currDir)
                            cd(currDir);
                        end

                        [filename,pathname]=uigetfile({'*.cvf';'*.xml'},getString(message('Sldv:shared:configComp:PickExistingFilterFile')),currFile);
                        cd(currWD);
                        path(currPath);

                        if~isequal(filename,0)&&~isequal(pathname,0)
                            newFile=fullfile(pathname,filename);
                            newFile=strrep(newFile,[pwd,filesep],'');
                            set_param(cs,objProp,newFile);
                            unchanged_flag=false;
                        else
                            unchanged_flag=true;
                        end


                        function unchanged_flag=TestGenerationPanel_ComposeSpecBrowse_callback(hObj,~,cs,~)



                            default='';

                            objProp=[hObj.productTag,'ObjectiveComposeSpecFileName'];
                            val=get_param(cs,objProp);

                            currPath=path;
                            currWD=pwd;

                            [currDir,currName]=fileparts(val);
                            if~isempty(currDir)
                                addpath(currDir);
                            end

                            currFile=which(currName);

                            if isempty(currFile)||strcmp(currFile,default)||strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                                currFile='';
                                currDir='';
                            end

                            if~isempty(currDir)
                                cd(currDir);
                            end
                            [filename,pathname]=uigetfile('*.mat',getString(message('Sldv:shared:configComp:PickExistingTestFile')),currFile);
                            cd(currWD);
                            path(currPath);

                            if~isequal(filename,0)&&~isequal(pathname,0)
                                newFile=fullfile(pathname,filename);
                                newFile=strrep(newFile,[pwd,filesep],'');
                                set_param(cs,objProp,newFile);
                                unchanged_flag=false;
                            else
                                unchanged_flag=true;
                            end


                            function unchanged_flag=ParametersPanel_Browse_callback(hObj,~,cs,~)


                                objProp=[hObj.productTag,'ParametersConfigFileName'];
                                val=get_param(cs,objProp);

                                [filename,pathname]=openDirForParameterFile(val,getString(message('Sldv:shared:configComp:PickParamConfigFile')));


                                if~isequal(filename,0)&&~isequal(pathname,0)
                                    newFile=fullfile(pathname,filename);
                                    newFile=strrep(newFile,[pwd,filesep],'');
                                    set_param(cs,objProp,newFile);
                                    unchanged_flag=false;

                                    sendToDDUX(cs,objProp,newFile);
                                else
                                    unchanged_flag=true;
                                end



                                function unchanged_flag=TestGenerationPanel_CovDataBrowse_callback(hObj,~,cs,~)



                                    default='';

                                    objProp=[hObj.productTag,'CoverageDataFile'];
                                    val=get_param(cs,objProp);

                                    currPath=path;
                                    currWD=pwd;

                                    [currDir,currName]=fileparts(val);
                                    if~isempty(currDir)
                                        addpath(currDir);
                                    end

                                    currFile=which(currName);

                                    if isempty(currFile)||strcmp(currFile,default)||strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                                        currFile='';
                                        currDir='';
                                    end

                                    if~isempty(currDir)
                                        cd(currDir);
                                    end
                                    [filename,pathname]=uigetfile('*.cvt',getString(message('Sldv:shared:configComp:PickCoverageDataFile')),currFile);
                                    cd(currWD);
                                    path(currPath);

                                    if~isequal(filename,0)&&~isequal(pathname,0)
                                        newFile=fullfile(pathname,filename);
                                        newFile=strrep(newFile,[pwd,filesep],'');
                                        set_param(cs,objProp,newFile);
                                        unchanged_flag=false;

                                        sendToDDUX(cs,objProp,newFile);
                                    else
                                        unchanged_flag=true;
                                    end





                                    function unchanged_flag=TestGenerationPanel_TestDataBrowse_callback(hObj,~,cs,~)



                                        default='';

                                        objProp=[hObj.productTag,'ExistingTestFile'];
                                        val=get_param(cs,objProp);

                                        currPath=path;
                                        currWD=pwd;

                                        [currDir,currName]=fileparts(val);
                                        if~isempty(currDir)
                                            addpath(currDir);
                                        end

                                        currFile=which(currName);

                                        if isempty(currFile)||strcmp(currFile,default)||strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                                            currFile='';
                                            currDir='';
                                        end

                                        if~isempty(currDir)
                                            cd(currDir);
                                        end


                                        testFileDlgFilters={'*.mat','MAT-files (*.mat)';...
                                        '*.xlsx;*.xls','Excel files (*.xlsx, *.xls)'};
                                        [filename,pathname]=uigetfile(testFileDlgFilters,getString(message('Sldv:shared:configComp:PickExistingTestFile')),currFile);
                                        cd(currWD);
                                        path(currPath);

                                        if~isequal(filename,0)&&~isequal(pathname,0)
                                            newFile=fullfile(pathname,filename);
                                            newFile=strrep(newFile,[pwd,filesep],'');
                                            set_param(cs,objProp,newFile);
                                            unchanged_flag=false;

                                            sendToDDUX(cs,objProp,newFile);
                                        else
                                            unchanged_flag=true;
                                        end



                                        function unchanged_flag=TestGenerationPanel_CovFilterFileBrowse_callback(hObj,~,cs,~)



                                            default='';

                                            objProp=[hObj.productTag,'CovFilterFileName'];
                                            val=get_param(cs,objProp);

                                            if slavteng('feature','MultiFilter')&&~isempty(val)
                                                tokens=strsplit(val,',|;','DelimiterType','RegularExpression');
                                                val=tokens{1};
                                            end
                                            [currDir,currName]=fileparts(val);

                                            currPath=path;
                                            currWD=pwd;

                                            if~isempty(currDir)
                                                addpath(currDir);
                                            end

                                            currFile=which(currName);

                                            if isempty(currFile)||strcmp(currFile,default)||strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                                                currFile='';
                                                currDir='';
                                            end

                                            if~isempty(currDir)
                                                cd(currDir);
                                            end

                                            if slavteng('feature','MultiFilter')
                                                [fileNames,pathName]=uigetfile('*.cvf',getString(message('Sldv:shared:configComp:PickExistingFilterFile')),...
                                                currFile,'MultiSelect','on');
                                            else
                                                [fileNames,pathName]=uigetfile('*.cvf',getString(message('Sldv:shared:configComp:PickExistingFilterFile')),...
                                                currFile);
                                            end

                                            cd(currWD);
                                            path(currPath);

                                            if~isequal(fileNames,0)&&~isequal(pathName,0)
                                                newFiles=fullfile(pathName,fileNames);

                                                if slavteng('feature','MultiFilter')
                                                    if iscell(newFiles)
                                                        newVal=strjoin(newFiles,'; ');
                                                    else
                                                        newVal=newFiles;
                                                    end
                                                else
                                                    newVal=newFiles;
                                                end
                                                newVal=strrep(newVal,[pwd,filesep],'');

                                                set_param(cs,objProp,newVal);
                                                unchanged_flag=false;
                                                sendToDDUX(cs,objProp,newFile);
                                            else
                                                unchanged_flag=true;
                                            end


                                            function unchanged_flag=ParametersPanel_RefreshModel_callback(hObj,hDlg,cs,~)


                                                unchanged_flag=true;
                                                progress=showProgressInd(getString(message('Sldv:Parameters:FindingParams')));
                                                mdlH=cs.getModel;

                                                if isempty(mdlH)




                                                    msg=getString(message('Sldv:Parameters:OverrideParameter'));
                                                    sldvshareprivate('local_error_dlg',msg,...
                                                    getString(message('Sldv:Parameters:ErrorInFindParams')));
                                                    return;
                                                end

                                                try
                                                    if isa(cs,'Simulink.ConfigSetRef')
                                                        sldvshareprivate('syncOverrideStatusOfSldvParamTable',cs);
                                                    end
                                                    pmanager=hObj.getParameterManager(mdlH,cs);
                                                    testgenTarget=hObj.get_param('DVTestgenTarget');
                                                    pmanager.refreshConfigParams();
                                                    if strcmp(testgenTarget,'Model')


                                                        addedConstr=pmanager.refreshModelParams();
                                                    else


                                                        cgDirInfo=RTW.getBuildDir(Simulink.ID.getFullName(mdlH));
                                                        ParameterCodeLocation=cgDirInfo.BuildDirectory;
                                                        stopOnWarning=true;
                                                        addedConstr=pmanager.refreshModelParams(stopOnWarning,ParameterCodeLocation);
                                                    end

                                                    if addedConstr
                                                        unchanged_flag=false;
                                                        pmanager.saveToConfig();
                                                    end



                                                    hDlg.getDialogSource.refresh;

                                                catch me
                                                    sldvshareprivate('local_error_dlg',me.message,...
                                                    getString(message('Sldv:Parameters:ErrorInFindParams')));
                                                end

                                                if~isempty(progress)
                                                    progress=[];
                                                end



                                                function unchanged_flag=ParametersPanel_Locate_callback(hObj,hDlg,cs,action)
                                                    unchanged_flag=true;
                                                    pNames=getSelectedParameterNames(hObj,hDlg,cs,action);


                                                    modelH=cs.getModel;

                                                    pmanager=hObj.getParameterManager(modelH,cs);



                                                    all_hilited_blocks=find_system(modelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','off','LookUnderMasks','all','HiliteAncestors','find');
                                                    for idx=1:length(all_hilited_blocks)
                                                        hilite_system(all_hilited_blocks(idx),'none');
                                                    end

                                                    try
                                                        for idx=1:length(pNames)

                                                            locations=pmanager.getParamObjByName(pNames{idx}).Location;

                                                            sortedLocations=sort(locations);

                                                            for i=length(sortedLocations):-1:1
                                                                hilite_system(sortedLocations{i},'find');
                                                            end
                                                        end
                                                    catch me %#ok<NASGU>
                                                        sldvshareprivate('local_error_dlg',getString(message('Sldv:Parameters:ParameterNotInModel',pNames{idx})));
                                                    end



                                                    function unchanged_flag=ParametersPanel_SelectAll_callback(hObj,hDlg,cs,action)
                                                        unchanged_flag=true;
                                                        pNames=getSelectedParameterNames(hObj,hDlg,cs,action);
                                                        if isempty(pNames)
                                                            return;
                                                        end
                                                        mdlH=cs.getModel;

                                                        pmanager=hObj.getParameterManager(mdlH,cs);
                                                        for idx=1:length(pNames)
                                                            pmanager.selectParamForAnalysis(pNames{idx},1);
                                                        end
                                                        pmanager.saveToConfig();
                                                        hDlg.refresh;
                                                        unchanged_flag=false;




                                                        function unchanged_flag=ParametersPanel_DeselectAll_callback(hObj,hDlg,cs,action)
                                                            unchanged_flag=true;
                                                            pNames=getSelectedParameterNames(hObj,hDlg,cs,action);
                                                            if isempty(pNames)
                                                                return;
                                                            end
                                                            mdlH=cs.getModel;

                                                            pmanager=hObj.getParameterManager(mdlH,cs);
                                                            for idx=1:length(pNames)
                                                                pmanager.selectParamForAnalysis(pNames{idx},0);
                                                            end
                                                            pmanager.saveToConfig();
                                                            hDlg.refresh;

                                                            unchanged_flag=false;


                                                            function unchanged_flag=ParametersPanel_Import_callback(hObj,hDlg,cs,~)

                                                                unchanged_flag=true;

                                                                objProp=[hObj.productTag,'ParametersConfigFileName'];
                                                                val=get(hObj,objProp);

                                                                [filename,pathname]=openDirForParameterFile(val,getString(message('Sldv:shared:configComp:PickSldvParamConfigFile')));


                                                                if~isequal(filename,0)
                                                                    newFile=fullfile(pathname,filename);
                                                                    try
                                                                        progress=showProgressInd(getString(message('Sldv:Parameters:ImportingFromFile',filename)));

                                                                        mdlH=cs.getModel;
                                                                        if isa(cs,'Simulink.ConfigSetRef')
                                                                            sldvshareprivate('syncOverrideStatusOfSldvParamTable',cs);
                                                                        end
                                                                        pmanager=hObj.getParameterManager(mdlH,cs);
                                                                        plist=pmanager.getParamsFromFile(newFile);
                                                                        pmanager.importAndMerge(plist);


                                                                        entriesInParamTable=getPrintableParamNamesFromSpec(plist);

                                                                        allOnes=cell(length(entriesInParamTable),1);
                                                                        for i=1:length(entriesInParamTable)
                                                                            allOnes{i}=1;
                                                                        end
                                                                        pmanager.selectParamForAnalysis(entriesInParamTable',allOnes);
                                                                        pmanager.saveToConfig();
                                                                        hDlg.refresh;
                                                                        unchanged_flag=false;
                                                                        progress=[];
                                                                    catch me %#ok<NASGU>
                                                                        progress=[];
                                                                        sldvshareprivate('local_error_dlg',...
                                                                        message('Sldv:Parameters:ErrorInFile',filename).getString);
                                                                    end
                                                                end

                                                                function paramNamesToSelect=getPrintableParamNamesFromSpec(spec)



                                                                    paramNamesToSelect={};
                                                                    if~isempty(spec)
                                                                        currentFields=fieldnames(spec);
                                                                        for idx=1:length(currentFields)
                                                                            topParam=currentFields{idx};
                                                                            if isstruct(spec.(topParam))
                                                                                paramLeavesInTopParam=getPrintableParamNamesFromSpec(spec.(topParam));
                                                                                for jdx=1:length(paramLeavesInTopParam)
                                                                                    paramNamesToSelect{end+1}=strcat(topParam,'.',paramLeavesInTopParam{jdx});%#ok<AGROW>
                                                                                end
                                                                            else
                                                                                paramNamesToSelect{end+1}=topParam;%#ok<AGROW>
                                                                            end
                                                                        end
                                                                    end


                                                                    function unchanged_flag=ParametersPanel_Export_callback(hObj,~,cs,~)
                                                                        [filename,pathname]=uiputfile('*.m',getString(message('Sldv:shared:configComp:PickFileParamConfigExport')));
                                                                        if~isequal(filename,0)
                                                                            exportFile=fullfile(pathname,filename);
                                                                            progress=showProgressInd(getString(message('Sldv:Parameters:WritingToFile')));
                                                                            try
                                                                                mdlH=cs.getModel;

                                                                                pmanager=hObj.getParameterManager(mdlH,cs);
                                                                                pmanager.export(exportFile);
                                                                            catch me
                                                                                if~isempty(progress)
                                                                                    progress=[];
                                                                                end
                                                                                sldvshareprivate('local_error_dlg',...
                                                                                message('Sldv:Parameters:ErrorDuringExport',me.message).getString);
                                                                            end
                                                                            progress=[];
                                                                        end

                                                                        unchanged_flag=true;


                                                                        function unchanged_flag=ParametersPanel_Clear_callback(hObj,hDlg,cs,action)
                                                                            pNames=getSelectedParameterNames(hObj,hDlg,cs,action);

                                                                            mdlH=cs.getModel;

                                                                            pmanager=hObj.getParameterManager(mdlH,cs);
                                                                            pmanager.clearAll(pNames);
                                                                            pmanager.saveToConfig();

                                                                            hDlg.getDialogSource.refresh;
                                                                            unchanged_flag=false;



                                                                            function unchanged_flag=ResultsPanel_DVSaveDataFile_callback(hObj,~,~,~)

                                                                                objPropSaveData=[hObj.productTag,'SaveDataFile'];
                                                                                valSaveData=get(hObj,objPropSaveData);

                                                                                objPropSaveSystemTest=[hObj.productTag,'SaveSystemTestHarness'];
                                                                                valSaveSystemTest=get(hObj,objPropSaveSystemTest);

                                                                                if~valSaveData&&strcmp(valSaveSystemTest,'on')
                                                                                    mdlName=getDriver(hObj);
                                                                                    if~isempty(mdlName)
                                                                                        modelH=get_param(mdlName,'Handle');
                                                                                        settings=Sldv.Options(modelH);
                                                                                        if strcmpi(settings.mode,'TestGeneration')
                                                                                            activityId='t';
                                                                                        else
                                                                                            activityId='p';
                                                                                        end
                                                                                        settings2=settings.deepCopy;
                                                                                        settings2.SaveDataFile='off';
                                                                                        settings2.SaveSystemTestHarness='on';
                                                                                        if isempty(hObj.SubsystemToAnalyze)
                                                                                            blockH=[];
                                                                                        else
                                                                                            blockH=get(hObj.SubsystemToAnalyze,'Handle');
                                                                                        end
                                                                                        [status,errStr]=sldvprivate('checkSldvOptions',settings2,activityId,modelH,blockH,true);
                                                                                        if~status
                                                                                            sldvshareprivate('local_warning_dlg',errStr);
                                                                                        end
                                                                                    else
                                                                                        sldvshareprivate('local_warning_dlg',getString(message('Sldv:shared:configComp:SaveTestHarnessFileOptMustChked')));
                                                                                    end
                                                                                end

                                                                                unchanged_flag=true;


                                                                                function EnableApplyButton(hDlg)

                                                                                    if~isempty(hDlg)&&isa(hDlg,'DAStudio.Dialog')
                                                                                        hDlg.getDialogSource.enableApplyButton(true);
                                                                                    end


                                                                                    function mdlName=getDriver(hObj)

                                                                                        hSrc=hObj.getSourceObject;
                                                                                        if~isempty(hSrc.getModel)
                                                                                            mdl=getModel(hSrc);
                                                                                            mdlName=get_param(mdl,'Name');
                                                                                        else
                                                                                            mdlName='';
                                                                                        end


                                                                                        function out=cr_to_space(in)
                                                                                            out=in;
                                                                                            if~isempty(in)
                                                                                                out(in==10)=char(32);
                                                                                            end


                                                                                            function progressBar=showProgressInd(message)
                                                                                                try

                                                                                                    progressBar=DAStudio.WaitBar;
                                                                                                    progressBar.setWindowTitle(message);
                                                                                                    progressBar.setLabelText(DAStudio.message('Simulink:tools:MAPleaseWait'));
                                                                                                    progressBar.setCircularProgressBar(true);
                                                                                                    progressBar.show();
                                                                                                catch Mex %#ok<NASGU>
                                                                                                    progressBar=[];
                                                                                                end

                                                                                                function selectedParams=getSelectedParameterNames(hObj,~,cs,action)



                                                                                                    selectedRowNumber=action;

                                                                                                    if isempty(selectedRowNumber)
                                                                                                        sldvshareprivate('local_warning_dlg',getString(message('Sldv:Parameters:NothingSelected')));
                                                                                                        selectedParams={};
                                                                                                    else
                                                                                                        mdlH=cs.getModel;


                                                                                                        pmanager=hObj.getParameterManager(mdlH,cs);
                                                                                                        if slavteng('feature','BusParameterTuning')


                                                                                                            pdata=pmanager.getFlatListOfParams();

                                                                                                            pnames={pdata.name};
                                                                                                        else
                                                                                                            pdata=pmanager.getAllParams;
                                                                                                            pnames=fieldnames(pdata);
                                                                                                        end
                                                                                                        selectedParams=pnames(selectedRowNumber+1);
                                                                                                    end

                                                                                                    function[file,fullpath]=openDirForParameterFile(val,message)



                                                                                                        default=fullfile(matlabroot,'toolbox','sldv','sldv','sldv_params_template.m');


                                                                                                        currPath=path;
                                                                                                        currWD=pwd;

                                                                                                        [fileDir,fileName]=fileparts(val);



                                                                                                        if~isempty(fileDir)&&exist(fileDir,'dir')==7
                                                                                                            addpath(fileDir);
                                                                                                        end

                                                                                                        currFile=which(fileName);



                                                                                                        if isempty(currFile)||strcmp(currFile,default)||strcmp(currFile,'built-in')||strcmp(currFile,'variable')
                                                                                                            fullFileDir='';
                                                                                                        else
                                                                                                            fullFileDir=fileparts(currFile);
                                                                                                        end

                                                                                                        if~isempty(fullFileDir)
                                                                                                            cd(fullFileDir);
                                                                                                        end


                                                                                                        [file,fullpath]=uigetfile('*.m',message,fullFileDir);



                                                                                                        cd(currWD);
                                                                                                        path(currPath);

                                                                                                        function cleanTimer(hDlg)
                                                                                                            try
                                                                                                                tmr=getappdata(hDlg,'Launcher');
                                                                                                                tListener=getappdata(hDlg,'ExecListener');


                                                                                                                if~isempty(tListener)
                                                                                                                    clear('tListener');
                                                                                                                end


                                                                                                                if~isempty(tmr)
                                                                                                                    if tmr.isRunning
                                                                                                                        stop(tmr);
                                                                                                                    end
                                                                                                                    clear('tmr');
                                                                                                                end
                                                                                                            catch



                                                                                                            end


                                                                                                            function sendToDDUX(cs,paramName,paramValue)
                                                                                                                if slfeature('ConfigsetDDUX')==1
                                                                                                                    dH=cs.getDialogHandle;
                                                                                                                    if(isa(dH,'DAStudio.Dialog'))
                                                                                                                        htmlView=dH.getDialogSource;
                                                                                                                        data=struct;
                                                                                                                        data.paramName=paramName;
                                                                                                                        data.paramValue=paramValue;
                                                                                                                        data.widgetType='browse';
                                                                                                                        htmlView.publish('sendToDDUX',data);
                                                                                                                    end
                                                                                                                end


