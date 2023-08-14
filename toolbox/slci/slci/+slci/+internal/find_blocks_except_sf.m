function blocks=find_blocks_except_sf(ctxt,lookundermasks,followlinks)




    if(nargin<2)
        lookundermasks='on';
        followlinks='on';
    elseif(nargin<3)
        followlinks='on';
    end

    if Simulink.internal.useFindSystemVariantsMatchFilter()
        allBlocks=find_system(ctxt,'AllBlocks','on',...
        'LookUnderMasks',lookundermasks,...
        'FollowLinks',followlinks,...
        'MatchFilter',@Simulink.match.activeVariants,...
        'LookUnderReadProtectedSubsystems','on',...
        'Type','block');
    else
        allBlocks=find_system(ctxt,'AllBlocks','on',...
        'LookUnderMasks',lookundermasks,...
        'FollowLinks',followlinks,...
        'LookUnderReadProtectedSubsystems','on',...
        'Type','block');
    end


    sfBlocksIdx=slci.internal.isStateflowBasedBlock(allBlocks);
    sfBlocks=allBlocks(sfBlocksIdx);


    hiddenBlocks=[];
    for i=1:numel(sfBlocks)
        sfBlock=sfBlocks(i);


        insideSfBlock=find_system(sfBlock,'AllBlocks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks',lookundermasks,...
        'FollowLinks',followlinks,...
        'LookUnderReadProtectedSubsystems','on',...
        'Type','block');
        insideSfBlock=setdiff(insideSfBlock,sfBlock);


        insideSfSSBlock=find_blocks_inside_sf_slfunctions(sfBlock,lookundermasks,followlinks);
        insideSfBlock=setdiff(insideSfBlock,insideSfSSBlock);

        hiddenBlocks=[hiddenBlocks;insideSfBlock];%#ok
        hiddenBlocks=unique(hiddenBlocks);
    end


    for i=1:numel(allBlocks)
        block=allBlocks(i);
        if strcmp(get_param(block,'Type'),'block')...
            &&~strcmp(get_param(block,'IOType'),'none')...
            &&~strcmpi(get_param(block,'IOType'),'siggen')


            insideViewerBlocks=find_system(block,'AllBlocks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lookundermasks,...
            'FollowLinks',followlinks,...
            'LookUnderReadProtectedSubsystems','on',...
            'Type','block');
            hiddenBlocks=[hiddenBlocks;insideViewerBlocks];%#ok
        end
    end
    hiddenBlocks=unique(hiddenBlocks);

    if~isempty(hiddenBlocks)

        [~,idxs]=setdiff(allBlocks,hiddenBlocks);

        blocks=allBlocks(sort(idxs));
    else
        blocks=allBlocks;
    end
end

function blkList=find_blocks_inside_sf_slfunctions(sfBlockHandle,lookundermasks,followlinks)
    blkList=[];
    chartId=sfprivate('block2chart',sfBlockHandle);
    chartUDDObj=idToHandle(sfroot,chartId);
    if isempty(chartUDDObj)
        return;
    end
    slFunctions=slci.internal.getSFActiveObjs(...
    chartUDDObj.find('-isa','Stateflow.SLFunction'));
    for i=1:numel(slFunctions)




        path=Simulink.ID.getFullName(sfBlockHandle);
        name=sf('get',slFunctions(i).Id,'.simulink.blockName');
        fnName=[path,'/',name];


        ssBlkHandle=get_param(fnName,'Handle');


        insideSSBlk=find_system(ssBlkHandle,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'AllBlocks','on',...
        'LookUnderMasks',lookundermasks,...
        'FollowLinks',followlinks,...
        'LookUnderReadProtectedSubsystems','on',...
        'Type','block');
        blkList=[blkList;insideSSBlk];%#ok                   
    end
end
