function newfolder




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.ConfigUIWindow;
    if isa(me,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if~isa(selectedNode,'ModelAdvisor.ConfigUI')
            return
        end
        if~strcmp(selectedNode.Type,'Group')
            selectedNode=selectedNode.ParentObj;
        end
        if strcmp(selectedNode.Type,'Group')
            ModelAdvisor.ConfigUI.stackoperation('push');
            temp=ModelAdvisor.ConfigUI;


            newname='new folder';
            index=1;
            dupNameObj=[];
            if~isempty(selectedNode.getChildren)
                dupNameObj=findobj([selectedNode.getChildren],'DisplayName',newname);
            end
            while~isempty(dupNameObj)
                newname=['new folder',num2str(index)];
                index=index+1;
                dupNameObj=findobj([selectedNode.getChildren],'DisplayName',newname);
            end
            temp.DisplayName=newname;

            temp.Type='Group';
            if temp.attach(selectedNode,length(selectedNode.ChildrenObj)+1)
                mdladvObj.ConfigUICellArray{end+1}=temp;
                mdladvObj.ConfigUIDirty=true;
            else
                warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MACENoDuplicateName',temp.DisplayName));
                set(warndlgHandle,'Tag','MACENoDuplicateName');
                mdladvObj.DialogCellArray{end+1}=warndlgHandle;
            end
        end
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',me.getRoot);
    end
