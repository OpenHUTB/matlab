function registerBusPortsTransformCheck()




    checkID='mathworks.m2m_edittime.BusPortsXform';
    rec=ModelAdvisor.internal.EdittimeCheck(checkID);
    rec.Title=DAStudio.message('sl_m2m_edittime:messages:BusPortsXform_Title');
    rec.TitleTips=DAStudio.message('sl_m2m_edittime:messages:BusPortsXform_Action_Description');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='mathworks.ModelTransformer.BusBlocks';

    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;

    rec.LicenseName={'SL_Verification_Validation'};

    mdladvRoot=ModelAdvisor.Root;

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@checkActionCallback);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('sl_m2m_edittime:messages:BusPortsXform_Action_Description');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);
    mdladvRoot.publish(rec,DAStudio.message('sl_m2m_edittime:messages:Component_And_SubComponent'));

end

function result=checkActionCallback(~)
    result=ModelAdvisor.Paragraph;
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);
    checkResultObj=mdladvObj.getCheckObj('mathworks.m2m_edittime.BusPortsXform');
    resultDetails=checkResultObj.ResultDetails;
    modelName=mdladvObj.ModelName;%#ok<NASGU>
    userDataArray={};
    tableRows={};
    for idx=1:numel(resultDetails)
        resultDetail=resultDetails(idx);
        userDataArray{end+1}=resultDetail.CustomData;%#ok<AGROW>
        tableRows{end+1,1}=resultDetail.Data;%#ok<AGROW>
    end

    tableTemplate=ModelAdvisor.FormatTemplate('TableTemplate');
    tableTemplate.setSubBar(0);
    tableTemplate.setInformation(DAStudio.message('sl_m2m_edittime:messages:BusPortsXform_Check_Action_1'));
    tableTemplate.setColTitles({DAStudio.message('sl_m2m_edittime:messages:BusPortsXform_Action_Report_Col1')});
    tableTemplate.setTableInfo(tableRows);
    result.addItem(tableTemplate.emitContent);


    userDataArray=findUnique(userDataArray);
    Simulink.ModelRefactor.BusPortsTransform.refactor(userDataArray);






end

function out=findUnique(data)
    if isempty(data)
        out=data;
        return;
    end
    [~,cols]=size(data);
    if cols==1
        out=data;
        return;
    end
    rootHandles(1)=data{1}{1};
    pickedIndexes(1)=1;
    for pIdx=2:cols
        cellData=data{pIdx};
        rootHandle=cellData{1};
        if~any(rootHandles(:)==rootHandle)
            rootHandles(end+1)=rootHandle;
            pickedIndexes(end+1)=pIdx;
        end
    end
    out=data(pickedIndexes);
end

