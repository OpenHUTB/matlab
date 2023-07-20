classdef(Sealed)LUTCompressionResult<handle&matlab.mixin.Heterogeneous




    properties(Constant,Hidden)
        NewMemoryUsageColumnName="NewMemoryUsage";
        DescriptionNewMemoryUsage=message('SimulinkFixedPoint:functionApproximation:descriptionNewMemoryUsage').getString();
        DescriptionMemoryDifferencePercentage=message('SimulinkFixedPoint:functionApproximation:descriptionMemoryDifferencePercentage').getString();
        DescriptionMemoryDifference=message('SimulinkFixedPoint:functionApproximation:descriptionMemoryDifference').getString();
    end

    properties(Access=private,Hidden)
        DataTable table
        Solutions cell
    end

    properties

        MemoryUnits FunctionApproximation.internal.MemoryUnit="bits"
    end

    properties(Dependent)

MemoryUsageTable


NumLUTsFound


NumImprovements


TotalMemoryUsed


TotalMemoryUsedNew


TotalMemorySavings


TotalMemorySavingsPercent
    end

    properties(SetAccess=private)

        SUD char


        WordLengths{mustBeNumeric}


        FindOptions Simulink.internal.FindOptions


        Display logical
    end

    properties(SetAccess=private,Hidden)
SolverOptions
    end

    methods
        function this=LUTCompressionResult()
            this.DataTable=table.empty();
            this.Solutions={};
        end

        function memoryTable=get.MemoryUsageTable(this)
            memoryTable=this.DataTable;
            solutionsCell=this.Solutions;
            if~isempty(memoryTable)

                memoryColumnName=FunctionApproximation.internal.memoryusagetablebuilder.MemoryUsageTableBuilder.MetaData.MemoryColumnName;
                memoryUnits=memoryTable.Properties.VariableUnits{2};
                memoryTable.(this.NewMemoryUsageColumnName)=memoryTable.(memoryColumnName);
                for iSolution=1:numel(solutionsCell)
                    if~isempty(solutionsCell{iSolution})
                        memoryTable{iSolution,this.NewMemoryUsageColumnName}=solutionsCell{iSolution}.totalMemoryUsage(memoryUnits);
                    end
                end


                memoryTable.DifferencePercentage=100*(memoryTable.(memoryColumnName)-memoryTable.(this.NewMemoryUsageColumnName))./memoryTable.(memoryColumnName);


                originalValues=memoryTable.(memoryColumnName);
                originalMemoryUnits=memoryTable.Properties.VariableUnits{2};
                memoryValue=FunctionApproximation.internal.MemoryValue(originalValues,'Unit',originalMemoryUnits);
                memoryValue.Unit=this.MemoryUnits;
                memoryTable{:,memoryColumnName}=reshape(memoryValue.Value,size(originalValues));

                originalValues=memoryTable.(this.NewMemoryUsageColumnName);
                memoryValue=FunctionApproximation.internal.MemoryValue(originalValues,'Unit',originalMemoryUnits);
                memoryValue.Unit=this.MemoryUnits;
                memoryTable{:,this.NewMemoryUsageColumnName}=reshape(memoryValue.Value,size(originalValues));


                memoryTable.Difference=memoryTable.(memoryColumnName)-memoryTable.(this.NewMemoryUsageColumnName);


                memoryTable.Properties.VariableUnits{2}=char(this.MemoryUnits);
                memoryTable.Properties.VariableUnits{3}=char(this.MemoryUnits);
                memoryTable.Properties.VariableUnits{4}='%';
                memoryTable.Properties.VariableUnits{5}=char(this.MemoryUnits);


                memoryTable.Properties.VariableDescriptions{3}=this.DescriptionNewMemoryUsage;
                memoryTable.Properties.VariableDescriptions{4}=this.DescriptionMemoryDifferencePercentage;
                memoryTable.Properties.VariableDescriptions{5}=this.DescriptionMemoryDifference;
            end
        end

        function v=get.TotalMemorySavings(this)
            v=sum(this.MemoryUsageTable.Difference);
        end

        function v=get.TotalMemoryUsed(this)
            memoryColumnName=FunctionApproximation.internal.memoryusagetablebuilder.MemoryUsageTableBuilder.MetaData.MemoryColumnName;
            v=sum(this.MemoryUsageTable.(memoryColumnName));
        end

        function v=get.TotalMemoryUsedNew(this)
            v=sum(this.MemoryUsageTable.NewMemoryUsage);
        end

        function v=get.TotalMemorySavingsPercent(this)
            v=100*this.TotalMemorySavings/this.TotalMemoryUsed;
        end

        function v=get.NumLUTsFound(this)
            v=size(this.MemoryUsageTable,1);
        end

        function v=get.NumImprovements(this)
            v=this.numImprovements();
        end

        function replace(this,rowID)
            n=numel(this.Solutions);
            if nargin<2

                rows=1:n;
            else
                this.validateIndex(rowID,n);
                rows=rowID;
            end

            for iRow=rows
                solution=this.Solutions{iRow};
                if this.canReplace(solution)

                    solution.replaceWithApproximate();
                end
            end
        end

        function revert(this,rowID)
            n=numel(this.Solutions);
            if nargin<2

                rows=1:n;
            else
                this.validateIndex(rowID,n);
                rows=rowID;
            end

            for iRow=rows
                solution=this.Solutions{iRow};
                if this.canReplace(solution)


                    solution.revertToOriginal();
                end
            end
        end
    end

    methods(Hidden)
        function setDataTable(this,dataTable)
            this.DataTable=dataTable;
            if~isempty(dataTable)
                this.MemoryUnits=FunctionApproximation.internal.MemoryUnit(dataTable.Properties.VariableUnits{2});
            end
        end

        function setSolutions(this,solutionsCell)
            this.Solutions=solutionsCell;
        end

        function setSUD(this,sud)
            this.SUD=sud;
        end

        function setDisplay(this,toDisplay)
            this.Display=toDisplay;
        end

        function setFindOptions(this,findOptions)
            this.FindOptions=findOptions;
        end

        function setWordLengths(this,wordLengths)
            this.WordLengths=wordLengths;
        end

        function setSolverOptions(this,options)
            this.SolverOptions=options;
        end

        function struct(this)

            error(message('SimulinkFixedPoint:functionApproximation:cannotConvertToStruct',class(this)));
        end

        function n=numImprovements(this)
            n=0;
            if~isempty(this.DataTable)
                n=sum(this.MemoryUsageTable.Difference>0);
            end
        end

        function solutions=getSolutions(this)
            solutions=this.Solutions;
        end

        function dataTable=getDataTable(this)
            dataTable=this.DataTable;
        end

        function flag=canReplace(~,solution)
            flag=~isempty(solution)&&(solution.PercentReduction>0);
        end
    end

    methods(Hidden,Static)
        function validateIndex(rowID,n)
            try
                mustBeLessThanOrEqual(rowID,n);
                mustBeGreaterThanOrEqual(rowID,1);
                mustBeInteger(rowID);
            catch err %#ok<NASGU>
                exception=MException(message('SimulinkFixedPoint:functionApproximation:rowIDNotInBounds',n));
                FunctionApproximation.internal.DisplayUtils.throwError(exception);
            end
        end
    end
end