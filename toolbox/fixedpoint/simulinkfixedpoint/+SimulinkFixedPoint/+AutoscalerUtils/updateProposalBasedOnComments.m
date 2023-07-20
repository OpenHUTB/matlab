function updatedDataType=updateProposalBasedOnComments(result)












    updatedDataType=[];


    blkObj=result.UniqueIdentifier.getObject;



    pathItem=result.UniqueIdentifier.getElementName;

    comments=result.getAutoscaler.checkComments(...
    blkObj,...
    pathItem);














    if~isempty(comments)
        result.addComment(comments);
        result.updateAcceptFlag;
        updatedDataType='n/a';
    end
end
