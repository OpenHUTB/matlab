function edittimeCheckData=createEdittimeCheckData(node)


    if isa(node,'ModelAdvisor.Check')
        node=getTaskObjForTheCheckObj(node);
    end
    srl=ModelAdvisor.Serializer;
    edittimeCheckData=srl.serializeNode(node);
    edittimeCheckData.check=true;
end


function taskobj=getTaskObjForTheCheckObj(checkObj)
    am=Advisor.Manager.getInstance;
    taskobj=ModelAdvisor.Task([checkObj.ID]);
    taskobj.DisplayName=checkObj.Title;
    taskobj.Description=checkObj.TitleTips;
    taskobj.MAC=checkObj.ID;
    taskobj.Enable=checkObj.Enable;
    taskobj.Check=checkObj;
    taskobj.MACIndex=am.slCustomizationDataStructure.CheckIDMap(checkObj.ID);
end