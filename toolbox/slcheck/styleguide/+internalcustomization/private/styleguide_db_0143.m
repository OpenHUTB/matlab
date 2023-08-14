function styleguide_db_0143()




    rec=ModelAdvisor.Check('mathworks.maab.db_0143');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0143Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0143Tip');
    rec.setCallbackFcn(@db_0143_StyleOneCallback,'None','DetailStyle');
    rec.setReportStyle('ModelAdvisor.Report.DefaultStyle');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0143Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

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
    inputParam2.Value=ModelAdvisor.Common.getDefaultBlkListInterpretionMode_db_0143;
    inputParam2.Entries={DAStudio.message('ModelAdvisor:engine:Allowed'),DAStudio.message('ModelAdvisor:engine:Prohibited')};
    inputParam2.Visible=false;
    inputParam2.Enable=false;
    inputParam3=ModelAdvisor.InputParameter;
    inputParam3.RowSpan=[2,10];
    inputParam3.ColSpan=[1,4];
    inputParam3.Name=DAStudio.message('ModelAdvisor:engine:BlkTypeList');
    inputParam3.Type='BlockType';
    inputParam3.Value=ModelAdvisor.Common.getDefaultBlockList_db_0143;
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
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});


end




function[ResultDescription]=db_0143_StyleOneCallback(system,CheckObj)


    feature('scopedaccelenablement','off');

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    [resultData]=getCheckInformation(system,mdladvObj);

    if isempty(resultData.failedBlocks)
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:db0143_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:db0143_Pass'));
    else

        ElementResults=Advisor.Utils.createResultDetailObjs(resultData.failedErrorStr,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:db0143_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:db0143FailMsg'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:db0143_RecAct'));
    end
    CheckObj.setResultDetails(ElementResults);


    [ResultDescription]=updateMdladvObj(mdladvObj,resultData);

end




function[ResultDescription]=updateMdladvObj(mdladvObj,resultData)

    ResultDescription={};



    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText({DAStudio.message('ModelAdvisor:styleguide:db0143_Info')});


    if(isempty(resultData(1).failedBlocks))
        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:db0143_Pass')});
        mdladvObj.setCheckResultStatus(true);
    else
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:db0143FailMsg')});
        ft.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0143_RecAct')});
        ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:db0143_Col_1'),...
        DAStudio.message('ModelAdvisor:styleguide:db0143_Col_2')});
        for inx=1:length(resultData.failedBlocks)
            ft.addRow({resultData.failedBlocks(inx),resultData.failedErrorStr(inx)});
        end
        mdladvObj.setCheckResultStatus(false);
    end
    ft.setSubBar(0);
    ResultDescription{end+1}=ft;
end


function[resultData]=getCheckInformation(system,mdladvObj)

    inputParams=mdladvObj.getInputParameters;




    AllowedSubsystemBlocks=inputParams{3}.Value;
    blackListMode=strcmp(inputParams{2}.Value,DAStudio.message('ModelAdvisor:engine:Prohibited'));


    AllowedSubsystemBlocks=...
    strcat(AllowedSubsystemBlocks(:,1),{':'},AllowedSubsystemBlocks(:,2));


    failedBlocks={};
    failedErrorStr={};


    followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');


    blksSubsystem=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',followlinkParam.Value,...
    'LookUnderMasks',lookundermaskParam.Value,...
    'BlockType','SubSystem');

    if strcmp(bdroot(system),system)
        blksSubsystem=[system;blksSubsystem];
    end

    blksSubsystem=Advisor.Utils.Naming.filterUsersInShippingLibraries(blksSubsystem);


    blksSubsystem=mdladvObj.filterResultWithExclusion(blksSubsystem);

    nonShippingBlksSubsystemObj=get_param(blksSubsystem,'Object');

    for i=1:numel(nonShippingBlksSubsystemObj)
        if isa(nonShippingBlksSubsystemObj{i},'Simulink.SubSystem')...
            &&~isempty(nonShippingBlksSubsystemObj{i}.MaskType)



            AllowedSubsystemBlocks{end+1}=append('SubSystem',':',nonShippingBlksSubsystemObj{i}.MaskType);%#ok<AGROW>
        end
    end












    blksSubsystem=blksSubsystem(~slprivate('is_stateflow_based_block',blksSubsystem));


    for idx=1:numel(blksSubsystem)



        blks=find_system(blksSubsystem{idx},...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followlinkParam.Value,...
        'LookUnderMasks',lookundermaskParam.Value,...
        'SearchDepth',1);
        blks=blks(2:end);


        blks=mdladvObj.filterResultWithExclusion(blks);


        blks=blks(~slprivate('is_stateflow_based_block',blks));


        BlockTypeMaskType=strcat(get_param(blks,'BlockType'),...
        {':'},get_param(blks,'MaskType'));


        if any(strcmp(BlockTypeMaskType,'SubSystem:'))






            for jdx=1:length(BlockTypeMaskType)

                if blackListMode
                    if any(strcmp(BlockTypeMaskType{jdx},AllowedSubsystemBlocks))

                        failedBlocks{end+1}=blksSubsystem{idx};%#ok<AGROW>
                        failedErrorStr{end+1}=blks{jdx};%#ok<AGROW>
                    end
                else
                    if~any(strcmp(BlockTypeMaskType{jdx},AllowedSubsystemBlocks))

                        failedBlocks{end+1}=blksSubsystem{idx};%#ok<AGROW>
                        failedErrorStr{end+1}=blks{jdx};%#ok<AGROW>
                    end
                end
            end
        end

    end


    resultData.failedBlocks=failedBlocks;
    resultData.failedErrorStr=failedErrorStr;

end



