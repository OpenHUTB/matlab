function pastegui




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    me=mdladvObj.ConfigUIWindow;
    if isa(me,'DAStudio.Explorer')&&~isempty(mdladvObj.ConfigUICopyObj)
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if~isa(selectedNode,'ModelAdvisor.ConfigUI')
            return
        end
        if~strcmp(selectedNode.Type,'Group')

            for i=1:length(selectedNode.ParentObj.Childrenobj)
                if strcmp(selectedNode.ParentObj.Childrenobj{i}.ID,selectedNode.ID)
                    break
                end
            end
            position=i+1;
            selectedNode=selectedNode.ParentObj;
        else
            position=length(selectedNode.Childrenobj)+1;
        end
        temp=copytree(mdladvObj.ConfigUICopyObj{1});
        ModelAdvisor.ConfigUI.stackoperation('push');
        if temp{1}.attach(selectedNode,position);
            mdladvObj.ConfigUICellArray=[mdladvObj.ConfigUICellArray,temp];
        else
            warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MACENoDuplicateName',temp{1}.DisplayName));
            set(warndlgHandle,'Tag','MACENoDuplicateName');
            mdladvObj.DialogCellArray{end+1}=warndlgHandle;
        end





    else
        disp(DAStudio.message('ModelAdvisor:engine:NothingToPaste'));
    end
