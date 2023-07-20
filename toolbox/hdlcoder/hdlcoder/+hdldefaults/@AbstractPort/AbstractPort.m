classdef AbstractPort<hdlimplbase.PortBase




    methods
        function this=AbstractPort(~)
        end
    end

    methods
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        setPortImplParams(this,hPort,isTopNetworkPort)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

