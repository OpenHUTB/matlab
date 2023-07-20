function comments=getComments(this,objForComments)







    comments={};

    if isa(objForComments,'SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer')
        comments=getCommentsForDTContainerInfo(this,objForComments);

    elseif isa(objForComments,'fxptds.AbstractSimulinkObjectResult')
        comments=getCommentsForAbstractSimulinkObjectResult(this,objForComments);

    elseif isa(objForComments,'fxptds.AbstractResult')
        comments=getCommentsForAbstractResult(this,objForComments);

    end
end


