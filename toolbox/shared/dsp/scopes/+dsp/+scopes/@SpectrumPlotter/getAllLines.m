function hLines=getAllLines(this)




    hLines=[];
    if this.NormalTraceFlag
        hLines=[hLines,this.Lines];
    end
    if this.MaxHoldTraceFlag
        hLines=[hLines,this.MaxHoldTraceLines];
    end
    if this.MinHoldTraceFlag
        hLines=[hLines,this.MinHoldTraceLines];
    end
end
