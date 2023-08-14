function moveup




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.ConfigUIWindow;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if~isa(selectedNode,'ModelAdvisor.ConfigUI')
            return
        end

        ModelAdvisor.ConfigUI.stackoperation('push');

        if~isempty(selectedNode.ParentObj)
            newChildrenObj={};
            for j=1:length(selectedNode.ParentObj.ChildrenObj)
                if strcmp(selectedNode.ParentObj.ChildrenObj{j}.ID,selectedNode.ID)&&j~=1
                    temp=newChildrenObj{end};
                    newChildrenObj{end}=selectedNode.ParentObj.ChildrenObj{j};
                    newChildrenObj{end+1}=temp;
                else
                    newChildrenObj{end+1}=selectedNode.ParentObj.ChildrenObj{j};%#ok<AGROW>
                end
            end
            selectedNode.ParentObj.ChildrenObj=newChildrenObj;
        end
        modeladvisorprivate('modeladvisorutil2','UpdateConfigUIMenuToolbar',me);
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',me.getRoot);
    end
