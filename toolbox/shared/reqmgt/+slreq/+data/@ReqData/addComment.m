function commentObj=addComment(this,reqOrLink)






    comment=slreq.datamodel.Comment(this.model);
    comment.date=datetime('now','TimeZone','UTC');
    if ispc
        comment.commentedBy=getenv('USERNAME');
    else
        comment.commentedBy=getenv('USER');
    end
    comment.commentedRevision=reqOrLink.revision;
    sourceMfObj=this.getModelObj(reqOrLink);
    sourceMfObj.comments.add(comment);

    commentObj=this.wrap(comment);


    if isa(sourceMfObj,'slreq.datamodel.RequirementItem')
        mfReqLinkSet=sourceMfObj.requirementSet;
    elseif isa(sourceMfObj,'slreq.datamodel.Link')
        mfReqLinkSet=sourceMfObj.source.artifact;
    else



    end
    if~mfReqLinkSet.dirty

        dataReqLinkSet=this.wrap(mfReqLinkSet);
        dataReqLinkSet.setDirty(true);
    end
end
