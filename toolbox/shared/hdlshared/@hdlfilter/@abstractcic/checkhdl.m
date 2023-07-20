function v=checkhdl(this,varargin)







    v=this.checkOneBitInput;
    if v.Status
        return
    end


    v=this.checkInvalidProps(varargin{:});
    if v.Status
        return
    end

    v=this.checkComplex;
    if v.Status
        return
    end

    v=this.checkVarRate;
    if v.Status
        return
    end


