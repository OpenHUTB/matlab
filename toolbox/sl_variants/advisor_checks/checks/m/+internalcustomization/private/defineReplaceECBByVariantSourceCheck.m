



function defineReplaceECBByVariantSourceCheck()



    slReplaceECBByVariantSource=ModelAdvisor.Check('mathworks.design.ReplaceEnvironmentControllerBlk');
    slReplaceECBByVariantSource.Title=DAStudio.message('Simulink:VariantAdvisorChecks:MATitleReplaceECBByVariantSource');
    slReplaceECBByVariantSource.TitleTips=DAStudio.message('Simulink:VariantAdvisorChecks:MATitletipReplaceECBByVariantSource');
    slReplaceECBByVariantSource.CSHParameters.MapKey='ma.simulink';
    slReplaceECBByVariantSource.CSHParameters.TopicID='MATitleReplaceECBByVariantSource';
    slReplaceECBByVariantSource.setCallbackFcn(@ExecReplaceECBByVariantSource,'None','StyleThree');
    slReplaceECBByVariantSource.Value=true;
    slReplaceECBByVariantSource.SupportExclusion=true;
    slReplaceECBByVariantSource.SupportLibrary=true;

    slReplaceECBByVariantSourceAction=ModelAdvisor.Action;
    slReplaceECBByVariantSourceAction.Name=DAStudio.message('Simulink:VariantAdvisorChecks:MAReplaceECBByVariantSourceActionButtonName');
    slReplaceECBByVariantSourceAction.Description=DAStudio.message('Simulink:VariantAdvisorChecks:MAReplaceECBByVariantSourceActionDescription');
    slReplaceECBByVariantSourceAction.setCallbackFcn(@ActionReplaceECBByVariantSource);

    slReplaceECBByVariantSource.setAction(slReplaceECBByVariantSourceAction);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(slReplaceECBByVariantSource,'Simulink');
end






function result=FindEnvironmentControllerBlocks(system)
    result={};


    ecb_blocks=find_system(system,'LookInsideSubsystemReference','off',...
    'MatchFilter',@Simulink.match.allVariants,'FollowLinks','off',...
    'LookUnderMasks','on','BlockType','SubSystem','Mask','on',...
    'ReferenceBlock',['simulink_need_slupdate/Environment',newline,'Controller']);


    ecb_blocks_hndl=[];
    for i=1:length(ecb_blocks)
        handlCell=get_param(ecb_blocks(i),'Handle');
        ecb_blocks_hndl=[ecb_blocks_hndl,handlCell{1}];
    end


    replfilt=[];
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    for i=1:length(ecb_blocks_hndl)

        filteredBlock=mdladvObj.filterResultWithExclusion(ecb_blocks_hndl(i));
        if~isempty(filteredBlock)
            replfilt=[replfilt,ecb_blocks_hndl(i)];
        end
    end
    replBlocks=replfilt;


    replnm={};
    for i=1:length(replBlocks)
        tmpName=[get_param(replBlocks(i),'Parent'),'/',get_param(replBlocks(i),'Name')];
        replnm{i}=tmpName;
    end

    replnm=sort(replnm);


    result=replnm;
end






function[ResultDescription,ResultHandles]=ExecReplaceECBByVariantSource(system)

    ResultDescription={};
    ResultHandles={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
    currentCheckObj.Action.Enable=false;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');


    currentResult=FindEnvironmentControllerBlocks(system);


    if~isempty(currentResult)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('Simulink:VariantAdvisorChecks:MAMsgReplaceECBByVariantSourceWarn'));
        ft.setListObj(currentResult);
        ft.setRecAction(DAStudio.message('Simulink:VariantAdvisorChecks:MAMsgReplaceECBByVariantSourceSuggest'));
        currentCheckObj.Action.Enable=true;
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('Simulink:VariantAdvisorChecks:MAMsgReplaceECBByVariantSourcePass'));
        mdladvObj.setCheckResultStatus(true);
    end

    ft.setSubBar(0);
    ResultDescription{end+1}=ft;
    ResultHandles{end+1}=[];
end







function result=ActionReplaceECBByVariantSource(taskobj)

    mdladvObj=taskobj.MAObj;
    ch_result=mdladvObj.getCheckResult(taskobj.MAC);
    replBlocks=ch_result{1,1}{1,1}.ListObj;

    nl=sprintf('\n');
    result=['<ul> <li> ',DAStudio.message('Simulink:VariantAdvisorChecks:MAReplaceECBByVariantSourceActionResults'),nl,'<ul> '];

    for i=1:length(replBlocks)

        oldBlk=get_param(replBlocks{i},'Handle');
        newBlk='simulink/Signal Routing/Variant Source';
        newHandle=slInternal('replace_block',oldBlk,newBlk);

        set_param(newHandle,'VariantControlMode','sim codegen switching');
        set_param(newHandle,'VariantActivationTime','update diagram');
        set_param(newHandle,'VariantControls',{'(sim)','(codegen)'});
        set_param(newHandle,'ShowConditionOnBlock','on');
        block_name=get_param(newHandle,'Name');
        block_name=replace(block_name,['Environment',newline,'Controller'],'Variant Source');
        set_param(newHandle,'Name',block_name);

        blkName=replBlocks{i};
        newBlkName=replace(blkName,['Environment',newline,'Controller'],'Variant Source');
        dispBlkName=regexprep(newBlkName,nl,' ');
        codeBlkName=modeladvisorprivate('HTMLjsencode',newBlkName,'encode');
        codeBlkName=[codeBlkName{:}];
        result=[result,nl,' <li> <a href="matlab:modeladvisorprivate(''hiliteSystem'',''',codeBlkName,''')">',dispBlkName,'</a></li>'];
    end
    result=[result,nl,'</ul> </li> </ul>'];
end
