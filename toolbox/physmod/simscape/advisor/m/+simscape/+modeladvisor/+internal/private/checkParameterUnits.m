function obj=checkParameterUnits(objType)







    checkId='checkParameterUnits';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkParameterUnitsCallback);
end



function msg=getMessage(id)



    messageCatalog='physmod:simscape:advisor:modeladvisor:checkParameterUnits';

    msg=DAStudio.message([messageCatalog,':',id]);
end


function result=checkParameterUnitsCallback(system)





    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    ft.setCheckText(getMessage('CheckText'));

    ft.setColTitles({getMessage('CheckResultCol1'),getMessage('CheckResultCol2')});

    ft.setSubBar(false);


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

    simscape_blocks=mdladvObj.filterResultWithExclusion(simscape_blocks);

    [blocks,exes]=simscape.compiler.sli.internal.findnonconvertibleunits(simscape_blocks);


    if isempty(blocks)

        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(getMessage('CheckResultPass'));

        mdladvObj.setCheckResultStatus(true);

    else


        for i=1:length(blocks)
            blk=blocks{i};
            exe=exes{i};
            causes=exe.cause;
            for j=1:numel(causes)
                submsg=causes{j}.message;
                ft.addRow({blk,submsg});
            end
        end

        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(getMessage('CheckResultWarn'));

        ft.setRecAction(getMessage('CheckResultAction'));

        mdladvObj.setCheckResultStatus(false);
    end

    result={ft};
end

