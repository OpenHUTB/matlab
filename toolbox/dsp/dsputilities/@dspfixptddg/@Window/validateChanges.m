function errmsg=validateChanges(this)







    errmsg='';
    success=1;



    if strcmp(this.wintype,'User defined')&&this.OptParams
        addlargsstr=this.UserParams;
        try
            addlargs=evalin('base',addlargsstr);
            if~iscell(addlargs)
                success=0;
            end
        catch
            success=0;
        end
    end
    if~success
        errmsg='Additional window function arguments must be specified in a cell array.';
    end
