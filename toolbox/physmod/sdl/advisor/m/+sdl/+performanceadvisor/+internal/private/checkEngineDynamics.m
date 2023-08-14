function obj=checkEngineDynamics(objType)






    checkId=mfilename;


    obj=sdl.performanceadvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,...
    @updateAction);

end



function msg=getMessage(id)



    messageCatalog=['physmod:sdl:performanceadvisor:',mfilename];

    msg=DAStudio.message([messageCatalog,':',id]);
end


function result=checkCallback(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    ft.setCheckText(getMessage('CheckText'));

    ft.setColTitles({getMessage('CheckResultCol1'),getMessage('CheckResultCol2')});

    ft.setSubBar(false);


    blocks=findSuboptimalBlocks(system);


    if isempty(blocks)

        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(getMessage('CheckResultPass'));

        mdladvObj.setCheckResultStatus(true);

    else
        EngineTimeConstantStr=get_param(blocks,'model_time_constant');

        isDisabled=strcmp('0',EngineTimeConstantStr);


        menuStrings={getMessage('EngineTimeConstantNo'),getMessage('EngineTimeConstantYes')};
        for blockIdx=1:length(blocks)
            thisBlock=blocks{blockIdx};
            thisEnabledStr=menuStrings{1+str2double(EngineTimeConstantStr(blockIdx))};
            ft.addRow({thisBlock,thisEnabledStr});
        end

        if all(isDisabled)

            ft.setSubResultStatus('Pass');
            ft.setSubResultStatusText(getMessage('CheckResultPass'));

            mdladvObj.setCheckResultStatus(true);
        else

            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(getMessage('CheckResultWarn'));
            ft.setRecAction(getMessage('ActionDescription'));

            mdladvObj.setCheckResultStatus(false);
        end

    end

    result={ft};
end

function blocks=findSuboptimalBlocks(system)
    if Simulink.internal.useFindSystemVariantsMatchFilter()



        blocks=find_system(system,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'RegExp','on',...
        'Type','block',...
        'MaskType','Generic Engine',...
        'model_time_constant','1',...
        'ReferenceBlock','^sdl_lib');
    else
        blocks=find_system(system,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'Variants','ActiveVariants',...
        'Type','block',...
        'MaskType','Generic Engine',...
        'model_time_constant','1');
        if~iscell(blocks)
            blocks={blocks};
        end


        RefBlocks=get_param(blocks,'ReferenceBlock');
        temp=regexp(RefBlocks,'sdl_lib');
        idx=[];
        for i=1:length(temp)
            if~isempty(temp{i})
                idx=[idx,i];%#ok<AGROW>
            end
        end
        blocks=blocks(idx);
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    blocks=mdladvObj.filterResultWithExclusion(blocks);

end

function result=updateAction(taskObj)

    system=get_param(taskObj.MAObj.System,'Name');


    blocks=findSuboptimalBlocks(system);

    failed_blocks={};
    for i=1:numel(blocks)
        thisBlock=blocks{i};
        try
            set_param(thisBlock,'model_time_constant','0');
        catch
            failed_blocks=[failed_blocks,thisBlock];%#ok
        end
    end

    if isempty(failed_blocks)
        result=getMessage('ActionResultPass');
    else
        result=getMessage('ActionResultFail');
    end
end
