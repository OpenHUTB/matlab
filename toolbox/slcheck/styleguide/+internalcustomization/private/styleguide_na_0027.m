function styleguide_na_0027





    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.maab.na_0027');

    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0027_title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:na_0027_tip');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.maab.na_0027';
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.setLicense({styleguide_license});




    paramConvention=Advisor.Utils.createStandardInputParameters('maab.StandardSelection');


    entries={DAStudio.message('ModelAdvisor:engine:Allowed'),DAStudio.message('ModelAdvisor:engine:Prohibited')};
    paramMode=Advisor.Utils.getInputParam_Enum('ModelAdvisor:engine:BlkListInterpretionMode',[1,1],[3,4],entries);


    paramBlkList=ModelAdvisor.InputParameter;
    paramBlkList.RowSpan=[2,10];
    paramBlkList.ColSpan=[1,4];
    paramBlkList.Name=DAStudio.message('ModelAdvisor:engine:BlkTypeList');
    paramBlkList.Type='BlockType';
    loadFromDisk=load(fullfile(matlabroot,filesep,'toolbox',filesep,'slcheck',filesep,'styleguide',filesep,'+internalcustomization',filesep,'private',filesep,'defaultBlockSupportTable.mat'));
    allowedBlocks=loadFromDisk.defaultBlockSupportTable;
    paramBlkList.Value=allowedBlocks;
    paramBlkList.Description=DAStudio.message('ModelAdvisor:styleguide:na_0027_supported_blocks');
    paramBlkList.Visible=false;
    paramBlkList.Enable=false;


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.Value='all';
    paramFollowLinks.RowSpan=[11,11];
    paramFollowLinks.ColSpan=[1,2];
    paramLookUnderMasks.RowSpan=[11,11];
    paramLookUnderMasks.ColSpan=[3,4];

    rec.setInputParametersLayoutGrid([11,4]);
    rec.setInputParameters({paramConvention,paramMode,paramBlkList,paramFollowLinks,paramLookUnderMasks});
    rec.setInputParametersCallbackFcn(@ModelAdvisor.Common.blkTypeList_MAAB_InputParamCB);



    rec.setCallbackFcn(@CheckCallback,'None','DetailStyle');
    mdladvRoot.register(rec);
end


function CheckCallback(system,CheckObj)
    feature('scopedaccelenablement','off');

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    [resultData]=getCheckInformation(system,mdladvObj);


    updateMdladvObj(mdladvObj,resultData);

    if isempty(resultData.failedBlocks)
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:na_0027_tip'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:na_0027_pass'));
    else

        ElementResults=Advisor.Utils.createResultDetailObjs(resultData.failedBlocks,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:na_0027_tip'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:na_0027_warn'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:na_0027_rec_action'));
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
    listOfBlocks=inputParams{3}.Value;
    followLinks=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookUnderMask=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');


    failedBlocks=[];



    if blackListMode

        for idx=1:size(listOfBlocks,1)



            blks=find_system(system,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',followLinks.Value,...
            'LookUnderMasks',lookUnderMask.Value,...
            'BlockType',listOfBlocks{idx,1},...
            'MaskType',listOfBlocks{idx,2});


            failedBlocks=[failedBlocks;blks];%#ok<AGROW>
        end

    else


        allblks=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followLinks.Value,...
        'LookUnderMasks',lookUnderMask.Value);
        if strcmp(bdroot(mdladvObj.SystemName),mdladvObj.SystemName)
            allblks=allblks(2:end);
        end
        validBlks=[];
        for idx=1:size(listOfBlocks,1)


            blks=find_system(system,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks',followLinks.Value,...
            'LookUnderMasks',lookUnderMask.Value,...
            'BlockType',listOfBlocks{idx,1},...
            'MaskType',listOfBlocks{idx,2});
            validBlks=[validBlks;blks];%#ok<AGROW>
        end
        failedBlocks=setdiff(allblks,validBlks);
    end



    failedBlocks=mdladvObj.filterResultWithExclusion(failedBlocks);
    resultData.failedBlocks=failedBlocks;

end
