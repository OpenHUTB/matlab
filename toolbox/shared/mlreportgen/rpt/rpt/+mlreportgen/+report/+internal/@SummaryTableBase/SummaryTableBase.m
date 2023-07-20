classdef(Abstract,Hidden)SummaryTableBase<handle





    methods(Access=protected,Hidden,Abstract)
        chapterNumbered=isChapterNumberHierarchical(this,rpt)
    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreportgen.report.SummaryTable,?slreportgen.report.SummaryTable})

        function content=getTableContent(this,rpt)




            [titles,props,tableContent]=getSummaryTablesData(this,rpt);


            nTables=numel(props);
            content=cell(1,nTables);
            for idx=1:nTables
                if props{idx}~=""
                    ft=mlreportgen.dom.FormalTable(props{idx},tableContent{idx});
                    tblRptr=copy(this.TableReporter);
                    content{idx}=tblRptr;
                    tblRptr.Content=ft;



                    titleReporter=getTitleReporter(tblRptr);
                    titleReporter.TemplateSrc=this;
                    if isChapterNumberHierarchical(this,rpt)
                        titleReporter.TemplateName="SummaryTableHierNumberedTitle";
                    else
                        titleReporter.TemplateName="SummaryTableNumberedTitle";
                    end
                    tblRptr.Title=titleReporter;


                    if~isempty(this.Title)
                        tblRptr.appendTitle(this.Title);
                    else
                        tblRptr.appendTitle(titles(idx));
                    end
                end
            end

        end
    end

    methods(Access=protected)

        function[props,content]=getSingleSummaryTableData(this,rpt,results,props,linkProperty,compileEachMdl,srcMdls)







            linkPropIdx=find(strcmp(props,linkProperty),1);


            nProps=numel(props);
            nResults=numel(results);
            content=cell(nResults,nProps);
            for idx=1:nResults
                result=results(idx);

                if compileEachMdl
                    compileModel(rpt,srcMdls(idx));
                end


                valRow=getPropertyValues(result,props,...
                "ReturnType","DOM");


                if this.IncludeLinks&&~isempty(linkPropIdx)
                    name=string(valRow{linkPropIdx});
                    if name==""
                        name="Link to object";
                    end
                    id=getReporterLinkTargetID(result);
                    link=mlreportgen.dom.InternalLink(id,name);
                    valRow{linkPropIdx}=link;
                end

                content(idx,:)=valRow;
            end

            if~this.ShowEmptyColumns&&~isempty(content)

                empty=cellfun(@(x)isempty(x)||all(isspace(x)),content);
                emptyCols=all(empty,1);
                content(:,emptyCols)=[];
                props(emptyCols)=[];
            end

        end
    end
end