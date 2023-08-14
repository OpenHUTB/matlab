function stepInGraph=getGraphForStepIn(block)

    stepInGraph=[];

    if(isSubSystemAndNotInExclusionList(block))
        graphName=getfullname(block);
        stepInGraph=get_param(graphName,'handle');
    elseif(isBlockNonProtectedModelRef(block))
        try
            graphName=get_param(block,'ModelName');
            proceedWhenBDisLoaded(graphName);
            stepInGraph=get_param(graphName,'handle');
        catch

        end
    end

end