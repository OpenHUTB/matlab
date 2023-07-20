classdef Submodels<rtw.report.ExternalLinks





    properties
ModelReferencesReports
ModelReferences
    end

    methods
        function obj=Submodels(reports,allModels)
            obj=obj@rtw.report.ExternalLinks(DAStudio.message('RTW:report:SubmodelsShortTitle'));
            obj.ModelReferencesReports=reports;
            obj.ModelReferences=allModels;
            obj.execute;
        end
    end

    methods(Access=private)
        execute(obj)
    end
end


