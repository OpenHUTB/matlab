function styleguide_na_0017

    mdladvRoot=ModelAdvisor.Root;
    maab_group=sg_maab_group;

    checkID='na_0017';
    rec=ModelAdvisor.Check('mathworks.maab.na_0017');
    rec.setLicense({styleguide_license});
    rec.setCallbackFcn(@CheckCallBackFcn,'None','StyleOne');
    rec.Title=DAStudio.message(['ModelAdvisor:styleguide:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:styleguide:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:styleguide:',checkID,'_tip'])];
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID=checkID;
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportHighlighting=true;


    inputParamFL=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamLUM=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamLUM.ColSpan=[3,4];
    inputParamFcnLevel=Advisor.Utils.getInputParam_String(...
    'ModelAdvisor:styleguide:na_0017_inputParam1',[2,2],[1,2],'3');
    inputParamFcnLevel.Enable=true;

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters({inputParamFL,inputParamLUM,inputParamFcnLevel});
    mdladvRoot.publish(rec,maab_group);

end


function ResultDescription=CheckCallBackFcn(system)

    ResultDescription={};
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    msgCatalogTagPrefix='ModelAdvisor:styleguide:na_0017';

    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');
    fcnCallLimit=mdlAdvObj.getInputParameterByName(DAStudio.message([msgCatalogTagPrefix,'_inputParam1']));
    fcnCallLimit=str2double(fcnCallLimit.Value);



    if~isempty(fcnCallLimit)&&~isnan(fcnCallLimit)...
        &&isnumeric(fcnCallLimit)&&isequal(floor(fcnCallLimit),fcnCallLimit)&&~isequal(fcnCallLimit,0)
        fcnCallLimit=abs(fcnCallLimit(1));
    else
        fcnCallLimit=3;
    end


    fcnBlocks=Advisor.Utils.getAllMATLABFunctionBlocks(system,FollowLinks.Value,LookUnderMasks.Value);
    fcnBlocks=mdlAdvObj.filterResultWithExclusion(fcnBlocks);


    conflictDetails=ModelAdvisor.internal.styleguide_na_0017_algo(fcnBlocks,fcnCallLimit);


    bResultStatus=false;
    tableOfResults=ModelAdvisor.FormatTemplate('TableTemplate');
    tableOfResults.setInformation(DAStudio.message([msgCatalogTagPrefix,'_info'],fcnCallLimit));
    tableOfResults.setSubBar(false);
    tableOfResults.setColTitles(DAStudio.message([msgCatalogTagPrefix,'_colTitle1']));

    if isempty(conflictDetails)
        tableOfResults.setSubResultStatus('Pass');
        tableOfResults.setSubResultStatusText(DAStudio.message([msgCatalogTagPrefix,'_pass'],fcnCallLimit));
        bResultStatus=true;
    else
        tableOfResults.setSubResultStatus('Warn');
        tableOfResults.setSubResultStatusText(DAStudio.message([msgCatalogTagPrefix,'_fail'],fcnCallLimit));
        if~iscell(conflictDetails)
            conflictDetails={conflictDetails};
        end
        tableOfResults.setTableInfo(conflictDetails);
        tableOfResults.setRecAction(DAStudio.message([msgCatalogTagPrefix,'_recAction'],fcnCallLimit));
    end

    mdlAdvObj.setCheckResultStatus(bResultStatus);
    ResultDescription{end+1}=tableOfResults;
end

