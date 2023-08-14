classdef abstractRam<hdldefaults.abstractReg



    properties

        InputPortNames=[];

        OutputPortNames=[];

        numRam=1;
    end

    methods
        function this=abstractRam(~)
        end
    end

    methods
        function set.numRam(obj,value)

            validateattributes(value,{'int32'},{'scalar'},'','numRam')
            obj.numRam=value;
        end
    end

    methods
        displayCodeGenMsg(~,hC,fullpathname,fullfilename)
        hdlcode=finishEmit(this,hC)
        inportOffset=fixPorts(this,hC,hasClkEn)
        generateClocks(this,hN,hC)
        hdlparam=getBlockParam(this,hC,param)
        str=getCodeGenMode(this)
        [hasClkEn,ramIsComplex]=getRamImplParam(this,inputData)
        val=hasDesignDelay(~,~,~)
        str=ramFileHeader(this,filename,blockname,blockpath)
        registerImplParamInfo(this)
        setRamInportName(this,hC,complexPostfix,inportOffset)
        setRamOutportName(this,hC,complexPostfix)
        v=validateImplParams(this,hC)
    end

    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        initParam(this,RAMType)
    end
end


