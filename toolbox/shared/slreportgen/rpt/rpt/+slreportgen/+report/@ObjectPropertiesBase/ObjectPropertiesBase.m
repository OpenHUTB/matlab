classdef(Abstract,Hidden)ObjectPropertiesBase<slreportgen.report.Reporter





    properties












        PropertyTable;






        ShowEmptyValues{mlreportgen.report.validators.mustBeLogical}=false;





        Properties={};

    end

    properties(Hidden)
        TableContent={};
    end

    properties(Abstract,Access=protected)


HierNumberedTitleTemplateName
NumberedTitleTemplateName


ParaStyleName
    end

    methods

        function objectPropertiesBase=ObjectPropertiesBase(varargin)
            objectPropertiesBase=...
            objectPropertiesBase@slreportgen.report.Reporter(varargin{:});
        end

        function set.PropertyTable(this,value)


            mustBeNonempty(value);

            mustBeA(value,"mlreportgen.report.BaseTable");

            this.PropertyTable=value;
        end

        function impl=getImpl(objectPropertiesBase,rpt)

            objectPropertiesBase.TableContent=getTableContent(objectPropertiesBase,rpt);

            if(~isempty(objectPropertiesBase.TableContent))
                impl=getImpl@slreportgen.report.Reporter(objectPropertiesBase,rpt);
            else
                impl=[];
            end

        end
    end


    methods(Access={?mlreportgen.report.ReportForm,?slreporten.report.ObjectPropertiesBase})

        function content=getContent(objectPropertiesBase,rpt)



            table=mlreportgen.dom.FormalTable();
            tr=mlreportgen.dom.TableRow();
            append(tr,mlreportgen.dom.TableHeaderEntry('Property'));
            append(tr,mlreportgen.dom.TableHeaderEntry('Value'));
            append(table.Header,tr);



            s=size(objectPropertiesBase.TableContent);
            for row=1:s(1)
                tableRow=mlreportgen.dom.TableRow();
                tableEntry=mlreportgen.dom.TableEntry();
                append(tableEntry,objectPropertiesBase.TableContent{row,1});
                append(tableRow,tableEntry);
                values=objectPropertiesBase.TableContent{row,2};
                tableEntry=mlreportgen.dom.TableEntry();

                for value=values
                    if isa(value,'mlreportgen.dom.FormalTable')



                        tableEntry.InnerMargin='0.2pt';
                    end
                    append(tableEntry,value);
                end
                append(tableRow,tableEntry);
                append(table.Body,tableRow);
            end


            content=objectPropertiesBase.PropertyTable;

            if isempty(content.Title)||...
                isa(content.Title,"mlreportgen.report.TitleReporter")&&isempty(content.Title.Content)
                titleContent=getTableTitleString(objectPropertiesBase);
                appendTitle(content,titleContent);
            end

            shouldNumberTableHierarchically=isChapterNumberHierarchical(objectPropertiesBase,rpt);
            if mlreportgen.report.Reporter.isInlineContent(content.Title)
                titleReporter=getTitleReporter(content);
                titleReporter.TemplateSrc=objectPropertiesBase;

                if shouldNumberTableHierarchically
                    titleReporter.TemplateName=objectPropertiesBase.HierNumberedTitleTemplateName;
                else
                    titleReporter.TemplateName=objectPropertiesBase.NumberedTitleTemplateName;
                end
                content.Title=titleReporter;
            end

            objectPropertiesBase.PropertyTable.Content=table;

        end


    end

    methods(Access=protected)

        function isEmptyValue=isEmptyPropValue(objectPropertiesBase,propValue)%#ok<INUSL>
            propStringValue=[];






            if ischar(propValue)||isstring(propValue)
                propValue=string(propValue);
                propStringValue=propValue;
            else
                if iscell(propValue)&&(ischar(propValue{1})||isstring(propValue{1}))
                    propValue{1}=string(propValue{1});
                    propStringValue=propValue{1};
                end
            end

            if~isempty(propStringValue)

                if(propStringValue==""||all(strcmp(propStringValue,"[]"))||all(strcmp(propStringValue,"N/A")))
                    isEmptyValue=true;
                else
                    isEmptyValue=false;
                end

            else



                isEmptyValue=isempty(propValue)||...
                iscell(propValue)&&...
                (isempty(propValue{1})||...
                (isstruct(propValue{1})&&isempty(fieldnames(propValue{1}))));
            end
        end
    end


    methods(Abstract,Access=protected)

        tableContent=getTableContent(objectPropertiesBase)

        titleContent=getTableTitleString(objectPropertiesBase);
    end

end