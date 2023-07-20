classdef(Abstract)ReportObjectFactory





    properties(Access=protected)
Customisation
    end

    methods(Access=public)
        function obj=ReportObjectFactory(customisation)
            obj.Customisation=customisation;
        end
    end

    methods(Access=public,Abstract=true)
        reportObject=create(obj);
    end

end

