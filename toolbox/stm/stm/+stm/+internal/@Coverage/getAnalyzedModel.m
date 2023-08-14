

function analyzedModel=getAnalyzedModel(cvdataObj,ownerType,ownerFullPath)
    if strcmp(ownerType,'Simulink.SubSystem')&&...
        ~isempty(strfind(cvdataObj.modelinfo.analyzedModel,'/'))

        analyzedModel=ownerFullPath;
    elseif strcmp(ownerType,'Simulink.BlockDiagram')&&stm.internal.Coverage.isModel(ownerFullPath)
        harnessList=sltest.harness.find(ownerFullPath,...
        'Name',cvdataObj.modelinfo.analyzedModel);
        if isempty(harnessList)
            analyzedModel=cvdataObj.modelinfo.analyzedModel;
        else

            analyzedModel=ownerFullPath;
        end
    else
        analyzedModel=cvdataObj.modelinfo.analyzedModel;
    end
end
