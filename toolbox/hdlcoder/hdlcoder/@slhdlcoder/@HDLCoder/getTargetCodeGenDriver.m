function targetCodeGenDriver=getTargetCodeGenDriver(this,p)





    if isempty(this.TargetCodeGenerationDriver)
        this.TargetCodeGenerationDriver=containers.Map('KeyType','char','ValueType','any');
    end

    modelName=p.ModelName;
    if~this.TargetCodeGenerationDriver.isKey(modelName)
        targetDriver=createDriver(this);
        this.TargetCodeGenerationDriver(modelName)=targetDriver;
    end
    targetCodeGenDriver=this.TargetCodeGenerationDriver(modelName);
end

function targetDriver=createDriver(this)
    fc=this.getParameter('FloatingPointTargetConfiguration');
    tool=this.getParameter('SynthesisTool');
    if targetcodegen.targetCodeGenerationUtils.isALTFPMode()
        if(any(strcmpi(tool,{'Altera Quartus II',''})))
            targetDriver=targetcodegen.alteradriver(fc);
        else
            error(message('hdlcommon:targetcodegen:ToolDependency',tool,'"Altera Quartus II" or empty','Altera MegaFunctions (ALTFP)'));
        end
    elseif targetcodegen.targetCodeGenerationUtils.isALTERAFPFUNCTIONSMode()
        if(any(strcmpi(tool,{'Altera Quartus II',''})))
            targetDriver=targetcodegen.alterafpfdriver(fc);
        elseif(any(strcmpi(tool,{'Intel Quartus Pro',''})))
            targetDriver=targetcodegen.alterafpfdriver(fc);
        else
            error(message('hdlcommon:targetcodegen:ToolDependency',tool,'"Altera Quartus II" or empty','Altera MegaFunctions (ALTERFA FP FUNCTIONS)'));
        end
    elseif targetcodegen.targetCodeGenerationUtils.isXilinxMode()
        if(any(strcmpi(tool,{'Xilinx ISE',''})))
            targetDriver=targetcodegen.xilinxdriver(fc);
        else
            error(message('hdlcommon:targetcodegen:ToolDependency',tool,'"Xilinx ISE" or empty','Xilinx LogiCORE'));
        end
    elseif targetcodegen.targetCodeGenerationUtils.isNFPMode()
        targetDriver=targetcodegen.nfpdriver(fc);
    else
        targetDriver=[];
    end
end
