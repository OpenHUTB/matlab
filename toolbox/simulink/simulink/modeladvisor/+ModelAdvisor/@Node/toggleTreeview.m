function toggleTreeview(toggleNode)




    mp=ModelAdvisor.Preferences;
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    am=Advisor.Manager.getInstance;
    applicationObjs=am.ApplicationObjMap.values;
    if length(applicationObjs)>1
        for i=1:length(applicationObjs)
            mdladvObj=applicationObjs{i}.getRootMAObj;
            process_each_obj(mdladvObj,mp,toggleNode);
        end
    else
        process_each_obj(mdladvObj,mp,toggleNode);
    end

    function process_each_obj(mdladvObj,mp,toggleNode)
        if~(isa(mdladvObj,'Simulink.ModelAdvisor')&&isa(mdladvObj.MAExplorer,'DAStudio.Explorer')&&mdladvObj.MAExplorer.isVisible)
            return
        end

        if strcmp(toggleNode,'ByProduct')
            if isempty(mdladvObj.ConfigFilePath)
                ByPNode=mdladvObj.getTaskObj('_SYSTEM_By Product');
                if~isempty(ByPNode)
                    if mp.ShowByProduct
                        modeladvisorprivate('modeladvisorutil2','dynamic_attach_node',ByPNode.ParentObj,ByPNode);
                    else
                        modeladvisorprivate('modeladvisorutil2','dynamic_detach_node',ByPNode.ParentObj,ByPNode);
                    end
                    edp=DAStudio.EventDispatcher;
                    edp.broadcastEvent('HierarchyChangedEvent',mdladvObj.MAExplorer.getRoot);
                end
            end
        elseif strcmp(toggleNode,'ByTask')
            if isempty(mdladvObj.ConfigFilePath)
                ByTNode=mdladvObj.getTaskObj('_SYSTEM_By Task');
                if~isempty(ByTNode)
                    if mp.ShowByTask
                        modeladvisorprivate('modeladvisorutil2','dynamic_attach_node',ByTNode.ParentObj,ByTNode);
                    else
                        modeladvisorprivate('modeladvisorutil2','dynamic_detach_node',ByTNode.ParentObj,ByTNode);
                    end
                    edp=DAStudio.EventDispatcher;
                    edp.broadcastEvent('hierarchyChangedEvent',mdladvObj.MAExplorer.getRoot);
                end
            end
        elseif strcmp(toggleNode,'SourceTab')
            mdladvObj.ShowSourceTab=mp.ShowSourceTab;
            imme=DAStudio.imExplorer(mdladvObj.MAExplorer);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',selectedNode);
        elseif strcmp(toggleNode,'ExclusionTab')
            mdladvObj.ShowExclusionTab=mp.ShowExclusionTab;
            imme=DAStudio.imExplorer(mdladvObj.MAExplorer);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',selectedNode);
        elseif strcmp(toggleNode,'Exclusions')
            mdladvObj.ShowExclusions=mp.ShowExclusionsInRpt;
        elseif strcmp(toggleNode,'Accordion')
            if mp.ShowAccordion
                for i=1:length(mdladvObj.advertisements)
                    if(mdladvObj.advertisements(i).visible)
                        mdladvObj.MAExplorer.addAccordionPane(mdladvObj.advertisements(i).id,...
                        mdladvObj.advertisements(i).DisplayName,...
                        mdladvObj.advertisements(i).icon,...
                        mdladvObj.advertisements(i).Description);
                        mdladvObj.advertisements(i).OnGUI=true;
                    end
                end
            else
                for i=1:length(mdladvObj.advertisements)
                    if(mdladvObj.advertisements(i).OnGUI)
                        mdladvObj.MAExplorer.removeAccordionPane(mdladvObj.Advertisements(i).id);
                        mdladvObj.advertisements(i).OnGUI=false;
                    end
                end
            end
        end
