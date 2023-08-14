classdef cosimDeployment<dnnfpga.bitstreambase.abstractDeployment



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=cosimDeployment(deployableNetwork,platform)
            obj@dnnfpga.bitstreambase.abstractDeployment(deployableNetwork,platform);
        end
    end

    methods(Access=public)
        function pass=check(this)
            pass=true;
        end

        function init(this)
        end

        function output=predict(this,input)
            if(~iscell(input))


                cellInput{1}=input;
            end
            output=this.m_deployableNetwork.predict(cellInput);
        end
    end
end

