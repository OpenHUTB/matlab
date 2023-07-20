function commentDas=addComment(this)






    commentData=this.dataModelObj.addComment();
    commentDas=slreq.das.Comment(commentData);
end
