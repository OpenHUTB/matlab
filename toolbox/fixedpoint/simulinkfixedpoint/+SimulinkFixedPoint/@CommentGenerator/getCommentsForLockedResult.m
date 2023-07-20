function comments=getCommentsForLockedResult(this,result)



    comments={};
    if result.isLocked
        comments={getString(message([this.stringIDPrefix,'ResultLocked']))};
    end
end