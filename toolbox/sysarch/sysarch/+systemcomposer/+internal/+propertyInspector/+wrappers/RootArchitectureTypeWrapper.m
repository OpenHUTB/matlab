classdef RootArchitectureTypeWrapper<systemcomposer.internal.propertyInspector.wrappers.ArchitectureElementWrapper



    properties
        IsInView;
    end

    methods
        function obj=RootArchitectureTypeWrapper(varargin)
            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ArchitectureElementWrapper(varargin{:});
            if nargin>3
                obj.IsInView=varargin{4};
            else
                obj.IsInView=false;
            end

            obj.schemaType='RootArchitectureType';
        end

        function type=getObjectType(~)
            type='RootArchitectureType';
        end

        function setStereotypeElement(obj)
            obj.stereotypeElement=obj.element;
        end

        function name=getName(obj)
            name=obj.element.getName;
        end
    end

end
