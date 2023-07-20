classdef SelectAnyNormal<Simulink.ModelReference.internal.GraphAnalysis.SimModeSelector




    methods

        function this=SelectAnyNormal(analyzer)
            this=this@Simulink.ModelReference.internal.GraphAnalysis.SimModeSelector(analyzer);
        end
    end

    methods(Access=protected)


        function indices=getIndices(obj)
            indices=find(obj.MyTable.Tag==Simulink.ModelReference.internal.GraphAnalysis.SimulationMode.Normal);
        end
    end
end