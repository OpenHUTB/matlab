function setupLines(this,varargin)





    if isempty(varargin)
        flag=true;
    else
        flag=varargin{1};
    end
    flag=flag&&~this.CCDFMode;
    if this.NormalTraceFlag
        setupNormalTraceLines(this,false);
        updateLineProperties(this);
    end
    if this.MaxHoldTraceFlag&&flag
        this.MaxHoldTraceLines=addHoldLines(this,this.MaxHoldTraceLines,'Max');
        updateMaxMinHoldLineProperties(this,'Max');
    end
    if this.MinHoldTraceFlag&&flag
        this.MinHoldTraceLines=addHoldLines(this,this.MinHoldTraceLines,'Min');
        updateMaxMinHoldLineProperties(this,'Min');
    end
    if this.CCDFMode&&this.CCDFGaussianReferenceFlag
        addCCDFGaussianReferenceLine(this);
    end
end
