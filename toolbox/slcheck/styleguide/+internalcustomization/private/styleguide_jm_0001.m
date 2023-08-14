function styleguide_jm_0001






    rec=ModelAdvisor.Check('mathworks.maab.jm_0001');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jm0001Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jm0001Tip');
    rec.setCallbackFcn(@jm_0001_StyleOneCallback,'None','DetailStyle');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jm0001Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportsEditTime=false;

    rec.setInputParametersLayoutGrid([11,4]);
    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.RowSpan=[1,1];
    inputParam1.ColSpan=[1,2];
    inputParam1.Name=DAStudio.message('ModelAdvisor:engine:Standard');
    inputParam1.Type='Enum';
    inputParam1.Value='MAB';
    inputParam1.Entries={'MAB','Custom'};
    inputParam1.Visible=false;
    inputParam2=ModelAdvisor.InputParameter;
    inputParam2.RowSpan=[1,1];
    inputParam2.ColSpan=[3,4];
    inputParam2.Name=DAStudio.message('ModelAdvisor:engine:BlkListInterpretionMode');
    inputParam2.Type='Enum';
    inputParam2.Value=ModelAdvisor.Common.getDefaultBlkListInterpretionMode_jm_0001;
    inputParam2.Entries={DAStudio.message('ModelAdvisor:engine:Allowed'),DAStudio.message('ModelAdvisor:engine:Prohibited')};
    inputParam2.Visible=false;
    inputParam2.Enable=false;
    inputParam3=ModelAdvisor.InputParameter;
    inputParam3.RowSpan=[2,10];
    inputParam3.ColSpan=[1,4];
    inputParam3.Name=DAStudio.message('ModelAdvisor:engine:BlkTypeList');
    inputParam3.Type='BlockType';
    inputParam3.Value=ModelAdvisor.Common.getDefaultBlockList_jm_0001;

    inputParam3.Visible=false;
    inputParam3.Enable=false;

    inputParam4=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam4.RowSpan=[11,11];
    inputParam4.ColSpan=[1,2];
    inputParam5=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam5.RowSpan=[11,11];
    inputParam5.ColSpan=[3,4];
    inputParam5.Value='all';
    rec.setInputParameters({inputParam1,inputParam2,inputParam3,inputParam4,inputParam5});
    rec.setInputParametersCallbackFcn(@ModelAdvisor.Common.blkTypeList_MAAB_InputParamCB);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end




function jm_0001_StyleOneCallback(system,CheckObj)


    feature('scopedaccelenablement','off');

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    [resultData]=getCheckInformation(system,mdladvObj);


    updateMdladvObj(mdladvObj,resultData);

    if isempty(resultData.failedBlocks)
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:jm0001_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jm0001_Pass'));
    else

        ElementResults=Advisor.Utils.createResultDetailObjs(resultData.failedBlocks,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:jm0001_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jm0001FailMsg'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:jm0001_RecAct'));
    end
    CheckObj.setResultDetails(ElementResults);

end




function updateMdladvObj(mdladvObj,resultData)

    if(isempty(resultData(1).failedBlocks))
        mdladvObj.setCheckResultStatus(true);
    else
        mdladvObj.setCheckResultStatus(false);
    end
end



function[resultData]=getCheckInformation(system,mdladvObj)



    inputParams=mdladvObj.getInputParameters;
    blackListMode=strcmp(inputParams{2}.Value,DAStudio.message('ModelAdvisor:engine:Prohibited'));
    ProhibitedBlocks=inputParams{3}.Value;
    followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');


    failedBlocks=[];

    if blackListMode

        for idx=1:size(ProhibitedBlocks,1)



            blks=find_system(system,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',followlinkParam.Value,...
            'LookUnderMasks',lookundermaskParam.Value,...
            'BlockType',ProhibitedBlocks{idx,1},...
            'MaskType',ProhibitedBlocks{idx,2});


            failedBlocks=[failedBlocks;blks];%#ok<AGROW>
        end
    else


        allblks=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followlinkParam.Value,...
        'LookUnderMasks',lookundermaskParam.Value);
        if strcmp(bdroot(mdladvObj.SystemName),mdladvObj.SystemName)
            allblks=allblks(2:end);
        end
        validBlks=[];
        for idx=1:size(ProhibitedBlocks,1)


            blks=find_system(system,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',followlinkParam.Value,...
            'LookUnderMasks',lookundermaskParam.Value,...
            'BlockType',ProhibitedBlocks{idx,1},...
            'MaskType',ProhibitedBlocks{idx,2});
            validBlks=[validBlks;blks];%#ok<AGROW>
        end
        failedBlocks=setdiff(allblks,validBlks);
    end



    failedBlocks=mdladvObj.filterResultWithExclusion(failedBlocks);
    resultData.failedBlocks=failedBlocks;

end




















