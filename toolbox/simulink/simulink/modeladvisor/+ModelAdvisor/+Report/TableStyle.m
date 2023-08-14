classdef TableStyle<ModelAdvisor.Report.CheckStyleFactory




    methods
        function obj=TableStyle
            obj.Name=getString(message('ModelAdvisor:engine:RecommendedAction'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.TableStyle.sort(elementsObj,'RecommendedAction');




            if isempty(fts)
                html=[];
                return;
            end


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

            for i=1:length(elementsObj)

                ft=[];
                ifSameTemplate=false;


                if numel(fts)~=numel(sortCriteria)
                    error(message...
                    ('ModelAdvisor:engine:MAReportParseError'));
                end

                if~elementsObj(i).IsViolation
                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                    ft=ModelAdvisor.Report.Utils.processBasicData(elementsObj(i),ft,{'Description','Title','Information','Status','RecAction'});

                else
                    resData=elementsObj(i).CustomData;

                    if isempty(resData)
                        continue;
                    end






                    cObjCriteria=ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObj(i),'','addIntoCriteria');
                    index=strfind(sortCriteria,cObjCriteria);


                    if~all(cellfun('isempty',index))
                        ifSameTemplate=true;
                        ft=fts{index{:}};
                    end




                    if isempty(ft)
                        ft=ModelAdvisor.FormatTemplate('TableTemplate');
                        ft=ModelAdvisor.Report.Utils.processBasicData(elementsObj(i),ft,{'Description','Title','Information','Status','RecAction'});
                        sortCriteria{end+1}=ModelAdvisor.Report.Utils.sortAlgorithm(sortMethod,elementsObj(i),'','addIntoCriteria');%#ok<AGROW>
                        columnName=resData.metaData;
                        ft.setColTitles(columnName);
                    end




                    rowValue=resData.data;
                    tblRow=cell(1,size(rowValue,2));

                    for colCount=1:size(rowValue,2)
                        element=rowValue{colCount};
                        rowVal=cell(1,numel(element));


                        for subRowCount=1:numel(element)
                            subElement=element{subRowCount};
                            switch(subElement.Type)
                            case ModelAdvisor.ResultDetailType.SID
                                rowVal{subRowCount}=subElement.Data;
                            case ModelAdvisor.ResultDetailType.String
                                rowVal{subRowCount}=subElement.Data;


                            case ModelAdvisor.ResultDetailType.SimulinkVariableUsage
                                rowVal{subRowCount}=ModelAdvisor.Text(subElement.DetailedInfo.SlVarSource);
                                linkString=ModelAdvisor.Report.Utils.exploreListNodeLink(subElement);
                                rowVal{subRowCount}.setHyperlink(linkString);
                            otherwise



                                error(message...
                                ('ModelAdvisor:engine:MAUnknownRDType'));
                            end
                        end

                        tblRow{colCount}=rowVal;

                    end

                    if~isempty(tblRow)
                        ft.addRow(tblRow);
                    end



                end

                if ifSameTemplate
                    fts{index{:}}=ft;%#ok<AGROW>
                else
                    fts{end+1}=ft;
                end
            end
        end
    end
end

