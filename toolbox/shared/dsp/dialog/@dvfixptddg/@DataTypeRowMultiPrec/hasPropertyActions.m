function rtn=hasPropertyActions(this,propName)



    try
        rtn=hasPropertyActions(this.Block,propName);
    catch
        rtn=false;
    end

