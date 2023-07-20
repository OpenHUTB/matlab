function toggleCheckResultOverlay(mode)




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isempty(mdladvObj)
        return
    end
    memenus=mdladvObj.MEmenus;
    switch mode
    case 'Prompt'
        if isfield(memenus,'ShowResultPrompt')&&isprop(memenus.ShowResultPrompt,'on')
            if strcmp(memenus.ShowResultPrompt.on,'on')
                mdladvObj.ShowResultOnPrompt=true;
            else
                mdladvObj.ShowResultOnPrompt=false;
            end
        end
    case 'GUI'
        if isfield(memenus,'ShowInformerGUI')&&isprop(memenus.ShowInformerGUI,'on')
            if strcmp(memenus.ShowInformerGUI.on,'on')

                am=Advisor.Manager.getInstance;
                allApplications=am.ApplicationObjMap.values;
                for i=1:length(allApplications)
                    loopmdladvObj=allApplications{i}.getRootMAObj();
                    if isa(loopmdladvObj,'Simulink.ModelAdvisor')&&isprop(loopmdladvObj,'ResultGUI')&&isa(loopmdladvObj.ResultGUI,'DAStudio.Informer')...
                        &&strcmp(bdroot(loopmdladvObj.SystemName),bdroot(mdladvObj.SystemName))&&~strcmp(loopmdladvObj.SystemName,mdladvObj.SystemName)
                        disp(DAStudio.message('ModelAdvisor:engine:HiliteWindowALreadyExists'));
                        memenus.ShowInformerGUI.on='off';
                        return







                    end
                end

                mdladvObj.ShowInformer=true;
                setpref('modeladvisor','ShowInformer',mdladvObj.ShowInformer);
                memenus.ShowInformerGUI.toolTip=DAStudio.message('ModelAdvisor:engine:MADisableHighlighting');
                memenus.ShowInformerGUI.Text=DAStudio.message('ModelAdvisor:engine:MADashboardUnHighlight');
                memenus.ShowExclusionsGUI.enable='on';
                memenus.ShowCheckResultsGUI.enable='on';
                me=mdladvObj.MAExplorer;
                if isa(me,'DAStudio.Explorer')
                    imme=DAStudio.imExplorer(me);
                    selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
                    selectedNode.updateResultGUI;

                    skipBringForeground=false;
                    [fInfo1,~]=dbstack;
                    for i=1:length(fInfo1)
                        if~(isempty(strfind(fInfo1(i).file,'openModelAdvisorComplianceResultsInEditor'))&&...
                            isempty(strfind(fInfo1(i).file,'openModelAdvisorResultsInEditor'))&&...
                            isempty(strfind(fInfo1(i).file,'openModelAdvisorResultsComponent')))
                            skipBringForeground=true;
                            break;
                        end
                    end
                    if~skipBringForeground
                        open_system(mdladvObj.SystemName);
                    end
                end
            else
                mdladvObj.ShowInformer=false;
                setpref('modeladvisor','ShowInformer',mdladvObj.ShowInformer);
                memenus.ShowInformerGUI.toolTip=DAStudio.message('ModelAdvisor:engine:MAEnableHighlighting');
                memenus.ShowInformerGUI.Text=DAStudio.message('ModelAdvisor:engine:MADashboardHighlight');
                memenus.ShowExclusionsGUI.enable='off';
                memenus.ShowCheckResultsGUI.enable='off';
                if isa(mdladvObj.ResultGUI,'DAStudio.Informer')
                    modeladvisorprivate('modeladvisorutil2','CloseResultGUICallback');
                    mdladvObj.ResultGUI.delete;
                end

                editor=GLUE2.Util.findAllEditors(mdladvObj.SystemName);
                if~isempty(editor)
                    editor.closeNotificationByMsgID('modeladvisor.highlight.openconfigset');
                end
            end
        end
    case 'Exclusion'
        if isfield(memenus,'ShowExclusionsGUI')&&isprop(memenus.ShowExclusionsGUI,'on')
            if strcmp(memenus.ShowExclusionsGUI.on,'on')
                mdladvObj.ShowExclusionsOnGUI=true;
            else
                mdladvObj.ShowExclusionsOnGUI=false;
            end
            setpref('modeladvisor','ShowExclusionsOnGUI',mdladvObj.ShowExclusionsOnGUI);
            me=mdladvObj.MAExplorer;
            if isa(me,'DAStudio.Explorer')
                imme=DAStudio.imExplorer(me);
                selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
                selectedNode.updateResultGUI;
            end
        end
    case 'CheckResult'
        if isfield(memenus,'ShowCheckResultsGUI')&&isprop(memenus.ShowCheckResultsGUI,'on')
            if strcmp(memenus.ShowCheckResultsGUI.on,'on')
                mdladvObj.ShowCheckResultsOnGUI=true;
            else
                mdladvObj.ShowCheckResultsOnGUI=false;
            end
            setpref('modeladvisor','ShowCheckResultsOnGUI',mdladvObj.ShowCheckResultsOnGUI);
            me=mdladvObj.MAExplorer;
            if isa(me,'DAStudio.Explorer')
                imme=DAStudio.imExplorer(me);
                selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
                selectedNode.updateResultGUI;
            end
        end
    end
