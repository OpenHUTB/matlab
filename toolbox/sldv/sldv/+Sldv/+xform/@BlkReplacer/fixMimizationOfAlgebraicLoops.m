function fixMimizationOfAlgebraicLoops(obj,mdlRefItem)




    refmodelH=get_param(mdlRefItem.RefMdlName,'Handle');
    if strcmp(get_param(refmodelH,'ModelReferenceMinAlgLoopOccurrences'),'on')||...
        obj.HasAlgebraicLoop
        BlockH=mdlRefItem.ReplacementInfo.AfterReplacementH;
        set_param(BlockH,'MinAlgLoopOccurrences','on');
    end
end

