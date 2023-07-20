classdef abstractBBox<hdlimplbase.HDLDirectCodeGen



    methods
        function this=abstractBBox(~)
        end

    end

    methods
        baseBBoxRegisterImplParamInfo(this)
        v_settings=block_validate_settings(this,hC)
        hdlcode=finishEmit(this,hC)
        inportOffset=fixPorts(this,hC)
        generateClocks(this,hN,hC)
        name=getClockEnableInputPort(this,~)
        name=getClockInputPort(this,~)
        latencyInfo=getLatencyInfo(this,hC)
        name=getResetInputPort(this,~)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v=validateVerilogBlackBoxPorts(~,hC)
    end

end

