function status=needResetBody(this,resetType)





    status=false;
    if strcmpi(resetType,'async')
        if this.hasAsyncReset
            status=true;
        end
    else
        if this.hasSyncReset
            status=true;
        end
    end
