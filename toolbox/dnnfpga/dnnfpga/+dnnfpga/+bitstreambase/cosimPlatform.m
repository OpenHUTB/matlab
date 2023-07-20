classdef cosimPlatform<dnnfpga.bitstreambase.abstractPlatform



    properties(Access=private)
m_processor
    end

    methods(Access=public,Hidden=true)
        function obj=cosimPlatform(processor)
            obj@dnnfpga.bitstreambase.abstractPlatform();
            obj.m_processor=processor;
        end
    end

    methods(Access=public)
        function deploySanityCheck(~,~)
        end

        function executeSanityCheck(~,~)
        end

        function printAddress(~)
        end

        function deploy(~,~)
        end

        function result=execute(this,data)
        end
    end
end

