classdef StateflowNodeAnalyzer<dependencies.internal.analysis.simulink.SimulinkModelAnalyzer




    properties(Constant)
        Extensions=".sfx";
    end

    methods
        function this=StateflowNodeAnalyzer(varargin)
            if nargin==0
                varargin={[
                dependencies.internal.analysis.simulink.StateflowAnalyzer
                dependencies.internal.analysis.simulink.StateflowEnumeratedConstantAnalyzer
                dependencies.internal.analysis.simulink.EMLAnalyzer
                ]};
            end
            this@dependencies.internal.analysis.simulink.SimulinkModelAnalyzer(varargin{:});
        end
    end

end
