function styleguide_db_0140()







    rec=ModelAdvisor.Check('mathworks.maab.db_0140');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0140Title');
    rec.setCallbackFcn(@db_0140_Callback,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0140Tip');
    rec.Value(true);
    rec.Group='MAAB Test Group';
    rec.setLicense({styleguide_license});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0140Title';

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
    inputParam2.RowSpan=[2,10];
    inputParam2.ColSpan=[1,4];
    inputParam2.Name=DAStudio.message('ModelAdvisor:engine:BlkTypeListWithParameter');
    inputParam2.Type='BlockTypeWithParameter';
    inputParam2.Value=ModelAdvisor.Common.getDefaultBlockList_db_0140;
    inputParam2.Visible=false;
    inputParam2.Enable=false;

    inputParam3=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam3.RowSpan=[11,11];
    inputParam3.ColSpan=[1,2];

    inputParam4=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam4.Value='graphical';
    inputParam4.RowSpan=[11,11];
    inputParam4.ColSpan=[3,4];

    rec.setInputParameters({inputParam1,inputParam2,inputParam3,inputParam4});
    rec.setInputParametersCallbackFcn(@ModelAdvisor.Common.blkTypeList_MAAB_InputParamCB);


    myAction=ModelAdvisor.Action;
    myAction.setCallbackFcn(@db_0140_ActionCallback);
    myAction.Name=DAStudio.message('ModelAdvisor:styleguide:db0140ActionName');
    myAction.Description=DAStudio.message('ModelAdvisor:styleguide:db0140ActionDescription');
    rec.setAction(myAction);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
end

function[ResultDescription]=db_0140_Callback(system)

    feature('scopedaccelenablement','off');
    ResultDescription={};

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(true);

    followlinkParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.LookUnderMasks');



    allBlocks=find_system(system,'FollowLinks',followlinkParam.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',lookundermaskParam.Value,...
    'FindAll','off',...
    'Type','block');
    bObjs=get_param(allBlocks,'Object');

    inputParams=modelAdvisorObject.getInputParameters;
    blocksAndAttribs=inputParams{2}.Value;

    reportBlks={};
    if~isempty(blocksAndAttribs)

        for i=1:length(bObjs)

            if~isa(bObjs{i},'Simulink.Reference')
                index1=strmatch(bObjs{i}.BlockType,blocksAndAttribs(1:end,1)','exact');
                index2=strmatch(bObjs{i}.MaskType,blocksAndAttribs(1:end,2)','exact');
                index=intersect(index1,index2);
                if length(index)>1
                    index=index(end);
                end
            else
                index=[];
            end
            if~isempty(index)&&~isempty(bObjs{i}.IntrinsicDialogParameters)&&strcmp(bObjs{i}.Mask,'off')
                fn=fieldnames(bObjs{i}.IntrinsicDialogParameters);
                for j=1:length(fn)

                    if~isempty(strmatch(fn{j},blocksAndAttribs{index,3}))

                        if isempty(strmatch('read-only',bObjs{i}.IntrinsicDialogParameters.(fn{j}).('Attributes'),'exact'))

                            if~isequal(filtered_default_param(bObjs{i}.BlockType,fn{j}),bObjs{i}.(fn{j}))

                                if~attributePresent(bObjs{i},fn{j})
                                    reportBlk.name=allBlocks{i};
                                    reportBlk.param=fn{j};
                                    defVal=filtered_default_param(bObjs{i}.BlockType,fn{j});
                                    if iscell(defVal)
                                        defVal=[defVal{:}];
                                    end
                                    reportBlk.defVal=defVal;
                                    currVal=bObjs{i}.(fn{j});
                                    if iscell(currVal)
                                        currVal=[currVal{:}];
                                    end
                                    reportBlk.val=currVal;

                                    filtered=modelAdvisorObject.filterResultWithExclusion(reportBlk.name);
                                    if~isempty(filtered)
                                        reportBlks{end+1}=reportBlk;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end



    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': db_0140'];

    ft.setCheckText({DAStudio.message('ModelAdvisor:styleguide:db0140InfoText')});
    if~isempty(reportBlks)
        modelAdvisorObject.setCheckResultStatus(false);
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:db0140FailureMessage')});
        ft.setRecAction({DAStudio.message('ModelAdvisor:styleguide:db0140RecAction')});
        ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:db0140Col_1'),...
        DAStudio.message('ModelAdvisor:styleguide:db0140Col_2'),...
        DAStudio.message('ModelAdvisor:styleguide:db0140Col_3'),...
        DAStudio.message('ModelAdvisor:styleguide:db0140Col_4')});

        for inx=1:length(reportBlks)
            ft.addRow({reportBlks{inx}.name,...
            reportBlks{inx}.param,...
            reportBlks{inx}.defVal,...
            reportBlks{inx}.val});
        end
        modelAdvisorObject.setActionEnable(true);
    else
        modelAdvisorObject.setActionEnable(false);
        modelAdvisorObject.setCheckResultStatus(true);
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:db0140SuccessMessage')});
    end
    modelAdvisorObject.setCheckResultData(reportBlks);
    ft.setSubBar(0);
    ResultDescription{end+1}=ft;

