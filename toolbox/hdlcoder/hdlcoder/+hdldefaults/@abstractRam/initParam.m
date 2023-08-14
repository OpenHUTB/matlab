function initParam(this,RAMType)






    if strcmpi(RAMType,'dualport')
        this.InputPortNames={'wr_din','wr_addr','wr_en','rd_addr'};
        this.OutputPortNames={'wr_dout','rd_dout'};
    elseif strcmpi(RAMType,'simpledualport')
        this.InputPortNames={'wr_din','wr_addr','wr_en','rd_addr'};
        this.OutputPortNames={'rd_dout'};
    elseif strcmpi(RAMType,'singleport')
        this.InputPortNames={'din','addr','we'};
        this.OutputPortNames={'dout'};
    else
        error(message('hdlcoder:validate:unsupportedRAM'));
    end

    if strcmpi(RAMType,'singleport')
        blkParam.required={'ramIsComplex','ramIsGeneric','hasClkEn','readNewData'};
    else
        blkParam.required={'ramIsComplex','ramIsGeneric','hasClkEn'};
    end
    blkParam.optional={'numRam'};
    this.blkParams=blkParam;


