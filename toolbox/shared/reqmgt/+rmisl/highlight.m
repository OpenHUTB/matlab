function result=highlight(modelH,refresh_reqsys_contents)



    try
        if nargin<2
            refresh_reqsys_contents=false;
        end

        if rmisl.isComponentHarness(modelH)

            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelH);
            mainModel=bdroot(harnessInfo.ownerHandle);
            mainModelHighlighted=strcmp(get_param(mainModel,'ReqHilite'),'on');
            if~mainModelHighlighted

                SLStudio.Utils.RemoveHighlighting(mainModel);
                set_param(mainModel,'ReqHilite','on');
                result=true;
                return;
            else


                doCheckForHarnesses=false;
            end
        else
            doCheckForHarnesses=true;
        end

        rmiut.progressBarFcn('set',0,...
        getString(message('Slvnv:rmiut:progressBar:HighlightPleaseWait')),...
        getString(message('Slvnv:rmiut:progressBar:HighlightTitle')));




        find_system(gcs,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LoadFullyIfNeeded','on','FollowLinks','on','LookUnderMasks','all','RequirementInfo',' ');


        rmiut.progressBarFcn('set',0.2,getString(message('Slvnv:rmiut:progressBar:HighlightCheckForLinks')));


        filterSettings=rmi.settings_mgr('get','filterSettings');


        [slHs,sfHs,sfFade,indirectHs]=rmisl.getHandlesForHighlighting(modelH,filterSettings);




        msystemsWithLinks=rmisl.getMSystemBlocksWithLinks(modelH,filterSettings);
        if~isempty(msystemsWithLinks)
            indirectHs=[indirectHs;msystemsWithLinks];
        end


        rmiut.progressBarFcn('set',0.6,getString(message('Slvnv:rmiut:progressBar:HighlightDefaultColors')));
        set_param(modelH,'HiliteAncestors','fade');
        action_highlight('purge');

        if doCheckForHarnesses
            activeHarness=Simulink.harness.internal.getActiveHarness(modelH);
            hasActiveHarness=~isempty(activeHarness);
        else
            hasActiveHarness=false;
        end



        mainModelNoLinks=(length(slHs)+length(sfHs)+length(indirectHs)==0);
        if mainModelNoLinks
            if rmi.settings_mgr('get','reportSettings','toolsReqReport')
                result=true;
            else
                result=rmisl.showNoLinksDlg(modelH,getString(message('Slvnv:reqmgt:highlightObjectsWithReqs')));
            end
        else


            for i=1:length(indirectHs)
                if floor(indirectHs(i))==indirectHs(i)
                    continue;
                end
                highlightOneObject(indirectHs(i),'reqInside',hasActiveHarness);


                try
                    mdlName=get_param(indirectHs(i),'ModelName');
                    mdlH=get_param(mdlName,'Handle');
                    set_param(mdlH,'ReqHilite','on');
                catch ex %#ok<NASGU>
                end
            end


            rmiut.progressBarFcn('set',0.7,getString(message('Slvnv:rmiut:progressBar:HighlightSimulink')));
            for i=1:length(slHs)
                if slHs(i)~=modelH
                    if rmisl.is_signal_builder_block(slHs(i))||strcmp(get_param(slHs(i),'Type'),'annotation')
                        highlightOneObject(slHs(i),'reqInside',hasActiveHarness);
                    else
                        highlightOneObject(slHs(i),'reqHere',hasActiveHarness);
                    end
                end
            end


            if license('test','Stateflow')&&exist('sf','file')&&(~isempty(sfHs)||~isempty(sfFade))
                rmiut.progressBarFcn('set',0.8,getString(message('Slvnv:rmiut:progressBar:HighlightStateflow')));
                modelName=get_param(modelH,'Name');
                rmisf.highlight(sfHs,sfFade,modelName,'req');

                if~isempty(slHs)
                    modelObj=get_param(modelH,'Object');


                    slFunctions=find(modelObj,'-isa','Stateflow.SLFunction');
                    for i=1:length(slFunctions)
                        slColor=slFunctions(i).getDialogProxy.HiliteAncestors;
                        if any(strcmp(slColor,{'reqHere','reqInside'}))
                            sf_update_style(slFunctions(i).Id,'req');
                        end
                    end


                    actionStates=find(modelObj,'-isa','Stateflow.SimulinkBasedState');
                    for i=1:length(actionStates)
                        acColor=actionStates(i).getDialogProxy.HiliteAncestors;
                        if any(strcmp(acColor,{'reqHere','reqInside'}))
                            sf_update_style(actionStates(i).Id,'req');
                        end
                    end
                end
            end


            rmiut.progressBarFcn('set',0.9,getString(message('Slvnv:rmiut:progressBar:HighlightDisplayBlocks')));
            rmidispblock('updateall',modelH,refresh_reqsys_contents);
            result=true;
        end

        if hasActiveHarness
            rmiut.progressBarFcn('set',0.95,'Highlighting Harness Diagram objects');
            hasHighlights=rmisl.highlightHarnessObjects(activeHarness.name);
            if hasHighlights&&mainModelNoLinks
                rmiut.closeDlg(getString(message('Slvnv:reqmgt:highlightObjectsWithReqs')));
            end
        end

        rmiut.progressBarFcn('delete');

    catch ex
        rmiut.progressBarFcn('delete');

        rmiut.warnNoBacktrace(ex.message);
        result=false;
    end
end

function highlightOneObject(obj,style,hasActiveHarness)
    set_param(obj,'HiliteAncestors',style);
    if hasActiveHarness
        slObj=get_param(obj,'Object');
        if~rmisl.isComponentHarness(strtok(slObj.Parent,'/'))
            harnessObjSid=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(slObj);
            if~isempty(harnessObjSid)
                try
                    harnessH=Simulink.ID.getHandle(harnessObjSid);
                catch ME
                    if strcmp(ME.identifier,'Simulink:utility:objectDestroyed')




                        return;
                    else
                        rethrow(ME);
                    end
                end
                set_param(harnessH,'HiliteAncestors',style);
            end
        end
    end
end


