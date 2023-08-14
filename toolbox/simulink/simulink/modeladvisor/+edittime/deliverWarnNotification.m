

function deliverWarnNotification(checkID,model)

    checkName=checkID;
    am=Advisor.Manager.getInstance;
    if am.slCustomizationDataStructure.CheckIDMap.isKey(checkID)
        checkIndex=am.slCustomizationDataStructure.CheckIDMap(checkID);
        if isfield(am.slCustomizationDataStructure,'checkCellArray')&&numel(am.slCustomizationDataStructure.checkCellArray)>=checkIndex
            checkName=am.slCustomizationDataStructure.checkCellArray{checkIndex}.Title;
            checkName=[checkName,'(',checkID,')'];
        end
    end
    e=GLUE2.Util.findAllEditors(model);
    e.deliverWarnNotification('edittime:warn:timeoutcheck',DAStudio.message('ModelAdvisor:engine:WarnDisabledEdittimeCheckBannerMsg',checkName,checkID));
end