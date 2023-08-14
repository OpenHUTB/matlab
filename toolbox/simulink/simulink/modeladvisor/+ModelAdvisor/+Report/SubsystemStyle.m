classdef SubsystemStyle<ModelAdvisor.Report.StyleFactory
    methods
        function obj=SubsystemStyle
            obj.Name=getString(message('ModelAdvisor:engine:Subsystem'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.Utils.sortObjs(elementsObj,'Subsystem',false);
            fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);
            html=fts;
        end

    end

end
