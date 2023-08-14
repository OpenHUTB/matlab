classdef CommentGenerator<handle








    properties(Constant)



        stringIDPrefix='SimulinkFixedPoint:resultinfo:';
    end

    methods(Access=public)
        comments=getComments(this,objForComments);
    end

    methods(Access=private)
        comments=getCommentsForDTContainerInfo(this,DTConInfo);
        comments=getCommentsForSpecifiedDT(this,DTConInfo);
        comments=getCommentsForNamedDTClients(this,DTConInfo);

        comments=getCommentsForAbstractResult(this,result);
        comments=getCommentsForLockedResult(this,result);
        comments=getCommentsForBlockObject(this,blockObject);
        comments=getCommentsForAbstractSimulinkObjectResult(this,result);
        comments=getCommentsForProposedDT(this,result)
    end
end

