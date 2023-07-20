function[simplifiable,subsystemOrMdl]=canBeSimplified(blockName,sopts)

    simplifiable=true;
    subsystemOrMdl=blockName;

    if strcmpi(get_param(blockName,'LinkStatus'),'resolved')||strcmpi(get_param(blockName,'LinkStatus'),'disabled')
        if~sopts.BreakLibraryLinks
            simplifiable=false;
        end
    elseif strcmpi(get_param(blockName,'LinkStatus'),'none')
        if slprivate('is_stateflow_based_block',blockName)
            simplifiable=false;
        elseif strcmpi(get_param(blockName,'BlockType'),'ModelReference')
            if~sopts.SimplifyMdlRefs
                simplifiable=false;
            end
            subsystemOrMdl=get_param(blockName,'ModelName');
        elseif~strcmpi(get_param(blockName,'BlockType'),'SubSystem')
            simplifiable=false;
        else
            if~sopts.SimplifySubSys
                simplifiable=false;
            end
        end
    end
