function obj=checkOutdatedBlocks(objType)








    checkId='checkOutdatedBlocks';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkNonupdatedAcSourcesCallback,...
    @updateAcSourcesAction);
end



function msg=getMessage(id)



    messageCatalog='physmod:simscape:advisor:modeladvisor:checkOutdatedBlocks';

    msg=DAStudio.message([messageCatalog,':',id]);
end


function result=checkNonupdatedAcSourcesCallback(system)


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');

    ft.setCheckText(getMessage('CheckText'));
    ft.setSubBar(false);


    blocks=findNonupdatedAcSources(system);


    if isempty(blocks)

        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(getMessage('CheckResultPass'));

        mdladvObj.setCheckResultStatus(true);

    else

        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(getMessage('CheckResultWarn'));

        ft.setListObj(blocks);

        ft.setRecAction(getMessage('CheckResultAction'));

        mdladvObj.setCheckResultStatus(false);
    end

    result={ft};
end


function result=updateAcSourcesAction(taskObj)

    system=get_param(taskObj.MAObj.System,'Name');


    blocks=findNonupdatedAcSources(system);

    failed_blocks={};
    for i=1:numel(blocks)
        if~updateACSourceBlock(blocks{i})
            failed_blocks=[failed_blocks,blocks{i}];%#ok
        end
    end

    if isempty(failed_blocks)
        result=getMessage('ActionResultPass');
    else
        result=getMessage('ActionResultFail');
    end

end


function blocks=findNonupdatedAcSources(system)
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        simscape_blocks=find_system(system,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'BlockType','SimscapeBlock');
    else
        simscape_blocks=find_system(system,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'Variants','ActiveVariants',...
        'BlockType','SimscapeBlock');
        if~iscell(simscape_blocks)
            simscape_blocks={simscape_blocks};
        end
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    simscape_blocks=mdladvObj.filterResultWithExclusion(simscape_blocks);

    blocks=simscape.compiler.sli.internal.findnonupdatedacsources(simscape_blocks);
end


function success=updateACSourceBlock(block)


    success=true;


    pvs=simscape.library.internal.UpdateACSourcePVs(block);

    if isempty(pvs)
        return;
    else
        try
            set_param(block,pvs{:});
        catch
            success=false;
        end
    end
end

