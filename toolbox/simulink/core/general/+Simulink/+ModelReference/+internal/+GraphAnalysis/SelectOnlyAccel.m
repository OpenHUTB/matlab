classdef SelectOnlyAccel<Simulink.ModelReference.internal.GraphAnalysis.SimModeSelector




    methods

        function this=SelectOnlyAccel(analyzer)
            this=this@Simulink.ModelReference.internal.GraphAnalysis.SimModeSelector(analyzer);
        end
    end

    methods(Access=protected)


        function indices=getIndices(obj)
            import Simulink.ModelReference.internal.GraphAnalysis.SimulationMode;

            uniqueNames=unique(obj.MyTable.Name,'stable');


            ind=arrayfun(@(x)(~any(...
            obj.MyTable.Tag(strcmp(obj.MyTable.Name,x)>0)==SimulationMode.Normal)),...
            uniqueNames);


            selectedNames=uniqueNames(ind);
            indices=[];


            for i=1:length(selectedNames)
                indices=[indices;find(strcmp(obj.MyTable.Name,selectedNames{i}))];%#ok<AGROW>
            end
        end
    end
end