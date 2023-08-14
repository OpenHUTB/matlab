classdef ReportOrchestrator<handle








    properties
        ProgramSizeEstimate designcostestimation.internal.costestimate.OperatorCountEstimate
        DataSegmentEstimate designcostestimation.internal.costestimate.DataSegmentEstimate
        CurrentDesign char
        ReportName(1,:)char
    end

    properties(Hidden,SetAccess=private)
        CostReport slreportgen.report.Report
        Actions(1,:)cell
        Estimates(1,:)cell
    end

    methods

        function obj=ReportOrchestrator()
        end


        function addChapter(obj)
            import slreportgen.report.*
            import slreportgen.finder.*
            import mlreportgen.report.*
            import mlreportgen.dom.*

            chapter=Chapter('Title',obj.CurrentDesign);

            obj.collectActions();



            for idx=1:numel(obj.Actions)
                currentAction=obj.Actions{idx};
                costResult=obj.Estimates{idx};
                currentAction(costResult,chapter);
            end

            append(obj.CostReport,chapter);
        end


        function openReport(obj)
            rptview(obj.CostReport);
        end


        function closeReport(obj)
            close(obj.CostReport);
        end

    end

    methods(Hidden)


        function collectActions(obj)
            obj.Actions={};
            obj.Estimates={};
            if(~isempty(obj.ProgramSizeEstimate))

                obj.Actions{end+1}=@designcostestimation.internal.reportutil.constructOperatorCountSections;
                obj.Estimates{end+1}=obj.ProgramSizeEstimate;
            end
            if(~isempty(obj.DataSegmentEstimate))

                obj.Actions{end+1}=@designcostestimation.internal.reportutil.constructDataSegmentSections;
                obj.Estimates{end+1}=obj.DataSegmentEstimate;
            end
        end


        function createReport(obj,name,location,type)
            import slreportgen.report.*
            import slreportgen.finder.*
            import mlreportgen.report.*
            import mlreportgen.dom.*


            obj.ReportName=dashboard.internal.utils.getReportName(fullfile(location,name),type,"DesignCostEstimation");
            obj.CostReport=designcostestimation.internal.reportutil.CostReport(obj.ReportName,type);
            obj.CostReport.CompileModelBeforeReporting=false;
            add(obj.CostReport,TitlePage('Title',obj.ReportName));

            add(obj.CostReport,TableOfContents);
        end
    end
end


