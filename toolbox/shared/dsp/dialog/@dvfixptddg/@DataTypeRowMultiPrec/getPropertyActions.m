function rtn=getPropertyActions(this,propName,currentValue)



    try
        rtn=getPropertyActions(this.Block,propName,currentValue);
    catch
        rtn=[];
    end

