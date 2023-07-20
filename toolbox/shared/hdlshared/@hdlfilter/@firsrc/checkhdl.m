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

    v=this.checkPipelineSupport;
    if v.Status
        return
    end

    if this.getHDLParameter('clockinputs')>1
        msg=['Multiple clocks are not supported for mfilt.firsrc filter. Only ''single'' is valid value for ''ClockInputs'' property in this case.'];
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:invalidClkInputs');
        return
    end

