classdef(Abstract,Hidden)VariableBase<handle




    properties




















































        FormatPolicy{mlreportgen.report.validators.mustBeString,...
        mustBeMember(FormatPolicy,{'Auto','Table','Paragraph','Inline Text'}),mustBeNonempty}="Auto";













        TableReporter{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.BaseTable',TableReporter)}=[];









        ParagraphFormatter{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.dom.Paragraph',ParagraphFormatter)}=[];









        TextFormatter{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.dom.Text',TextFormatter)}=[];








        MaxCols{mlreportgen.utils.validators.mustBePositiveNumber,mustBeNonempty}=32;








        DepthLimit{mlreportgen.utils.validators.mustBeZeroOrPositiveNumber,mustBeNonempty}=10;




        ObjectLimit{mlreportgen.utils.validators.mustBePositiveNumber,mustBeNonempty}=200;









        IncludeTitle{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;





















        Title{mlreportgen.report.validators.mustBeInline}=[];








        ShowDataType{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=false;









        ShowEmptyValues{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;









        ShowDefaultValues{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;





























        PropertyFilterFcn{mlreportgen.report.validators.mustBeInstanceOfMultiClass({'function_handle','char','string'},PropertyFilterFcn)}











        NumericFormat{mlreportgen.report.validators.mustBeInstanceOfMultiClass({'numeric','char','string'},NumericFormat)}=[];
    end

    properties(Access=public,Hidden)

        Content=[];
    end

    properties(Abstract,Hidden)
HierNumberedTitleTemplateName
NumberedTitleTemplateName
FormalTableTemplateName
    end

    methods(Abstract,Access=protected,Hidden)
        varName=getVarName(this)
        value=getVarValue(this)
    end

    methods(Access=protected,Hidden,Abstract)
        chapterNumbered=isChapterNumberHierarchical(this,rpt)
    end

    methods
        function set.FormatPolicy(this,value)
            if ischar(value)
                this.FormatPolicy=string(value);
            else
                this.FormatPolicy=value;
            end
        end

        function set.TableReporter(this,value)


            mustBeNonempty(value);



            this.TableReporter=value;
        end

        function set.ParagraphFormatter(this,value)


            mustBeNonempty(value);



            this.ParagraphFormatter=value;
        end

        function set.TextFormatter(this,value)


            mustBeNonempty(value);



            this.TextFormatter=value;
        end

        function set.PropertyFilterFcn(this,value)


            this.PropertyFilterFcn=value;
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreportgen.report.MATLABVariable,?slreportgen.report.ModelVariable})
        function content=getContent(this,rpt)

            n=numel(this.Content);
            content=cell(1,n);
            for i=1:n
                if isa(this.Content{i},"mlreportgen.report.BaseTable")

                    iContent=copy(this.Content{i});



                    if mlreportgen.report.Reporter.isInlineContent(iContent.Title)
                        titleReporter=getTitleReporter(iContent);
                        titleReporter.TemplateSrc=this;

                        if isChapterNumberHierarchical(this,rpt)
                            titleReporter.TemplateName=this.HierNumberedTitleTemplateName;
                        else
                            titleReporter.TemplateName=this.NumberedTitleTemplateName;
                        end
                        iContent.Title=titleReporter;
                    end






                    if strcmp(rpt.Type,"docx")&&...
                        isa(iContent.Content,"mlreportgen.dom.FormalTable")
                        iContent.TableStyleName=this.FormalTableTemplateName;
                    end
                    content{i}=iContent;
                else
                    content{i}=this.Content{i};
                end
            end
        end
    end

    methods(Access=protected)

        function[variableName,variableValue]=reportVariable(this,rpt)



            import mlreportgen.report.internal.variable.*;


            variableValue=getVarValue(this);
            variableName=getVarName(this);




            reportOptions=ReportOptions(this);




            reportOptions.Debug=rpt.Debug;


            reporterQueue=ReporterQueue.instance();



            reporterQueue.init(reportOptions,variableName,variableValue);




            this.Content=reporterQueue.run();
        end

    end

end

