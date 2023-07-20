







function jmaab_jc_0651
    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0651');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0651_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID=rec.ID;
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:jmaab:jc_0651',@hCheckAlgo),...
    'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0651_tip');
    rec.setLicense({styleguide_license});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@addDataConversionBlocks);
    modifyAction.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0651_ModifyButtonText');
    modifyAction.Description=DAStudio.message('ModelAdvisor:jmaab:jc_0651_ModifyButtonDesc');
    modifyAction.Enable=true;
    rec.setAction(modifyAction);

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    if isempty(system)
        return;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flv=mdladvObj.getInputParameterByName('Follow links');
    lum=mdladvObj.getInputParameterByName('Look under masks');


    allBlks=find_system(system,'FollowLinks',flv.Value,'LookUnderMasks',lum.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'type','block');



    topLevelInports=find_system(bdroot(system),'FollowLinks',flv.Value,...
    'LookUnderMasks',lum.Value,...
    'SearchDepth',1,'Regexp','on','BlockType','Inport|Outport|InportShadow');


    allBlks=setdiff(allBlks,topLevelInports);



    blkTypesNotConsidered={'Constant','DataTypeConversion','BusCreator','EnablePort'};
    for k=1:length(blkTypesNotConsidered)


        allBlks=setdiff(allBlks,find_system(system,'FollowLinks',flv.Value,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks',lum.Value,'BlockType',blkTypesNotConsidered{k}));
    end




    allBlks=setdiff(allBlks,find_system(system,'FollowLinks',flv.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',lum.Value,'MaskType','Compare To Constant'));

    if isempty(allBlks)
        return;
    end

    allBlks=mdladvObj.filterResultWithExclusion(allBlks);

    flaggedBlocks=false(1,length(allBlks));

    for k=1:length(allBlks)
        currBlock=allBlks{k};
        blockObj=get_param(currBlock,'Object');

        if~isprop(blockObj,'OutDataTypeStr')
            continue;
        end

        type=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,blockObj.OutDataTypeStr);
        if isempty(type)
            continue;
        end

        if contains(type{1},'Inherit:')||...
            (strcmp(blockObj.MaskType,'Enumerated Constant')&&contains(type{1},'Enum:'))
            continue;
        else
            flaggedBlocks(k)=true;
        end
    end

    FailingObjs=allBlks(flaggedBlocks);

end

function result=addDataConversionBlocks(taskobj)

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    system=mdladvObj.System;
    if isempty(system)
        return;
    end

    ResultData=mdladvObj.getCheckResult('mathworks.jmaab.jc_0651');

    if isempty(ResultData)
        return;
    end

    sfHandles=Simulink.ID.getHandle(ResultData{1}.ListObj);

    if isempty(sfHandles)
        return;
    end

    for k=1:length(sfHandles)
        currBlock=sfHandles{k};
        blockObj=get_param(currBlock,'Object');
        type=get_param(currBlock,'OutDataTypeStr');



        if strcmpi(get_param(currBlock,'BlockType'),'Logic')
            set_param(currBlock,'OutDataTypeStr','Inherit: Logical (see Configuration Parameters: Optimization)');
        else
            set_param(currBlock,'OutDataTypeStr','Inherit: Inherit via internal rule');
        end
        posI=get_param(currBlock,'Position');
        addBlockName=[blockObj.parent,'/','dataconversion',num2str(k)];
        dataConvBlkHandle=add_block('built-in/DataTypeConversion',addBlockName,'MakeNameUnique','on','Position',[posI(3)+20,posI(2),posI(3)+50,posI(4)]);
        set_param(dataConvBlkHandle,'OutDataTypeStr',type)
        dstnPortHandles=[];
        if ishandle(blockObj.LineHandles.Outport)
            dstnPortHandles=get_param(blockObj.LineHandles.Outport,'DstPortHandle');
            delete_line(blockObj.LineHandles.Outport);
        end

        phSrc=get_param(blockObj.handle,'PortHandles');
        phDest=get_param(dataConvBlkHandle,'PortHandles');
        add_line(blockObj.parent,phSrc.Outport,phDest.Inport);

        phSrc=get_param(dataConvBlkHandle,'PortHandles');
        for i=1:numel(dstnPortHandles)
            add_line(blockObj.parent,phSrc.Outport,dstnPortHandles(i));
        end

    end

    result=ModelAdvisor.Paragraph();
    msg=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:jmaab:jc_0651_PostModificationUpdateText'));
    result.addItem(msg);

end

