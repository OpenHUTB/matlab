classdef ExecutionFunction<coder.preview.internal.FunctionMemorySection




    methods
        function obj=ExecutionFunction(sourceDD,type,name)


            obj@coder.preview.internal.FunctionMemorySection(sourceDD,type,name);
        end
    end

    methods(Access=protected)
        function out=getMemorySectionEntry(obj)

            out=obj.getEntry.MemorySection;
        end

        function out=getFunctionNamingRule(obj)

            out=obj.getEntry.FunctionName;
        end
    end
end


