classdef MatlabFunctionListingBuilder<matlab.internal.profileviewer.model.FunctionListingPayloadBuilder




    methods
        function obj=MatlabFunctionListingBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.FunctionListingPayloadBuilder(profileInterface);
            mlock;
        end
    end


    methods(Access=protected)
        function executedLines=buildExecutedLines(obj,adjustedExecutedLines)

            executedLines={};
            executedLines=obj.addExecutedLinesField(executedLines,adjustedExecutedLines,'LineNumber');
            executedLines=obj.addExecutedLinesField(executedLines,adjustedExecutedLines,'Calls');
            executedLines=obj.addExecutedLinesField(executedLines,adjustedExecutedLines,'Time');

            if obj.Config.WithMemoryData
                executedLines=obj.addExecutedLinesField(executedLines,adjustedExecutedLines,'AllocatedMemory');
                executedLines=obj.addExecutedLinesField(executedLines,adjustedExecutedLines,'FreedMemory');
                executedLines=obj.addExecutedLinesField(executedLines,adjustedExecutedLines,'PeakMemory');
            end
        end
    end
end
