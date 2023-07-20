classdef BlockStyle<ModelAdvisor.Report.StyleFactory
    methods
        function obj=BlockStyle
            obj.Name=getString(message('ModelAdvisor:engine:Block'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.Utils.sortObjs(elementsObj,'Block',false);
            fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);
            html=fts;
        end

    end
end
