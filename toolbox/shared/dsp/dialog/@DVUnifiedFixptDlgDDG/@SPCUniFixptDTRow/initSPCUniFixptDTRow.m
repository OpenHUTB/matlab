function this=initSPCUniFixptDTRow(this,type,rowIndex,controller)

    this.Controller=controller;
    this.Block=controller.block;
    this.Row=rowIndex;
    [prfxStr,nmStr]=udtGetPrmPrefixFromFixptDTRowStruct(type);
    this.Prefix=prfxStr;
    this.Name=nmStr;

    if isfield(type,'autoSignedness')
        this.AutoSignedness=type.autoSignedness;
        this.SignedSignedness=0;
        this.UnsignedSignedness=0;
    end
    if isfield(type,'signedSignedness')
        this.SignedSignedness=type.signedSignedness;
    end
    if isfield(type,'unsignedSignedness')
        this.UnsignedSignedness=type.unsignedSignedness;
    end

    if isfield(type,'binaryPointScaling')
        this.BinaryPointScaling=type.binaryPointScaling;
    end
    if isfield(type,'bestPrecisionMode')
        this.BestPrecisionMode=type.bestPrecisionMode;
    end



    if isfield(type,'customInhRuleStrs')
        customInheritRuleCellArray=type.customInhRuleStrs;
        if~isempty(customInheritRuleCellArray)
            this.CustomInhRuleStrs=customInheritRuleCellArray;
        end
    end

    if isfield(type,'inheritInternalRule')
        this.InheritInternalRule=type.inheritInternalRule;
    end


    if isfield(type,'inheritSameWLAsInput')
        this.InheritSameWLAsInput=type.inheritSameWLAsInput;
    end


    if isfield(type,'inheritInput')
        this.InheritInput=type.inheritInput;
    end


    if isfield(type,'inheritFirstInput')
        this.InheritFirstInput=type.inheritFirstInput;
    end


    if isfield(type,'inheritSecondInput')
        this.InheritSecondInput=type.inheritSecondInput;
    end


    if isfield(type,'inheritProdOutput')
        this.InheritProdOutput=type.inheritProdOutput;
    end


    if isfield(type,'inheritAccumulator')
        this.InheritAccum=type.inheritAccumulator;
    end



    if isfield(type,'hasDesignMin')
        this.HasDesignMin=type.hasDesignMin;
    end

    if isfield(type,'hasDesignMax')
        this.HasDesignMax=type.hasDesignMax;
    end

    if isfield(type,'valBestPrecFLMaskPrm')
        this.ValBestPrecFLMaskPrm=type.valBestPrecFLMaskPrm;
    else
        this.ValBestPrecFLMaskPrm='';
    end

    this.loadFromBlock;
