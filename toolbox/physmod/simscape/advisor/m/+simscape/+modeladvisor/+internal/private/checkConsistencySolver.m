function obj=checkConsistencySolver(objType)





    checkId=mfilename;


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,@updateAction);
end



function msg=getMessage(id)

    messageCatalog=...
    ['physmod:simscape:advisor:modeladvisor:',mfilename];
    msg=DAStudio.message([messageCatalog,':',id]);
end

function result=checkCallback(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    ft.setSubBar(false);


    blocks=nonUpdatedBlocks(findAllSolverBlocks(system));

    if isempty(blocks)

        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(getMessage('CheckResultPass'));

        mdladvObj.setCheckResultStatus(true);
    else

        ft.setSubResultStatus('Fail');
        ft.setSubResultStatusText(getMessage('CheckResultFail'));
        ft.setRecAction(getMessage('ActionDescription'));

        ft.setColTitles({getMessage('CheckResultColTitle')});
        for blockIdx=1:length(blocks)
            thisBlock=blocks{blockIdx};
            ft.addRow({thisBlock});
        end

        mdladvObj.setCheckResultStatus(false);
    end

    result={ft};
end

function blocks=findAllSolverBlocks(system)
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        blocks=find_system(system,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'Type','block',...
        'MaskType',sprintf('Solver\nConfiguration'));
    else
        blocks=find_system(system,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'Variants','ActiveVariants',...
        'Type','block',...
        'MaskType',sprintf('Solver\nConfiguration'));

        if~iscell(blocks)
            blocks={blocks};
        end
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    blocks=mdladvObj.filterResultWithExclusion(blocks);
end


function blocks=nonUpdatedBlocks(blocks)
    consistencySolver=get_param(blocks,'ConsistencySolver');
    blocks=blocks(strcmpi(consistencySolver,'NEWTON_FTOL'));
end


function result=updateAction(taskObj)

    system=get_param(taskObj.MAObj.System,'Name');


    blocks=nonUpdatedBlocks(findAllSolverBlocks(system));

    failed_blocks={};
    for i=1:numel(blocks)
        thisBlock=blocks{i};
        try
            set_param(thisBlock,'ConsistencySolver','NEWTON_XTOL_AFTER_FTOL');
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
