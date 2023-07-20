classdef ConfigurationParameterStyle<ModelAdvisor.Report.CheckStyleFactory
    methods
        function obj=ConfigurationParameterStyle
            obj.Name=getString(message('ModelAdvisor:engine:RecommendedAction'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.ConfigurationParameterStyle.sort(elementsObj,'RecommendedAction');
            fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);
            html=fts;
        end
    end
    methods(Static)
        function fts=sort(elementsObj,sortMethod)
            fts={};
            sortCriteria={};
            sortedStatus={};
            sortCriteriaIndex={};
            for i=1:length(elementsObj)
                if isempty(elementsObj(i).Data)&&elementsObj(i).Type==ModelAdvisor.ResultDetailType.SID
                    ft=ModelAdvisor.Report.Utils.processInformationalData(elementsObj(i));
                    fts{end+1}=ft;%#ok<AGROW>
                    continue;
                end
                foundMatch=false;
                for j=1:length(sortCriteria)
                    if ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObj(i),sortCriteria{j},'compare')
                        ft=fts{sortCriteriaIndex{j}};
                        if elementsObj(i).IsViolation
                            sortedStatus{j}=false;%#ok<AGROW>
                            ft.setSubResultStatus('warn');
                        end
                        foundMatch=true;
                        break;
                    end
                end
                if~foundMatch
                    sortCriteria{end+1}=ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObj(i),'','addIntoCriteria');%#ok<AGROW>
                    sortedStatus{end+1}=elementsObj(i).IsViolation;%#ok<AGROW>
                    sortCriteriaIndex{end+1}=numel(fts)+1;%#ok<AGROW>
                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                    ft=ModelAdvisor.Report.Utils.processBasicData(elementsObj(i),ft,{'Description','Title','Information','Status','RecAction'});
                    ft.setColTitles({getString(message('Advisor:engine:Parameter')),getString(message('Advisor:engine:CurrentValue')),getString(message('Advisor:engine:RecValues'))});
                    fts{end+1}=ft;%#ok<AGROW>
                end
                if elementsObj(i).Type==ModelAdvisor.ResultDetailType.ConfigurationParameter
                    link=Advisor.Utils.getHyperlinkToConfigSetParameter(elementsObj(i).DetailedInfo.ModelName,elementsObj(i).DetailedInfo.Parameter);
                    if isfield(elementsObj(i).CustomData,'CurrentValue')
                        CurrentValue=elementsObj(i).CustomData.CurrentValue;
                    else
                        CurrentValue='';
                    end
                    if isfield(elementsObj(i).CustomData,'RecommendedValue')
                        RecommendedValue=elementsObj(i).CustomData.RecommendedValue;
                    else
                        RecommendedValue='';
                    end
                    ft.addRow({link,CurrentValue,RecommendedValue});
                end
            end
        end
    end
end
