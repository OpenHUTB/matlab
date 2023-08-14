function obj=checkSimscapeSolverBlock(objType)






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


        ft.setColTitles({getMessage('CheckResultCol1'),getMessage('CheckResultCol3'),getMessage('CheckResultCol5')});
        for blockIdx=1:length(blocks)
            thisBlock=blocks{blockIdx};
            thisMaskWSVariables=get_param(thisBlock,'MaskWSVariables');
            thisLocalSolverChoiceStr=getLocalSolverChoiceStr(thisBlock);
            thisLocalSolverSampleTime=thisMaskWSVariables(strcmp('LocalSolverSampleTime',{thisMaskWSVariables(:).Name})).Value;
            if~isempty(thisLocalSolverSampleTime)
                ft.addRow({thisBlock,thisLocalSolverChoiceStr,thisLocalSolverSampleTime});
            else
                ft.addRow({thisBlock,thisLocalSolverChoiceStr,''});
            end
        end

        mdladvObj.setCheckResultStatus(true);
    else

        ft.setSubResultStatus('Fail');
        ft.setSubResultStatusText(getMessage('CheckResultFail'));
        ft.setRecAction(getMessage('ActionDescription'));

        ft.setColTitles({getMessage('CheckResultCol1'),getMessage('CheckResultCol2'),getMessage('CheckResultCol3'),getMessage('CheckResultCol4')});
        for blockIdx=1:length(subOptimalBlocks)
            thisBlock=subOptimalBlocks{blockIdx};
            thisUseLocalSolverStr=get_param(thisBlock,'UseLocalSolver');
            thisLocalSolverChoiceStr=getLocalSolverChoiceStr(thisBlock);
            thisDoFixedCostStr=get_param(thisBlock,'DoFixedCost');
            ft.addRow({thisBlock,thisUseLocalSolverStr,thisLocalSolverChoiceStr,thisDoFixedCostStr});
        end

        mdladvObj.setCheckResultStatus(false);
    end

    result={ft};
end

function blocks=findAllBlocks(system)
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

function blocks=findSuboptimalBlocks(system)

    blocks=findAllBlocks(system);


    useLocalSolverStr=get_param(blocks,'UseLocalSolver');
    localSolverChoiceStr=get_param(blocks,'LocalSolverChoice');
    doFixedCostStr=get_param(blocks,'DoFixedCost');

    isUsingLocalSolver=strcmp('on',useLocalSolverStr);
    isUsingPartitioningSolver=strcmp('NE_PARTITIONING_ADVANCER',localSolverChoiceStr);
    isUsingBackwardEulerSolver=strcmp('NE_BACKWARD_EULER_ADVANCER',localSolverChoiceStr);
    isDoingFixedCost=strcmp('on',doFixedCostStr);

    blocks=blocks(~isUsingLocalSolver|~(isUsingPartitioningSolver|isUsingBackwardEulerSolver)|~isDoingFixedCost);
end

function result=updateAction(taskObj)

    system=get_param(taskObj.MAObj.System,'Name');


    blocks=findSuboptimalBlocks(system);

    failed_blocks={};
    for i=1:numel(blocks)
        thisBlock=blocks{i};
        try
            set_param(thisBlock,'UseLocalSolver','on');
            set_param(thisBlock,'LocalSolverChoice','NE_PARTITIONING_ADVANCER');
            set_param(thisBlock,'DoFixedCost','on');
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

function thisLocalSolverChoiceStr=getLocalSolverChoiceStr(thisBlock)
    thisLocalSolverChoiceStr=get_param(thisBlock,'LocalSolverChoice');
    switch thisLocalSolverChoiceStr
    case 'NE_BACKWARD_EULER_ADVANCER'
        thisLocalSolverChoiceStr=getMessage('NE_BACKWARD_EULER_ADVANCER');
    case 'NE_TRAPEZOIDAL_ADVANCER'
        thisLocalSolverChoiceStr=getMessage('NE_TRAPEZOIDAL_ADVANCER');
    case 'NE_PARTITIONING_ADVANCER'
        thisLocalSolverChoiceStr=getMessage('NE_PARTITIONING_ADVANCER');
    otherwise

    end
end
