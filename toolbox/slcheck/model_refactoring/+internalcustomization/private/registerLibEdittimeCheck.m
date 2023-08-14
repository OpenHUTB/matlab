function registerLibEdittimeCheck()




    checkID='mathworks.cloneDetection.libraryEdittime';
    rec=ModelAdvisor.internal.EdittimeCheck(checkID);
    rec.Title=DAStudio.message('sl_cloneDetection_edittime:messages:libPattern_edittime_Title_MA');
    rec.TitleTips=DAStudio.message('sl_cloneDetection_edittime:messages:libPattern_edittime_Action_Description');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='mathworks.CloneDetection.Library';

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
    modifyAction.Description=DAStudio.message('sl_cloneDetection_edittime:messages:libPattern_edittime_Action_Description');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);
    mdladvRoot.publish(rec,DAStudio.message('sl_m2m_edittime:messages:Component_And_SubComponent'));

end

function result=checkActionCallback(~)
    result=ModelAdvisor.Paragraph;
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);
    checkResultObj=mdladvObj.getCheckObj('mathworks.cloneDetection.libraryEdittime');
    resultDetails=checkResultObj.ResultDetails;
    modelName=mdladvObj.ModelName;
    modelHandle=get_param(modelName,'Handle');

    libResult=Simulink.SLPIR.CloneDetection.getLibraryList(modelHandle);
    clonedetection(modelName);
    settingObj=Simulink.CloneDetection.Settings();
    i=1;

    for j=1:length(libResult)
        for k=1:length(libResult(j).candidates)
            path=which(get_param(libResult(j).candidates(k),'Name'));
            settingObj.Libraries{i}={path};
            i=i+1;
        end
    end
    Simulink.CloneDetection.findClones(modelName,settingObj);
    tableRows={};
    userDataArray={};
    for idx=1:numel(resultDetails)
        resultDetail=resultDetails(idx);
        if~isa(resultDetail,'double')
            userDataArray{end+1}=resultDetail.CustomData;
            tableRows{end+1,1}=resultDetail.Data;
        end
    end
    tableTemplate=ModelAdvisor.FormatTemplate('TableTemplate');
    tableTemplate.setSubBar(0);
    tableTemplate.setInformation(DAStudio.message('sl_cloneDetection_edittime:messages:Library_Check_Action_1'));
    tableTemplate.setColTitles({DAStudio.message('sl_cloneDetection_edittime:messages:Library_MA_Check_Description')});
    tableTemplate.setTableInfo(tableRows);
    result.addItem(tableTemplate.emitContent);

end
