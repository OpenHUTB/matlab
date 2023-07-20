
classdef CompareFloatEquality<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=CompareFloatEquality(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
        end

        function algorithm(this)
            this.cgirCheckAlgorithm('NODE_FLOAT_EQUALITY','D1.1');
        end

        function report(this)
            this.cgirCheckReport();
        end

    end

end

