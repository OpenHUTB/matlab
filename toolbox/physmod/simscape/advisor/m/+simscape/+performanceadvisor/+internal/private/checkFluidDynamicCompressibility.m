function obj=checkFluidDynamicCompressibility(objType)







    checkId=mfilename;


    obj=simscape.performanceadvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,...
    @updateAction);
end



function msg=getMessage(id)



    messageCatalog=['physmod:simscape:advisor:performanceadvisor:',mfilename];

    msg=DAStudio.message([messageCatalog,':',id]);
end


function result=checkCallback(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    ft.setCheckText(getMessage('CheckText'));

    ft.setSubBar(false);


    blocks=findAllBlocks(system);
    subOptimalBlocks=findSuboptimalBlocks(system);


    if isempty(blocks)

        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(getMessage('CheckResultPassNotApplicable'));

        mdladvObj.setCheckResultStatus(true);
    elseif isempty(subOptimalBlocks)

        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(getMessage('CheckResultPass'));

        mdladvObj.setCheckResultStatus(true);
    else

        ft.setSubResultStatus('Fail');
        ft.setSubResultStatusText(getMessage('CheckResultFail'));
        ft.setRecAction(getMessage('ActionDescription'));

        ft.setColTitles({getMessage('CheckResultCol1'),getMessage('CheckResultCol2')});
        for blockIdx=1:length(subOptimalBlocks)
            thisBlock=subOptimalBlocks{blockIdx};
            thisDynamicCompressibilityStr=get_param(thisBlock,'dynamic_compressibility');
            switch thisDynamicCompressibilityStr
            case '0'
                thisDynamicCompressibilityStr='Off';
            case '1'
                thisDynamicCompressibilityStr='On';
            otherwise
            end
            ft.addRow({thisBlock,thisDynamicCompressibilityStr});
        end

        mdladvObj.setCheckResultStatus(false);
    end

    result={ft};
end

function blocks=findAllBlocks(system)

    maskTypes={'Pipe (TL)',...
    sprintf('Rotational\nMechanical Converter\n(TL)'),...
    sprintf('Translational\nMechanical Converter\n(TL)')};

    if Simulink.internal.useFindSystemVariantsMatchFilter()
        findBlockOfMaskTypeFunc=@(mdl,maskType)find_system(mdl,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'Type','block',...
        'MaskType',maskType);
    else
        findBlockOfMaskTypeFunc=@(mdl,maskType)find_system(mdl,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'Variants','ActiveVariants',...
        'Type','block',...
        'MaskType',maskType);
    end

    blocks={};
    for maskTypeIdx=1:length(maskTypes)
        thisMaskType=maskTypes{maskTypeIdx};
        theseBlocks=findBlockOfMaskTypeFunc(system,thisMaskType);
        if~iscell(theseBlocks)
            theseBlocks={theseBlocks};
        end
        blocks=[blocks,theseBlocks];%#ok<AGROW>
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    blocks=mdladvObj.filterResultWithExclusion(blocks);
end

function blocks=findSuboptimalBlocks(system)

    blocks=findAllBlocks(system);


    dynamicCompressibility=get_param(blocks,'dynamic_compressibility');

    isDynamicCompressibility=strcmp('1',dynamicCompressibility);

    blocks=blocks(isDynamicCompressibility);
end

function result=updateAction(taskObj)

    system=get_param(taskObj.MAObj.System,'Name');


    blocks=findSuboptimalBlocks(system);

    failed_blocks={};
    for i=1:numel(blocks)
        thisBlock=blocks{i};
        try
            set_param(thisBlock,'dynamic_compressibility','0');
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
