

classdef DefaultStyle<ModelAdvisor.Report.CheckStyleFactory
    methods
        function obj=DefaultStyle
            obj.Name=getString(message('ModelAdvisor:engine:Default'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            html=CheckObj.CacheResultInHTMLForNewCheckStyle;
        end

    end
end
