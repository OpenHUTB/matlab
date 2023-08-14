classdef AutosarComponentWrapper<systemcomposer.internal.propertyInspector.wrappers.ViewArchitectureWrapper



    properties
    end

    methods
        function obj=AutosarComponentWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ViewArchitectureWrapper(varargin{:});
            obj.schemaType='ViewComponent';
        end
    end
end

