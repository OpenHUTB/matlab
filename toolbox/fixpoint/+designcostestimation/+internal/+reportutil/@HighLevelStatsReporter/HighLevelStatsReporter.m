classdef HighLevelStatsReporter<slreportgen.report.Reporter




    properties
CostResult
    end

    properties(Access=private)
ExpensiveBlocks
ExpensiveSystems
    end

    methods

        function obj=HighLevelStatsReporter(varargin)
            obj=obj@slreportgen.report.Reporter(varargin{:});
            obj.TemplateName='HighLevelStatsReporter';
        end


        function contentToBeAdded=getContent(obj,~)
            contentToBeAdded={};


            if(isempty(obj.CostResult)||(obj.CostResult.TotalCost==0))
                return;
            end
            import slreportgen.finder.*
            import mlreportgen.report.*
            import mlreportgen.dom.*
            finder=BlockFinder(obj.CostResult.Design);
            while(hasNext(finder))
                currBlock=next(finder);
                if(slreportgen.utils.isValidSlSystem(currBlock.BlockPath))
                    obj.processSystem(currBlock.BlockPath);
                else
                    obj.processBlock(currBlock.BlockPath);
                end
            end
            if(~isempty(obj.ExpensiveBlocks))
                obj.ExpensiveBlocks=designcostestimation.internal.reportutil.HighLevelStatsReporter.sortAndFilter(obj.ExpensiveBlocks);
            end
            if(~isempty(obj.ExpensiveSystems))
                obj.ExpensiveSystems=designcostestimation.internal.reportutil.HighLevelStatsReporter.sortAndFilter(obj.ExpensiveSystems);
            end
            if(~isempty(obj.ExpensiveBlocks))
                tbl1=MATLABTable(obj.ExpensiveBlocks);
                tbl1.Border="solid";
                tbl1.ColSep="solid";
                tbl1.RowSep="solid";
                tbl1.HeaderRule=[];
                Blockrptr=BaseTable(tbl1);
                Blockrptr.Title="Most Expensive Blocks";
                contentToBeAdded=[contentToBeAdded;Blockrptr];
            end
            if(~isempty(obj.ExpensiveSystems))
                tbl1=MATLABTable(obj.ExpensiveSystems);
                tbl1.Border="solid";
                tbl1.ColSep="solid";
                tbl1.RowSep="solid";
                tbl1.HeaderRule=[];
                Blockrptr=BaseTable(tbl1);
                Blockrptr.Title="Most Expensive Systems";
                contentToBeAdded=[contentToBeAdded;Blockrptr];
            end
        end
    end

    methods(Access=private)

        function processBlock(obj,BlockPath)
            obj.ExpensiveBlocks=[obj.ExpensiveBlocks;[BlockPath,obj.CostResult.componentTotalCost(BlockPath)]];
        end


        function processSystem(obj,SystemPath)
            obj.ExpensiveSystems=[obj.ExpensiveSystems;[SystemPath,obj.CostResult.componentTotalCost(SystemPath)]];
        end
    end



    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=designcostestimation.internal.reportutil.HighLevelStatsReporter.getClassFolder();
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
            path=HighLevelStatsReporter.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"HighLevelStatsReporter");
        end



        function returnTable=sortAndFilter(CostTable)
            CostTable=table(CostTable(:,1),str2double(CostTable(:,2)));
            CostTable.Properties.VariableNames={'Name','Cost'};
            CostTable=sortrows(CostTable,[2],'descend');%#ok<NBRAK>
            if(size(CostTable,1)>5)
                CostTable=CostTable(1:5,:);
            end
            returnTable=CostTable(CostTable.Cost>0,:);
        end
    end
end


