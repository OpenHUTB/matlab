classdef MultiLUTCompressionStrategy<handle




    properties(Access=protected)
        Solutions cell
    end

    methods(Abstract)
        execute(this,blockPaths,options);
    end

    methods(Hidden)
        function addSolution(this,solution,index,options)
            if~isempty(solution)
                this.Solutions{index}=solution;
                FunctionApproximation.internal.DisplayUtils.displayCompressedSolutionFoundForBlockPath(solution,options);
            end
        end
    end

    methods(Sealed)
        function solutions=getSolutions(this)
            solutions=this.Solutions;
        end
    end

    methods(Static)
        function options=updateOptions(lutPath,options)
            maskType=get_param(lutPath,'MaskType');
            if ismember(maskType,{'Curve','Map'})
                options.AUTOSARCompliant=true;
            end
        end
    end
end