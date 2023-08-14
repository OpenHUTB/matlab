classdef ArchitectureTypeWrapper<systemcomposer.internal.propertyInspector.wrappers.ArchitectureElementWrapper



    properties
        IsInView;
    end

    methods
        function obj=ArchitectureTypeWrapper(varargin)
            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ArchitectureElementWrapper(varargin{:});
            if nargin>3
                obj.IsInView=varargin{4};
            else
                obj.IsInView=false;
            end

            obj.schemaType='ArchitectureType';
        end

        function type=getObjectType(~)
            type='ArchitectureType';
        end

        function setStereotypeElement(obj)
            obj.stereotypeElement=obj.element.getArchitecture;
        end

    end

end
