function foundBlks=local_findSystem(varargin)







    hScope=varargin{1};
    if isnumeric(hScope)
        curModelName=getfullname(hScope);
    else
        curModelName=hScope;
    end



    allBlocks=find_system(curModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,varargin{2:end});

    activeBlkIndex=[];

    for idx=1:numel(allBlocks)
        curBlock=allBlocks{idx};
        if strcmp(get_param(curBlock,'CompiledIsActive'),'on')
            activeBlkIndex(end+1)=idx;%#ok<AGROW>
        end
    end

    foundBlks=allBlocks(activeBlkIndex);
