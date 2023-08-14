function actualSourcesIDs=getActualSrcForResult(result)












    if isa(result,'fxptds.AbstractSimulinkObjectResult')
        actualSourcesIDs=result.getActualSourceIDs;
    else


        actualSourcesIDs={result.UniqueIdentifier};
    end

end
