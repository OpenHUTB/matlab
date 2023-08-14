classdef ReportOptions<handle






    properties


        MaxCols{mlreportgen.utils.validators.mustBePositiveNumber,mustBeNonempty}=32;


        DepthLimit{mlreportgen.utils.validators.mustBeZeroOrPositiveNumber,mustBeNonempty}=10;


        ObjectLimit{mlreportgen.utils.validators.mustBePositiveNumber,mustBeNonempty}=200;


        DisplayPolicy{mustBeMember(DisplayPolicy,{'Auto','Table','Paragraph','Inline Text'}),mustBeNonempty}="Auto";


        IncludeTitle{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;


        Title=[];


        ShowEmptyValues{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;


        ShowDefaultValues{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=true;


        ShowDataType{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=false;



        TableReporterTemplate{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.BaseTable',TableReporterTemplate)}=[];



        ParagraphReporterTemplate{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.dom.Paragraph',ParagraphReporterTemplate)}=[];



        InlineTextReporterTemplate{mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.dom.Text',InlineTextReporterTemplate)}=[];


        PropertyFilterFcn{mlreportgen.report.validators.mustBeInstanceOfMultiClass({'function_handle','char','string'},PropertyFilterFcn)}=[];


        NumericFormat{mlreportgen.report.validators.mustBeInstanceOfMultiClass({'numeric','char','string'},NumericFormat)}=[];
    end

    properties(Access=public,Hidden)


        Debug{mlreportgen.report.validators.mustBeLogical,mustBeNonempty}=false;
    end

    methods
        function this=ReportOptions(sourceObj)






            if(nargin==1)&&~isempty(sourceObj)
                this.MaxCols=sourceObj.MaxCols;
                this.DepthLimit=sourceObj.DepthLimit;
                this.ObjectLimit=sourceObj.ObjectLimit;
                this.IncludeTitle=sourceObj.IncludeTitle;
                this.Title=sourceObj.Title;
                this.ShowEmptyValues=sourceObj.ShowEmptyValues;
                this.ShowDefaultValues=sourceObj.ShowDefaultValues;
                this.ShowDataType=sourceObj.ShowDataType;
                this.PropertyFilterFcn=sourceObj.PropertyFilterFcn;
                this.NumericFormat=sourceObj.NumericFormat;

                if isa(sourceObj,"mlreportgen.report.internal.variable.ReportOptions")

                    this.DisplayPolicy=sourceObj.DisplayPolicy;
                    this.TableReporterTemplate=copy(sourceObj.TableReporterTemplate);
                    this.ParagraphReporterTemplate=clone(sourceObj.ParagraphReporterTemplate);
                    this.InlineTextReporterTemplate=clone(sourceObj.InlineTextReporterTemplate);
                    this.Debug=sourceObj.Debug;
                else



                    this.DisplayPolicy=sourceObj.FormatPolicy;
                    this.TableReporterTemplate=copy(sourceObj.TableReporter);
                    this.ParagraphReporterTemplate=clone(sourceObj.ParagraphFormatter);
                    this.InlineTextReporterTemplate=clone(sourceObj.TextFormatter);
                end
            else
                this.TableReporterTemplate=mlreportgen.report.BaseTable;
                this.ParagraphReporterTemplate=mlreportgen.dom.Paragraph;
                this.InlineTextReporterTemplate=mlreportgen.dom.Text;
            end
        end
    end

end

