function v=checkhdl(this,varargin)







    v=this.checkAllCoeffsZero;
    if v.Status
        return
    end


    v=this.checkOneBitInput;
    if v.Status
        return
    end


    v=this.checkInvalidProps(varargin{:});
    if v.Status
        return
    end

    v=this.checkComplex;


