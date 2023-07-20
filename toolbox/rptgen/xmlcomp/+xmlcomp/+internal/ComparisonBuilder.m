


classdef ComparisonBuilder<handle

    properties(SetAccess=private,GetAccess=public)
Sources
Parameters
    end

    methods(Access=public)

        function obj=ComparisonBuilder()
            import com.mathworks.comparisons.param.impl.ComparisonParameterSetImpl;
            obj.Parameters=ComparisonParameterSetImpl();
        end

        function obj=addSource(obj,source)
            obj.Sources{end+1}=source;
        end

        function obj=addParameter(obj,type,value)
            obj.Parameters.setValue(type,value);
        end

        function comparisonDriver=build(obj)
            comparisonDriver=xmlcomp.internal.ComparisonDriver(...
            obj.Sources{1},...
            obj.Sources{2},...
            obj.Parameters...
            );
        end

    end

end