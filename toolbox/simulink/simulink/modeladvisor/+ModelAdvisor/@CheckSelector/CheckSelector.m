



classdef CheckSelector<handle
    properties(Access=private)
        checkIDList={};
        checkNameList={};
        mdlName='';
    end

    properties(Access=public)
        fDialogHandle;
        cbinfo=[];
        eventListener=[];
    end

    methods(Access=public)
        show(aObj);
    end

    methods(Static=true)



        function instance=getInstance(mdlName,cbinfo)
            instance=ModelAdvisor.CheckSelector.findExistingDlg(mdlName);
            if isempty(instance)
                instance=ModelAdvisor.CheckSelector(mdlName,cbinfo);
            else
                instance.cbinfo=cbinfo;
            end
        end




        function checkSelector=findExistingDlg(modelName)
            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs;
            checkSelector=[];
            dialogtag=['ModelAdvisor.CheckSelector_',modelName];
            for idx=1:numel(dlgs)
                if strcmp(dlgs(idx).dialogTag,dialogtag)
                    dlg=dlgs(idx);
                    checkSelector=dlg.getSource;
                    break;
                end
            end
        end
    end

    methods(Access=public)
        function obj=CheckSelector(mdlName,cbinfo)
            obj.mdlName=mdlName;
            [tcheckIDList,tcheckNameList]=extractCheckIDsFromConfig();


            removeChecks={};
            if isa(cbinfo.userdata.exclusionEditor,'ModelAdvisor.ExclusionEditor')&&isKey(cbinfo.userdata.exclusionEditor.exclusionState,cbinfo.userdata.exclusionEditor.getPropKey(cbinfo.userdata.prop))
                val=cbinfo.userdata.exclusionEditor.exclusionState(cbinfo.userdata.exclusionEditor.getPropKey(cbinfo.userdata.prop));
                for i=1:length(val)
                    removeChecks=[removeChecks,val.checkIDs];%#ok<AGROW>
                end
            end
            [tcheckIDList,sortIdx]=setdiff(tcheckIDList,removeChecks);
            if~isempty(sortIdx)
                tcheckNameList=tcheckNameList(sortIdx);
            end
            obj.checkNameList=tcheckNameList;
            obj.checkIDList=tcheckIDList;
            obj.cbinfo=cbinfo;
            setEventHandler(obj);
        end

        function out=getMdlName(aObj)
            out=aObj.mdlName;
        end

        function out=getDialogTag(aObj)
            out=[class(aObj),'_',aObj.getMdlName];
        end

        function checkIDList=getCheckIDList(aObj)
            checkIDList=aObj.checkIDList;
        end

        function checkNameList=getCheckNameList(aObj)
            checkNameList=aObj.checkNameList;
        end

        function out=getSelectedCheckIDs(aObj)
            idx=aObj.fDialogHandle.getWidgetValue('checkIDListTag');
            out=aObj.checkIDList(idx+1);
        end
    end
end

function[addCheckIDs,addCheckNames]=extractCheckIDsFromConfig()
    am=Advisor.Manager.getInstance;
    if isempty(am.slCustomizationDataStructure.CheckIDMap)
        am.loadslCustomization;
    end
    ByProductNode=am.slCustomizationDataStructure.TaskAdvisorCellArray{am.slCustomizationDataStructure.libtopLevelWorkFlows{1}};
    [addCheckIDs,addCheckNames]=createConfig(ByProductNode,{},{});
end

function[checkIDList,checkTitle]=createConfig(currentNode,checkIDList,checkTitle)
    if isempty(currentNode)
        return;
    end
    if isa(currentNode,'ModelAdvisor.Task')
        checkIDList=[checkIDList,currentNode.MAC];
        if~isempty(currentNode.MAC)&&isempty(currentNode.DisplayName)
            checkTitle=[checkTitle,{''}];
        else
            checkTitle=[checkTitle,currentNode.DisplayName];
        end
    else
        for i=1:length(currentNode.ChildrenObj)
            [checkIDList,checkTitle]=createConfig(currentNode.ChildrenObj{i},checkIDList,checkTitle);
        end
    end
end
