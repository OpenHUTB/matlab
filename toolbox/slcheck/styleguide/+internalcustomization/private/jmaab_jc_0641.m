function jmaab_jc_0641





    rec=Advisor.Utils.getDefaultCheckObject...
    ('mathworks.jmaab.jc_0641',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters...
    ('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters...
    ('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);

    rec.setLicense({styleguide_license});

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@checkActionCallback);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message...
    ('Advisor:engine:CCActionDescription');
    modifyAction.Enable=true;

    rec.setAction(modifyAction);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function FailingObjs=hCheckAlgo(system)

    FailingObjs=[];

    if isempty(system)
        return;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    FL=mdladvObj.getInputParameterByName('Follow links');
    LUM=mdladvObj.getInputParameterByName('Look under masks');




    blkObj1=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FL.value,'LookUnderMasks',LUM.value,...
    'Regexp','on','SampleTime','^[0-9 .]');




    blkObj2=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FL.value,'LookUnderMasks',LUM.value,...
    'Regexp','on','SystemSampleTime','^[0-9 .]',...
    'BlockType','SubSystem','isSubsystemVirtual','off');

    blkObj1=mdladvObj.filterResultWithExclusion(blkObj1);
    blkObj2=mdladvObj.filterResultWithExclusion(blkObj2);

    if isempty(blkObj1)&&isempty(blkObj2)
        return;
    end




    blkObj1=Advisor.Utils.Naming.filterUsersInShippingLibraries(blkObj1);

    blkObj2=Advisor.Utils.Naming.filterUsersInShippingLibraries(blkObj2);

    if isempty(blkObj1)&&isempty(blkObj2)
        return;
    end





    flag=cellfun(@(x)~strcmp(...
    get_param(x,'TreatAsAtomicUnit'),'on'),blkObj2);
    blkObj2=blkObj2(flag);








    execptionBlk={'Outport','Inport','UnitDelay','Delay',...
    'DataTypeConversion','RateTransition','Memory','Constant'};
    flagBlk1=[];
    for iBlk=1:length(blkObj1)
        blkType=get_param(blkObj1{iBlk},'BlockType');
        curBlk=blkObj1(iBlk);
        curBlkPath=get_param(curBlk{1},'parent');
        if~any(strcmp(blkType,execptionBlk))




            if strcmp(blkType,'EnablePort')||...
                (strcmp(blkType,'TriggerPort')&&...
                ~((strcmp(get_param(blkObj1{iBlk},'TriggerType'),'function-call'))&&...
                (~Stateflow.SLUtils.isChildOfStateflowBlock(curBlkPath))))

                curBlkPath=get_param(curBlk,'parent');
                if strcmp(curBlkPath,bdroot(curBlk))
                    flagBlk1=[flagBlk1;curBlk];
                end
            else
                flagBlk1=[flagBlk1;curBlk];
            end
        end
    end

    FailingObjs=[flagBlk1;blkObj2];








    maskType=[
    {'Band-Limited White Noise'}
    {'chirp'}
    {'Counter Free-Running'}
    {'Counter Limited'}
    {'Enumerated Constant'}
    {'Ramp'}
    {'Repeating table'}
    {'Repeating Sequence Interpolated'}
    {'Repeating Sequence Stair'}
    {'Sigbuilder block'}
    {'SignalEditor'}
    {'WaveformGenerator'}
    ];

    blockType=[
    {'Inport'}
    {'Clock'}
    {'Constant'}
    {'DigitalClock'}
    {'FromWorkspace'}
    {'FromFile'}
    {'FromSpreadsheet'}
    {'Ground'}
    {'DiscretePulseGenerator'}
    {'RandomNumber'}
    {'SignalGenerator'}
    {'Sin'}
    {'Step'}
    {'UniformRandomNumber'}
    ];

    index=cellfun(@(x)ismember(get_param(x,'BlockType'),blockType),...
    FailingObjs,'UniformOutput',false);

    FailingObjs=FailingObjs(~[index{:}]);

    index=cellfun(@(x)ismember(get_param(x,'MaskType'),maskType),...
    FailingObjs,'UniformOutput',false);

    FailingObjs=FailingObjs(~[index{:}]);

end


function result=checkActionCallback(~)



    result=ModelAdvisor.Paragraph;

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);
    ch_result=mdladvObj.getCheckResult('mathworks.jmaab.jc_0641');


    failingObjs=ch_result{1}.ListObj;

    if isempty(failingObjs)
        return;
    end





    editProp=get_param(bdroot(failingObjs),'Lock');
    logicalIndex=strcmp(editProp,'on');
    nonEditableBlocks=failingObjs(logicalIndex);
    editableBlocks=failingObjs(~logicalIndex);




    if~isempty(editableBlocks)

        editableBlocks=get_param(editableBlocks,'Object');
        editableBlocks=[editableBlocks{:}];
        property={'SampleTime','SystemSampleTime'};

        for pCount=1:numel(property)

            isPropFlag=isprop(editableBlocks,property{pCount});
            arrayfun(@(x)set_param(x.handle,property{pCount},'-1'),...
            editableBlocks(isPropFlag))

        end

        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(0);
        ft.setInformation(DAStudio.message('ModelAdvisor:jmaab:jc_0621_autoFix1'));
        ft.setListObj(editableBlocks);
        result.addItem(ft.emitContent);
    end


    if~isempty(nonEditableBlocks)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(0);
        ft.setInformation(DAStudio.message('ModelAdvisor:jmaab:jc_0621_autoFix2'));
        ft.setListObj(nonEditableBlocks);
        result.addItem(ft.emitContent);
    end

end
