function setDataType(this,slBlockName,sltype)

    setOutDataTypeStr(this,slBlockName,sltype);

    if sltype.isvector
        set_param(slBlockName,'PortDimensions',sltype.sldims);
    end

    if sltype.iscomplex
        set_param(slBlockName,'SignalType','complex');
    end

end
