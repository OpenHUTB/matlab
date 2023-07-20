function movedown




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
            for j=1:length(selectedNode.ParentObj.ChildrenObj)
                if strcmp(selectedNode.ParentObj.ChildrenObj{j}.ID,selectedNode.ID)
                    break;
                end
            end
            if j~=length(selectedNode.ParentObj.ChildrenObj)
                temp=selectedNode.ParentObj.ChildrenObj{j+1};
                selectedNode.ParentObj.ChildrenObj{j+1}=selectedNode.ParentObj.ChildrenObj{j};
                selectedNode.ParentObj.ChildrenObj{j}=temp;
            end
        end
        modeladvisorprivate('modeladvisorutil2','UpdateConfigUIMenuToolbar',me);
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',me.getRoot);
    end
