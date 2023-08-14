classdef ExpressionStyle<ModelAdvisor.Report.CheckStyleFactory
    methods
        function obj=ExpressionStyle
            obj.Name=getString(message('ModelAdvisor:engine:RecommendedAction'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.ExpressionStyle.sort(elementsObj,'RecommendedAction');
            if length(fts)==1
                fts{1}.setSubBar(0);
            end

            fts{end}.setSubBar(0);
            html=fts;
        end
    end
    methods(Static)
        function fts=sort(elementsObj,sortMethod)
            fts={};
            sortCriteria={};
            sortedStatus={};
            sortCriteriaIndex={};



            bHasCustomData=any(arrayfun(@(x)~isempty(x.CustomData),elementsObj));

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
                    if bHasCustomData
                        ft.setColTitles({getString(message('ModelAdvisor:engine:BlockPath')),getString(message('Advisor:engine:Expression')),getString(message('Advisor:engine:Description'))});
                    else
                        ft.setColTitles({getString(message('ModelAdvisor:engine:BlockPath')),getString(message('Advisor:engine:Expression'))});
                    end
                    fts{end+1}=ft;%#ok<AGROW>
                end
                tblRow=[];
                switch(elementsObj(i).Type)
                case ModelAdvisor.ResultDetailType.SID
                    if~isempty(elementsObj(i).DetailedInfo)
                        if~isempty(elementsObj(i).DetailedInfo.TextHighlightStart)&&~isempty(elementsObj(i).DetailedInfo.TextHighlightEnd)

                            tblRow={elementsObj(i).Data,...
                            Advisor.Utils.Simulink.getEmlHyperlink(elementsObj(i).Data,...
                            elementsObj(i).DetailedInfo.Expression,...
                            elementsObj(i).DetailedInfo.TextHighlightStart,...
                            elementsObj(i).DetailedInfo.TextHighlightEnd)};

                        else

                            tblRow={elementsObj(i).Data,elementsObj(i).DetailedInfo.Expression};
                        end
                    end
                case ModelAdvisor.ResultDetailType.Mfile
                    [~,file,ext]=fileparts(elementsObj(i).DetailedInfo.FileName);

                    slCB=ModelAdvisor.getSimulinkCallback('hilite_file',elementsObj(i).DetailedInfo.FileName);

                    formattedTextObj=ModelAdvisor.Text([file,ext]);
                    formattedTextObj.setHyperlink(slCB);

                    if~isempty(elementsObj(i).DetailedInfo.TextHighlightStart)&&~isempty(elementsObj(i).DetailedInfo.TextHighlightEnd)

                        tblRow={formattedTextObj,...
                        Advisor.Utils.Simulink.getEmlHyperlink(elementsObj(i).DetailedInfo.FileName,elementsObj(i).DetailedInfo.Expression,elementsObj(i).DetailedInfo.TextHighlightStart,elementsObj(i).DetailedInfo.TextHighlightEnd)};
                    else

                        tblRow={formattedTextObj,elementsObj(i).DetailedInfo.Expression};
                    end
                case ModelAdvisor.ResultDetailType.Stateflow
                    if~isempty(elementsObj(i).DetailedInfo)

                        h_start=str2num(elementsObj(i).DetailedInfo.TextHighlightStart);
                        h_end=str2num(elementsObj(i).DetailedInfo.TextHighlightEnd);
                        expression=elementsObj(i).DetailedInfo.Expression;


                        if h_start>h_end||length(expression)<h_end




                            tblRow={elementsObj(i).Data,...
                            Advisor.Utils.Simulink.getEmlHyperlink(elementsObj(i).Data,...
                            expression,...
                            h_start,...
                            h_end)};
                        else

                            tblRow={elementsObj(i).Data,...
                            Advisor.Utils.Stateflow.highlightSFLabelByIndex(...
                            expression,...
                            [h_start...
                            ,h_end])};
                        end
                    end
                end

                if~isempty(tblRow)
                    if bHasCustomData
                        tblRow{end+1}=elementsObj(i).CustomData;%#ok<AGROW>
                    end

                    ft.addRow(tblRow);
                end
            end
        end
    end
end
