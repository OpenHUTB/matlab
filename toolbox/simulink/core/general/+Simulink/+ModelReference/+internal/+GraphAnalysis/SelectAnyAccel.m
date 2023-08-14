classdef SelectAnyAccel<Simulink.ModelReference.internal.GraphAnalysis.SimModeSelector




    methods

        function this=SelectAnyAccel(analyzer)
            this=this@Simulink.ModelReference.internal.GraphAnalysis.SimModeSelector(analyzer);
        end
    end

    methods(Access=protected)


        function indices=getIndices(obj)
            indices=find(obj.MyTable.Tag==Simulink.ModelReference.internal.GraphAnalysis.SimulationMode.Accel);
        end
    end
end