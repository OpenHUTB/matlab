classdef SpecificationSection<handle




    properties(Access=protected)
Specification
Dialog
    end

    methods(Abstract)
        sectionItems=getSectionItems(obj)
    end

    methods
        function obj=SpecificationSection(spec)
            obj.Specification=spec;
        end

        function applySpecification(obj)
            obj.Specification.applySpec();
        end

        function openCallback(obj,dlg)
            obj.Dialog=dlg;
        end

        function closeCallback(obj)

            obj.Dialog=[];
        end
    end
end

