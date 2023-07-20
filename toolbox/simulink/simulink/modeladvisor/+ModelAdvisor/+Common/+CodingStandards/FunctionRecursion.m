
classdef FunctionRecursion<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=FunctionRecursion(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
        end

        function res=algorithm(this)
            res=this.cgirCheckAlgorithm('NODE_FCN_RECURSION','17.2');
        end

        function report(this)
            this.cgirCheckReport();
        end

    end

end

