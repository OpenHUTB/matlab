function setUserActionInProgress(this,boolValue)
    if boolValue
        assert(this.userActionInProgress>=0,'MainManager userActionInProgress cannot be less than 0')
        this.userActionInProgress=this.userActionInProgress+1;
    else
        assert(this.userActionInProgress>0,'MainManager userActionInProgress is already 0')
        this.userActionInProgress=this.userActionInProgress-1;
        if this.userActionInProgress==0
            for cb=values(this.userActionFinishCallBacks)
                cb{1}();
            end
            this.userActionFinishCallBacks.remove(keys(this.userActionFinishCallBacks));
        end
    end
end
