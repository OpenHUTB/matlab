classdef MatlabDetailViewBuilder<matlab.internal.profileviewer.model.DetailViewPayloadBuilder




    methods
        function obj=MatlabDetailViewBuilder(profileInterface)
            import matlab.internal.profileviewer.model.*
            busyLinesPayloadBuilder=MatlabBusyLinesBuilder(profileInterface);
            childrenFunctionsPayloadBuilder=MatlabChildrenFunctionsBuilder(profileInterface);
            functionListingPayloadBuilder=MatlabFunctionListingBuilder(profileInterface);
            obj@matlab.internal.profileviewer.model.DetailViewPayloadBuilder(profileInterface,...
            busyLinesPayloadBuilder,childrenFunctionsPayloadBuilder,...
            functionListingPayloadBuilder);
            mlock;
        end
    end

    methods
        function functionTableItem=buildFunctionTableItemCustom(obj,functionTableItem)
            functionTableItem.IsMemoryProfile=obj.Config.WithMemoryData;
        end

        function flag=filterParent(~,~,~)
            flag=false;
        end
    end

    methods(Static)
        function matlabCodeAsCellArray=getmcode(fileName)
            matlabCodeAsCellArray=matlab.internal.profileviewer.model.getMatlabCodeAsCellArray(fileName);
        end

        function indexMap=buildExecutedLinesIndexMap(withMemoryData)









            executedLinesFields={'LineNumber','Calls','Time'};
            if withMemoryData
                executedLinesFields=[executedLinesFields,{'AllocatedMemory','FreedMemory','PeakMemory'}];
            end
            indexMap=matlab.internal.profileviewer.model.ExecutedLinesFieldMap(executedLinesFields);
        end
    end
end
