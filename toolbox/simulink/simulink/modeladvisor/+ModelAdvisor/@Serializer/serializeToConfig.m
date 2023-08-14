function out=serializeToConfig(this,inpObj)

    am=Advisor.Manager.getInstance;

    if isa(inpObj,'ModelAdvisor.Check')
        taskNode=ModelAdvisor.Task([inpObj.ID,'_',inpObj.ID]);
        taskNode.DisplayName=inpObj.Title;
        taskNode.Description=inpObj.TitleTips;
        taskNode.MAC=inpObj.ID;
        taskNode.Enable=inpObj.Enable;
        taskNode.Check=inpObj;
        taskNode.MACIndex=am.slCustomizationDataStructure.CheckIDMap(inpObj.ID);
    else
        taskNode=inpObj;
    end
    ConfigUIRoot=ModelAdvisor.Group('_SYSTEM');
    ConfigUIRoot.DisplayName=DAStudio.message('Simulink:tools:MACETitle');
    ConfigUIRoot.ChildrenObj{end+1}=taskNode;
    ConfigUIRoot.Children{end+1}=inpObj.ID;
    nodes=this.serializeNode(ConfigUIRoot);
    nodes(1).parent=NaN;
    jsondata.Tree=nodes;
    out=jsonencode(jsondata,'PrettyPrint',true);
end
