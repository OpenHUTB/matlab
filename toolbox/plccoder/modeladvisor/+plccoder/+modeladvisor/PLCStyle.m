classdef PLCStyle < ModelAdvisor.Report.CheckStyleFactory
    methods
        function obj = PLCStyle
            obj.Name = 'PLCStyle';
        end
        
        function html = generateReport(~, CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj = CheckObj.Check;
            end
            elementResults = CheckObj.ResultDetails;
            fts = plccoder.modeladvisor.PLCStyle.getFormatTemplates(elementResults);
            %fts.setSubBar(0);
            
            html = fts;
        end
    end

    methods(Static)
        
        function ft = getFormatTemplates(elementResults)
            ft = ModelAdvisor.FormatTemplate('ListTemplate');
            listObj = cell(1, numel(elementResults));
            subResultStatus = 'Pass';
            for i = 1:numel(elementResults)
                if ~isempty(elementResults(i).Data)
                    subResultStatus = 'Warn';
                    ft.SubResultStatusText = elementResults(i).Status; % fix this
                    ft.RecAction = elementResults(i).RecAction; % fix this
                    listObj{i} = elementResults(i).Data;
                end
            end
            ft.setSubResultStatus(subResultStatus);
            if strcmp(subResultStatus, 'Warn')
                ft.setListObj(listObj);
            end
            ft.setCheckText(elementResults(1).Description); %fix this
        end
    end
end