end


function bResult=attributePresent(blkObj,field)
    bResult=false;
    expr=['%<',field,'>'];
    bResult=~isempty(strfind(blkObj.AttributesFormatString,expr));
end



function paramValue=filtered_default_param(blockPath,paramTag)
    paramValue=get_param(['built-in/',blockPath],paramTag);
    switch blockPath
    case 'TriggerPort'
        if strcmp(paramTag,'StatesWhenEnabling')
            paramValue='held';
        end
    case 'DataTypeConversion'
        if strcmp(paramTag,'RndMeth')
            paramValue='Floor';
        end
    case 'Demux'
        if strcmp(paramTag,'DisplayOption')
            paramValue='bar';
        end
    case 'DiscreteFilter'
        if strcmp(paramTag,'SampleTime')
            paramValue='1';
        end
    case 'Lookup2D'
        if strcmp(paramTag,'RowIndex')
            paramValue='[1:3]';
        elseif strcmp(paramTag,'ColumnIndex')
            paramValue='[1:3]';
        elseif strcmp(paramTag,'Table')
            paramValue='[4 5 6;16 19 20;10 18 23]';
        elseif strcmp(paramTag,'InputSameDT')
            paramValue='off';
        end
    case 'MinMax'
        if strcmp(paramTag,'InputSameDT')
            paramValue='off';
        end
    case 'Sum'
        if strcmp(paramTag,'InputSameDT')
            paramValue='off';
        end
    case 'Switch'
        if strcmp(paramTag,'InputSameDT')
            paramValue='off';
        end
    case 'UniformRandomNumber'
        if strcmp(paramTag,'SampleTime')
            paramValue='0.1';
        end
    case 'UnitDelay'
        if strcmp(paramTag,'SampleTime')
            paramValue='-1';
        end
    case 'VariableTransportDelay'
        if strcmp(paramTag,'VariableDelayType')
            paramValue='Variable transport delay';
        elseif strcmp(paramTag,'MaximumDelay')
            paramValue='10';
        end
    case 'DiscreteIntegrator'
        if strcmp(paramTag,'SampleTime')
            paramValue='-1';
        end
    end
end

function result=db_0140_ActionCallback(taskobj)
    reportBlks=taskobj.Check.ResultData;
    for i=1:size(reportBlks,2)
        blkObj=get_param(reportBlks{i}.name,'Object');
        expr=[reportBlks{i}.param,'=%<',reportBlks{i}.param,'>'];
        reportBlks{i}.originalAttributesFormatString=blkObj.AttributesFormatString;
        if isempty(blkObj.AttributesFormatString)
            blkObj.AttributesFormatString=[blkObj.AttributesFormatString,expr];
        else
            blkObj.AttributesFormatString=[blkObj.AttributesFormatString,sprintf('\n'),expr];
        end
        reportBlks{i}.newAttributesFormatString=blkObj.AttributesFormatString;
    end
    result=ModelAdvisor.FormatTemplate('TableTemplate');

    result.setCheckText({DAStudio.message('ModelAdvisor:styleguide:db0140ActionInfoText')});
    result.setColTitles({DAStudio.message('ModelAdvisor:styleguide:db0140Col_1'),...
    DAStudio.message('ModelAdvisor:styleguide:db0140Col_2'),...
    DAStudio.message('ModelAdvisor:styleguide:db0140ActionCol_3'),...
    DAStudio.message('ModelAdvisor:styleguide:db0140ActionCol_4')});
    for inx=1:length(reportBlks)
        result.addRow({reportBlks{inx}.name,...
        reportBlks{inx}.param,...
        escapeHTMLSpecialChars(reportBlks{inx}.originalAttributesFormatString),...
        escapeHTMLSpecialChars(reportBlks{inx}.newAttributesFormatString)});
    end
    taskobj.MAObj.setActionEnable(false);
end

function output=escapeHTMLSpecialChars(input)
    output=strrep(input,'<','&lt;');
    output=strrep(output,'>','&gt;');
end
