function playAll(dialog)




    UD=get(dialog,'UserData');





    if is_simulating_l(UD)
        return;
    end
    set(UD.toolbar.playall,'Enable','off');
    set(UD.dialog,'Pointer','watch');
    modelH=UD.simulink.modelH;
    testCnt=length(UD.dataSet);
    UD.current.simMode='PlayAll';



    if strcmpi(strtok(get_param(UD.simulink.modelH,'StopTime')),'inf')
        errordlg(getString(message('sigbldr_blk:playAll:NoInfiniteTime')));
    else
        if is_cv_licensed&&exist('cvsim','file')>0&&...
            strcmp(get_param(UD.simulink.modelH,'SimulationMode'),'normal')&&...
            ~builtin('_license_checkout',SlCov.CoverageAPI.getLicenseName,'quiet')


            covPath=get_param(UD.simulink.modelH,'CovPath');
            if~strcmp(covPath,'/')
                try
                    covObj=get_param(cvi.TopModelCov.checkCovPath(get_param(UD.simulink.modelH,'Name'),covPath),'Handle');
                catch playAllCovError %#ok<NASGU>

                    covObj=modelH;
                end
            else
                covObj=modelH;
            end

            simOk=1;
            oldWarnState=warning('query');
            warning('off','all');
            covdata=cell(testCnt,1);
            for testIdx=1:testCnt
                UD=dataSet_activate(UD,testIdx);
                sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);
                set(UD.dialog,'UserData',UD);
                test=cvtest(covObj);
                errmsg='';
                try
                    [covdata{testIdx},simout]=cvsim(test,'ReturnWorkspaceOutputs','on');
                    helperPopulateSDI(simout,modelH,UD);
                catch mex
                    covdata{testIdx}=[];
                    [~,errMessage]=slprivate('getAllErrorIdsAndMsgs',mex,'concatenateIdsAndMsgs',true);
                    errMessage=slprivate('removeHyperLinksFromMessage',errMessage);
                    errmsg=getString(message('sigbldr_blk:playAll:CVSimFailure',errMessage));
                end

                if~UD.current.simWasStopped&&~isempty(errmsg)
                    set(UD.toolbar.playall,'Enable','on');

                    simOk=0;
                    errordlg(errmsg);
                    break;
                end


                UD=get(UD.dialog,'UserData');
                if(UD.current.simWasStopped)
                    break
                end
            end
            warning(oldWarnState);

            if(~UD.current.simWasStopped&&simOk&&~isempty([covdata{:}]))
                covTotal=cvi.TopModelCov.genResultsForSigbuilder(modelH,UD.simulink.subsysH,covdata);
            end




            exportTotal=0;
            if evalin('base','exist(''performing_sltestgen_testing'')')
                exportTotal=evalin('base','performing_sltestgen_testing');
            end

            if exportTotal
                assignin('base','tvg_sigbuilder_total_cov',covTotal);
            end


        else



            covStatus=get_param(modelH,'RecordCoverage');
            covmdlRefStatus=get_param(modelH,'CovModelRefEnable');
            if strcmpi(covStatus,'on')||~strcmpi(covmdlRefStatus,'off')
                dirtyStatus=get_param(modelH,'Dirty');
                set_param(modelH,'RecordCoverage','off');
                set_param(modelH,'CovModelRefEnable','off');
            end

            for testIdx=1:testCnt
                UD=dataSet_activate(UD,testIdx);
                sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);
                set(UD.dialog,'UserData',UD);
                try
                    simout=sim(get_param(modelH,'Name'),'ReturnWorkspaceOutputs','on');
                    helperPopulateSDI(simout,modelH,UD);
                catch simError
                    errordlg(getString(message('sigbldr_blk:playAll:SimFailure',simError.message)));
                    break;
                end


                UD=get(UD.dialog,'UserData');
                if(UD.current.simWasStopped)
                    break
                end
            end
            if strcmpi(covStatus,'on')||~strcmpi(covmdlRefStatus,'off')
                set_param(modelH,'RecordCoverage',covStatus);
                set_param(modelH,'CovModelRefEnable',covmdlRefStatus);
                set_param(modelH,'Dirty',dirtyStatus);
            end

        end
        UD.current.simMode='';
        UD.current.simWasStopped=0;
    end




    if ishghandle(dialog,'figure')
        set(dialog,'UserData',UD);
    end

end


function helperPopulateSDI(simout,modelH,UD)
    try

        bHasLoggedData=~isempty(simout.get);




        mdlName=get_param(modelH,'Name');
        hCs=getActiveConfigSet(mdlName);
        status=hCs.get_param('InspectSignalLogs');
        sdiEngine=Simulink.sdi.Instance.engine;
        try
            bFPTEnabled=fxptui.isFPTEnabledForSignalLogging(mdlName);
        catch me %#ok<NASGU>
            bFPTEnabled=false;
        end
        bImportLogged=sdiEngine.isRecording||strcmp(status,'on')||bFPTEnabled;


        if bImportLogged&&bHasLoggedData
            Simulink.sdi.view;
        end


        tabNumber=UD.current.dataSetIdx;
        tabName=UD.dataSet(tabNumber).name;
        dataRunName=[sdiEngine.runNameTemplate,' : ',tabName];


        sdiEngine=Simulink.sdi.Instance.engine;
        storedRun=Simulink.sdi.getCurrentSimulationRun(mdlName,'',false);
        if~isempty(storedRun)
            storedRun.Name=dataRunName;
            if bImportLogged&&bHasLoggedData
                sdiEngine.addToRunFromNamesAndValues(storedRun.id,...
                {'simout'},...
                {simout},mdlName);

            end
            sdiEngine.notifyAppsOfNewRun(storedRun.id,mdlName);
        elseif bImportLogged&&bHasLoggedData
            sdiEngine.createRunFromNamesAndValues(dataRunName,...
            {'simout'},...
            {simout},mdlName);
        end


        if(bImportLogged&&bHasLoggedData)||(storedRunID~=0)
            Simulink.sdi.internal.SLMenus.getSetNewDataAvailable(mdlName,true);
        end
    catch me %#ok<NASGU>

    end
end
