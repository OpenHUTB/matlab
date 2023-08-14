classdef GroupStyle<ModelAdvisor.Report.CheckStyleFactory
    methods
        function obj=GroupStyle
            obj.Name=getString(message('ModelAdvisor:engine:RecommendedAction'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.GroupStyle.sort(elementsObj,'RecommendedAction');
            if length(fts)==1
                fts{1}.setSubBar(0);
            end

            fts{end}.setSubBar(0);
            html=fts;
        end

    end

    methods(Static)

        function fts=sort(elementsObjs,sortMethod)
            fts={};
            sortCriteria={};
            sortedObjs={};
            sortedStatus={};

            for n=1:length(elementsObjs)
                foundMatch=false;
                for j=1:length(sortCriteria)
                    if ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObjs(n),sortCriteria{j},'compare')
                        sortedObjs{j}{end+1}=elementsObjs(n);%#ok<AGROW>
                        if elementsObjs(n).IsViolation
                            sortedStatus{j}=true;%#ok<AGROW>
                        end
                        foundMatch=true;
                        break;
                    end
                end
                if~foundMatch
                    sortedObjs{end+1}={elementsObjs(n)};%#ok<AGROW>
                    sortCriteria{end+1}=ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObjs(n),'','addIntoCriteria');%#ok<AGROW>
                    sortedStatus{end+1}=elementsObjs(n).IsViolation;%#ok<AGROW>
                end
            end

            for k=1:numel(sortedObjs)
                elementsObjs=sortedObjs{k};
                ft=ModelAdvisor.FormatTemplate('TableTemplate');
                ft.setColTitles({DAStudio.message('ModelAdvisor:engine:ResultFormatGroupCol1'),DAStudio.message('ModelAdvisor:engine:ResultFormatGroupCol2')});
                TableInfo={};

                for j=1:numel(elementsObjs)
                    if~isempty(elementsObjs{j}.Data)
                        TableInfo{j,1}=ModelAdvisor.Text(['Group',num2str(j)]);%#ok<AGROW>



                        data=strsplit(elementsObjs{j}.Data,'|');
                        TableInfo{j,2}=data;%#ok<AGROW>
                        linkString=['matlab: modeladvisorprivate hiliteGroup ',elementsObjs{j}.Data];
                        TableInfo{j,1}.setHyperlink(linkString);

                    end
                end
                ft.SubResultStatusText=elementsObjs{j}.Status;

                if~isempty(TableInfo)
                    ft.SubTitle=elementsObjs{j}.Title;
                    ft.RecAction=elementsObjs{j}.RecAction;
                    ft.SubResultStatus='warn';
                    ft.setTableInfo(TableInfo);
                else
                    ft.SubTitle=elementsObjs{j}.Description;
                    ft.SubResultStatus='pass';
                end
                fts{end+1}=ft;
            end
        end
    end
end
