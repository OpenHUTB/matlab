function comments=getCommentsForProposedDT(this,result)




    comments={};
    specifiedDTContainer=result.getSpecifiedDTContainerInfo;
    if~result.hasProposedDT

        comments=[comments;getCommentsForSpecifiedDT(this,specifiedDTContainer)];
    end

    isMutable=traceVar(specifiedDTContainer);

    if isMutable

        comments=[comments;...
        {getString(message([this.stringIDPrefix,'NamedDTControl'],...
        specifiedDTContainer.origDTString))}];








        if~isa(result,'fxptds.AbstractSimulinkObjectResult')

            comments=[comments;...
            {getString(message([this.stringIDPrefix,'SeeDataObjectsPane'],...
            specifiedDTContainer.origDTString))}];
        else


            listOfNamedTypes=getResolutionQueueForNamedType(specifiedDTContainer);
            if numel(listOfNamedTypes)>1

                delimiter='&#8594;';

                hierarchy=cellfun(@(x)[x,delimiter],listOfNamedTypes,'UniformOutput',false);
                hierarchy=[hierarchy{:}];
                hierarchy(end-numel(delimiter)+1:end)=[];

                comments=[comments;...
                {getString(message([this.stringIDPrefix,'NamedDTHierarchy'],...
                specifiedDTContainer.origDTString,...
                hierarchy))}];
            end
        end
    end
end


