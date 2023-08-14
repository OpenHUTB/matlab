function defineEmptyVariantObjectUsageCheck()








    emptyVarObjCheck=ModelAdvisor.Check('mathworks.design.emptyVariantObject');
    emptyVarObjCheck.Title=DAStudio.message('Simulink:Variants:UAEmptyVarObjCheckTitle');
    emptyVarObjCheck.TitleTips=DAStudio.message('Simulink:Variants:UAEmptyVarObjCheckTitleTips');
    emptyVarObjCheck.setCallbackFcn(@ExecCheckListEmptyObjects,'None','StyleOne');

    emptyVarObjCheck.Visible=true;
    emptyVarObjCheck.Enable=true;
    emptyVarObjCheck.Value=true;


    emptyVarObjCheck.CSHParameters.MapKey='ma.simulink';
    emptyVarObjCheck.CSHParameters.TopicID='UACheckEmptyVarObjTitle';
    emptyVarObjCheck.SupportLibrary=true;



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(emptyVarObjCheck);

end









function ResultDescription=ExecCheckListEmptyObjects(system)
    ResultDescription={};
    ResultStatus=false;
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(ResultStatus);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    setTableTitle(ft,DAStudio.message('Simulink:Variants:UAEmptyVarObjTableTitle'));
    setColTitles(ft,{DAStudio.message('Simulink:Variants:UAEmptyVarObjTableColumnOneHeading'),...
    DAStudio.message('Simulink:Variants:UAEmptyVarObjTableColumnTwoHeading')});

    searchReferencedModels=false;
    [variantObjectNames,variantObjectUsageMap]=slvariants.internal.manager.core.getVariantObjectsUsageInfo(system,searchReferencedModels);



    dataAccessor=Simulink.data.DataAccessor.create(system);
    ResultStatus=true;
    for i=1:numel(variantObjectNames)
        variantObjectName=variantObjectNames{i};
        varID=dataAccessor.identifyByName(variantObjectName);
        if isempty(dataAccessor.getVariable(varID).Condition)
            blocksUsingVariantObject=variantObjectUsageMap(variantObjectName);
            for j=1:numel(blocksUsingVariantObject)


                addRow(ft,{variantObjectName,blocksUsingVariantObject{j}});
            end
            ResultStatus=false;
        end
    end

    if~ResultStatus
        setRecAction(ft,DAStudio.message('Simulink:Variants:UAEmptyVarObjRecommendedAction'));
        setCheckText(ft,DAStudio.message('Simulink:Variants:UAEmptyVarObjFailMessage'));
    else
        setCheckText(ft,DAStudio.message('Simulink:Variants:UAEmptyVarObjPassMessage'));
    end

    ResultDescription{end+1}=ft;
    mdladvObj.setCheckResultStatus(ResultStatus);
end


