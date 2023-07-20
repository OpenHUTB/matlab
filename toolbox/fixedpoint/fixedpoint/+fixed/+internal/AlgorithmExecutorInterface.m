classdef(Abstract)AlgorithmExecutorInterface




%#codegen


    methods
        function y=exec(obj,x_in)

            y=execImpl(obj,x_in);
        end
    end


    properties(GetAccess=protected,SetAccess=immutable)
mTypesTable
    end


    methods(Access=protected)
        function obj=AlgorithmExecutorInterface(typesTable)
            coder.allowpcode('plain');
            obj.mTypesTable=coder.const(typesTable);
        end
    end


    methods(Abstract,Access=protected)
        y=execImpl(obj,x_in)
    end

end
