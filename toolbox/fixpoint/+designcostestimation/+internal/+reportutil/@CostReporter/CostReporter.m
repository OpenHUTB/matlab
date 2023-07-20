classdef CostReporter<slreportgen.report.Reporter





    properties
Diagram
CostResult
    end

    methods

        function obj=CostReporter(varargin)
            obj=obj@slreportgen.report.Reporter(varargin{:});
            obj.TemplateName='CostReporter';
        end





        function contentToBeAdded=getContent(obj,~)
            contentToBeAdded={};
            import slreportgen.finder.*
            import mlreportgen.report.*
            import mlreportgen.dom.*
            if(isempty(obj.Diagram)||isempty(obj.CostResult))
                return;
            end
            finder=BlockFinder(obj.Diagram);

            BlockName=[];
            SelfCost=[];
            TotalCost=[];
            SystemName=[];
            SystemTotalCost=[];

            while hasNext(finder)
                finderResult=next(finder);
                currBlockPath=finderResult.BlockPath;
                if(obj.isZeroCostBlock(currBlockPath,obj.CostResult))
                    continue;
                end
                if(slreportgen.utils.isValidSlSystem(currBlockPath))
                    SystemName=[SystemName;finderResult.Name];%#ok<*AGROW>
                    SystemTotalCost=[SystemTotalCost;obj.CostResult.componentTotalCost(currBlockPath)];
                    continue;
                end
                BlockName=[BlockName;finderResult.Name];
                SelfCost=[SelfCost;obj.CostResult.componentSelfCost(currBlockPath)];
                TotalCost=[TotalCost;obj.CostResult.componentTotalCost(currBlockPath)];
            end

            costTable=table(BlockName,SelfCost,TotalCost);
            if(~isempty(costTable))
                costTable=sortrows(costTable,[3,2],'descend');
                tbl1=MATLABTable(costTable);
                tbl1.Border="solid";
                tbl1.ColSep="solid";
                tbl1.RowSep="solid";
                tbl1.HeaderRule=[];
                Blockrptr=BaseTable(tbl1);
                Blockrptr.Title="Block Cost Table - "+get_param(obj.Diagram,'Name');
                contentToBeAdded=[contentToBeAdded;Blockrptr];
            end

            costTable=table(SystemName,SystemTotalCost);
            if(~isempty(costTable))
                costTable=sortrows(costTable,[2],'descend');
                tbl1=MATLABTable(costTable);
                tbl1.Border="solid";
                tbl1.ColSep="solid";
                tbl1.RowSep="solid";
                tbl1.HeaderRule=[];
                Systemrptr=BaseTable(tbl1);
                Systemrptr.Title="System Cost Table - "+get_param(obj.Diagram,'Name');
                contentToBeAdded=[contentToBeAdded;Systemrptr];
            end
        end

    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=designcostestimation.internal.reportutil.CostReporter.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end


        function isZeroCost=isZeroCostBlock(~,BlockPath,CostResult)
            isZeroCost=(CostResult.componentTotalCost(BlockPath))==0;
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
            path=designcostestimation.internal.reportutil.CostReporter.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"designcostestimation.internal.reportutil.CostReporter");
        end
    end
end


