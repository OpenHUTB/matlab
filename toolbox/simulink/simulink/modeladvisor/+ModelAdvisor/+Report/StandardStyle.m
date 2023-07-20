classdef StandardStyle<ModelAdvisor.Report.CheckStyleFactory
    methods
        function obj=StandardStyle
            obj.Name=getString(message('ModelAdvisor:engine:RecommendedAction'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.Utils.sortObjs(elementsObj,'RecommendedAction',false);
            fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);
            html=fts;
        end

    end
end
