classdef DataSegmentReporter<slreportgen.report.Reporter




    properties
CostResult
    end

    methods

        function obj=DataSegmentReporter(varargin)
            obj=obj@slreportgen.report.Reporter(varargin{:});
            obj.TemplateName='DataSegmentReporter';
        end


        function contentToBeAdded=getContent(obj,~)
            contentToBeAdded={};


            if(isempty(obj.CostResult)||(obj.CostResult.TotalMemoryConsumption==0))
                return;
            end

            import mlreportgen.report.*
            import mlreportgen.dom.*

            tbl1=MATLABTable(obj.CostResult.CostTable);
            tbl1.Border="solid";
            tbl1.ColSep="solid";
            tbl1.RowSep="solid";
            tbl1.HeaderRule=[];
            dataSegmentRptr=BaseTable(tbl1);
            dataSegmentRptr.Title="Data Segment Variables";
            contentToBeAdded=dataSegmentRptr;

        end
    end



    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=designcostestimation.internal.reportutil.DataSegmentReporter.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Access=protected,Hidden)
        result=openImpl(reporter,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function createTemplate(templatePath,type)
            path=designcostestimation.internal.reportutil.DataSegmentReporter.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"designcostestimation.internal.reportutil.DataSegmentReporter");
        end

    end
end


