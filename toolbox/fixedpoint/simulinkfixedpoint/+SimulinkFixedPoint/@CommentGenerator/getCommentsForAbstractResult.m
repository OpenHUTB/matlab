function comments=getCommentsForAbstractResult(this,result)



    comments={};


    comments=[comments;getCommentsForLockedResult(this,result)];


    comments=[comments;getCommentsForProposedDT(this,result)];


    blockObject=result.UniqueIdentifier.getObject;
    comments=[comments;getCommentsForBlockObject(this,blockObject)];
end