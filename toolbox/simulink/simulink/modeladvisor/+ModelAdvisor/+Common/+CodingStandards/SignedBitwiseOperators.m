
classdef SignedBitwiseOperators<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=SignedBitwiseOperators(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
        end

        function algorithm(this)
            this.cgirCheckAlgorithm('NODE_SIGNED_BITOPS','10.1');
        end

        function report(this)
            this.cgirCheckReport();
        end

    end

end

