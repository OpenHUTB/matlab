function styleguide_jc_0061





    rec=ModelAdvisor.Check('mathworks.maab.jc_0061');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc0061Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc0061Tip');
    rec.setCallbackFcn(@jc_0061_StyleOneCallback,'None','DetailStyle');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0061Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

    inputParams{1}=Advisor.Utils.createStandardInputParameters('maab.StandardSelection');
    inputParams{end}.RowSpan=[1,1];
    inputParams{end}.ColSpan=[1,2];

    inputParams{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParams{end}.RowSpan=[2,2];
    inputParams{end}.ColSpan=[1,2];

    inputParams{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParams{end}.RowSpan=[2,2];
    inputParams{end}.ColSpan=[3,4];
    inputParams{end}.Value='graphical';

    inputParams{end+1}=ModelAdvisor.InputParameter;
    inputParams{end}.RowSpan=[3,11];
    inputParams{end}.ColSpan=[1,4];
    inputParams{end}.Name=DAStudio.message('ModelAdvisor:styleguide:AllowedBlkList');
    inputParams{end}.Type='BlockType';
    inputParams{end}.Value=getObviousBlockList;
    inputParams{end}.Visible=false;
    inputParams{end}.Enable=false;

    rec.setInputParametersLayoutGrid([11,4]);
    rec.setInputParameters(inputParams);
    rec.setInputParametersCallbackFcn(@InputParameterCallBack);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function BlockList=getObviousBlockList()

    BlockList={'From','';...
    'Goto','';...
    'Ground','';...
    'Logic','';...
    'Merge','';...
    'MinMax','';...
    'ModelReference','';...
    'MultiPortSwitch','';...
    'Product','';...
    'RelationalOperator','';...
    'Saturate','';...
    'Switch','';...
    'Terminator','';...
    'Trigonometry','';...
    'UnitDelay','';...
    'Sum','';...
    'SubSystem','Compare To Constant';...
    'SubSystem','Compare To Zero';};
end

function InputParameterCallBack(taskobj,tag,handle)%#ok<INUSD>
    if strcmp(tag,'InputParameters_1')
        if isa(taskobj,'ModelAdvisor.Task')
            inputParameters=taskobj.Check.InputParameters;
        elseif isa(taskobj,'ModelAdvisor.ConfigUI')
            inputParameters=taskobj.InputParameters;
        else
            return
        end
        switch inputParameters{1}.Value
        case 'MAB'
            inputParameters{4}.Value=getObviousBlockList();
            inputParameters{4}.Enable=false;

        case 'Custom'
            inputParameters{4}.Enable=true;

        end
    end
end


function jc_0061_StyleOneCallback(system,CheckObj)


    feature('scopedaccelenablement','off');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    [resultDescriptiveOnBlocks,...
    resultDescriptiveOffBlocks,...
    resultObviousBlocks]=getBlockViolations(system,mdladvObj);


    CheckObj.setResultDetails(updateMdladvObj(mdladvObj,...
    resultDescriptiveOnBlocks,...
    resultDescriptiveOffBlocks,...
    resultObviousBlocks));

end




function[ResultDescription]=updateMdladvObj(mdladvObj,...
    DescriptiveOnBlocks,...
    DescriptiveOffBlocks,...
    ObviousBlocks)

    ResultDescription=[];



    bResult=true;

    ElementResults=Advisor.Utils.createResultDetailObjs('',...
    'IsInformer',true,...
    'Description',DAStudio.message('ModelAdvisor:styleguide:jc0061_Info'));
    ResultDescription=[ResultDescription,ElementResults];


    if isempty(ObviousBlocks)
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Title',DAStudio.message('ModelAdvisor:styleguide:jc0061ObviousBlocksDescMsg_Title'),...
        'Information',DAStudio.message('ModelAdvisor:styleguide:jc0061ObviousBlocksDescMsg'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0061ObviousBlocks_PassMsg'));
    else
        bResult=false;
        ElementResults=Advisor.Utils.createResultDetailObjs(ObviousBlocks,...
        'Title',DAStudio.message('ModelAdvisor:styleguide:jc0061ObviousBlocksDescMsg_Title'),...
        'Information',DAStudio.message('ModelAdvisor:styleguide:jc0061ObviousBlocksDescMsg'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0061ObviousBlocksFailMsg'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:jc0061ObviousBlocks_RecAct'));
    end
    ResultDescription=[ResultDescription,ElementResults];



    ft2=ModelAdvisor.FormatTemplate('ListTemplate');
    ft2.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:jc0061NameShownNotDescriptive_Title')});
    ft2.setInformation({DAStudio.message('ModelAdvisor:styleguide:jc0061NameShownNotDescriptive_Msg')});

    if~isempty(DescriptiveOnBlocks)
        bResult=false;
        ElementResults=Advisor.Utils.createResultDetailObjs(DescriptiveOnBlocks,...
        'Title',DAStudio.message('ModelAdvisor:styleguide:jc0061NameShownNotDescriptive_Title'),...
        'Information',DAStudio.message('ModelAdvisor:styleguide:jc0061NameShownNotDescriptive_Msg'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveOnBlocksFailMsg'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveOnBlocks_RecAct'));
    else
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Title',DAStudio.message('ModelAdvisor:styleguide:jc0061NameShownNotDescriptive_Title'),...
        'Information',DAStudio.message('ModelAdvisor:styleguide:jc0061NameShownNotDescriptive_Msg'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveOnBlocks_PassMsg'));
    end

    ResultDescription=[ResultDescription,ElementResults];

    ft3=ModelAdvisor.FormatTemplate('ListTemplate');
    ft3.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveBlocksDescMsg_Title')});
    ft3.setInformation({DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveBlocksDescMsg')});

    if~isempty(DescriptiveOffBlocks)
        bResult=false;
        ElementResults=Advisor.Utils.createResultDetailObjs(DescriptiveOffBlocks,...
        'Title',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveBlocksDescMsg_Title'),...
        'Information',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveBlocksDescMsg'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveOffBlocksFailMsg'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveOffBlocks_RecAct'));
    else
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Title',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveBlocksDescMsg_Title'),...
        'Information',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveBlocksDescMsg'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0061DescriptiveOffBlocks_PassMsg'));
    end
    ResultDescription=[ResultDescription,ElementResults];






    mdladvObj.setCheckResultStatus(bResult);

end


function[resultDescriptiveOnBlocks,resultDescriptiveOffBlocks,resultObviousBlocks]=getBlockViolations(system,mdladvObj)

    followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');


    if isnumeric(system)
        system=getfullname(system);
    end

    inputParams=mdladvObj.getInputParameters;
    ObviousBlockTypes=inputParams{4}.Value;


    resultDescriptiveOnBlocks=[];
    resultDescriptiveOffBlocks=[];
    resultObviousBlocks=[];




    blks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',followlinkParam.Value,...
    'LookUnderMasks',lookundermaskParam.Value,...
    'Type','block');



    blks=filterBlocks(followlinkParam.Value,lookundermaskParam.Value,system,blks);



    exprnumchars='[0123456789._()!@#\$&*+-;\\|/?,\\ \n\r\t]';


    blkNames=get_param(blks,'Name');
    blkTypes=get_param(blks,'BlockType');



    defaultNamesMap=getDefaultBlockNames();


    for idx=1:length(blks)
        if any(strcmp(get_param(blks{idx},'BlockType'),{'ArgIn','ArgOut'}))
            continue;
        end


        if isInBlockList(blks{idx},ObviousBlockTypes)

            if isNotHidden(blks(idx))
                resultObviousBlocks=[resultObviousBlocks,blks(idx)];%#ok<AGROW>
            end
        else



            if(strcmp(blkTypes{idx},'SubSystem')||strcmp(blkTypes{idx},'S-Function'))&&...
                strcmp(get_param(blks{idx},'LinkStatus'),'resolved')&&...
                ~isempty(get_param(blks{idx},'ReferenceBlock'))


                refBlock=get_param(blks{idx},'ReferenceBlock');

                try
                    libraryAccessible=true;

                    libraryName=bdroot(refBlock);
                catch E
                    if strcmp(E.identifier,'Simulink:Commands:InvSimulinkObjectName')

                        try
                            firstSlashIdx=regexp(refBlock,'/','once');

                            libraryName=refBlock(1:firstSlashIdx-1);
                            load_system(libraryName);
                        catch E %#ok<NASGU>
                            libraryAccessible=false;
                        end
                    else
                        rethrow(E);
                    end
                end

                if libraryAccessible
                    filePath=which(libraryName);

                    if strncmpi(filePath,'built-in',8)||...
                        strncmp(matlabroot,filePath,length(matlabroot))

                        libBlockName=get_param(refBlock,'Name');

                        if strcmpi(regexprep(blkNames{idx},exprnumchars,''),...
                            regexprep(libBlockName,exprnumchars,''))

                            if isNotHidden(blks(idx))
                                resultDescriptiveOnBlocks=[resultDescriptiveOnBlocks,blks(idx)];%#ok<AGROW>
                            end
                        else

                            if strcmp(get_param(blks{idx},'ShowName'),'off')
                                resultDescriptiveOffBlocks=[resultDescriptiveOffBlocks,blks(idx)];%#ok<AGROW>
                            end
                        end


                        continue;
                    end
                end
            end







            if defaultNamesMap.isKey(blkTypes{idx})


                defaultNames=defaultNamesMap(blkTypes{idx});


                if any(strcmpi(regexprep(blkNames{idx},exprnumchars,''),...
                    regexprep(defaultNames,exprnumchars,'')))

                    if isNotHidden(blks(idx))
                        resultDescriptiveOnBlocks=[resultDescriptiveOnBlocks,blks(idx)];%#ok<AGROW>
                    end
                else

                    if strcmp(get_param(blks(idx),'ShowName'),'off')
                        resultDescriptiveOffBlocks=[resultDescriptiveOffBlocks,blks(idx)];%#ok<AGROW>
                    end
                end
            else


                if strcmpi(regexprep(blkNames{idx},exprnumchars,''),...
                    regexprep(blkTypes{idx},exprnumchars,''))

                    if isNotHidden(blks(idx))
                        resultDescriptiveOnBlocks=[resultDescriptiveOnBlocks,blks(idx)];%#ok<AGROW>
                    end
                else
                    if strcmp(get_param(blks(idx),'ShowName'),'off')
                        resultDescriptiveOffBlocks=[resultDescriptiveOffBlocks,blks(idx)];%#ok<AGROW>
                    end
                end
            end
        end
    end


    resultDescriptiveOnBlocks=mdladvObj.filterResultWithExclusion(resultDescriptiveOnBlocks);
    resultDescriptiveOffBlocks=mdladvObj.filterResultWithExclusion(resultDescriptiveOffBlocks);
    resultObviousBlocks=mdladvObj.filterResultWithExclusion(resultObviousBlocks);

end

function flag=isNotHidden(blk)
    flag=strcmp(get_param(blk,'ShowName'),'on')&&~simulink.diagram.internal.isNameHiddenAutomatically(blk{1});
end

function blks=filterBlocks(followlinkSetting,lookundermaskSetting,system,blks)




    blksStateflow=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',followlinkSetting,...
    'LookUnderMasks',lookundermaskSetting,...
    'MaskType','Stateflow',...
    'Type','block');



    blks=setprune(blks,blksStateflow,'NoSubSystems');









    reqBlocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',followlinkSetting,...
    'LookUnderMasks',lookundermaskSetting,...
    'MaskType','System Requirements',...
    'BlockType','SubSystem');



    reqBlockItems=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',followlinkSetting,...
    'LookUnderMasks',lookundermaskSetting,...
    'MaskType','System Requirement Item',...
    'BlockType','SubSystem');

    blks=setdiff(blks,[reqBlocks;reqBlockItems]);
end


function bResult=isInBlockList(Object,BlockList)
    bResult=false;
    [numRows,~]=size(BlockList);
    for i=1:numRows
        if~strcmp(get_param(Object,'Type'),'block_diagram')&&isequal({get_param(Object,'BlockType'),get_param(Object,'MaskType')},BlockList(i,:))
            bResult=true;
            return;
        end
    end
end
