classdef NoHDL<hdlimplbase.HDLDirectCodeGen




    methods
        function this=NoHDL(~)
        end
    end

    methods
        v_settings=block_validate_settings(this,hC)
        state=getStateInfo(this,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
        v=validateBlock(this,hC)
    end

    methods(Hidden)
        registerImplParamInfo(this)
        retval=usesSimulinkHandleForModelGen(this,hN,hC)
        hNewC=elaborate(this,hN,hC)
        val=mustElaborateInPhase1(~,~,~)
    end
end