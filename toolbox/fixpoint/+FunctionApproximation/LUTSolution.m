classdef(Sealed)LUTSolution<FunctionApproximation.internal.ApproximateSolution







































































    properties(Access=private)
        Solution FunctionApproximation.internal.ApproximateLUTSolution
    end

    properties(Transient,SetAccess=private)
TableData
PercentReduction
FeasibleSolutions
AllSolutions
    end

    methods(Access={?FunctionApproximation.internal.LUTDBUnitToApproximateLUTSolutionAdapter})
        function this=LUTSolution(solution)
            this.Solution=solution;
            this.ErrorFunction=solution.ErrorFunction;
            this.DataBase=solution.DataBase;
            this.Options=solution.Options;
            this.DBUnit=solution.DBUnit;
            this.SourceProblem=solution.SourceProblem;
            this.ID=solution.ID;
            this.Feasible=solution.Feasible;
        end
    end

    methods
        function tableData=get.TableData(this)
            tableData=tabledata(this);
        end

        function reduction=get.PercentReduction(this)
            reduction=percentreduction(this);
        end

        function sols=get.FeasibleSolutions(this)
            sols=feasiblesolutions(this);
        end

        function sols=get.AllSolutions(this)
            sols=allsolutions(this);
        end
    end

    methods(Hidden)
        function sols=allsolutions(this)
            sols=allsolutions(this.Solution);
        end

        function tableData=tabledata(this)
            tableData=tabledata(this.Solution);
        end

        function sols=feasiblesolutions(this)
            sols=feasiblesolutions(this.Solution);
        end

        function reduction=percentreduction(this)
            reduction=percentreduction(this.Solution);
        end

        function struct(this)
            error(message('SimulinkFixedPoint:functionApproximation:cannotConvertToStruct',class(this)));
        end

        function displayallsolutions(this)
            displayallsolutions(this.Solution);
        end

        function displayfeasiblesolutions(this)
            displayfeasiblesolutions(this.Solution);
        end

        function sol=solutionfromID(this,id)
            sol=solutionfromID(this.Solution,id);
        end

        function memoryUsage=totalmemoryusage(this,memoryUnit)
            if nargin<2
                memoryUnit=this.Options.MemoryUnits;
            end
            memoryUsage=totalmemoryusage(this.Solution,memoryUnit);
        end

        function feasibilityDetails=getFeasibilityDetails(this)
            flags=this.DBUnit.IndividualConstraintMet;
            feasibilityDetails=struct(...
            'ErrorConstraintPassed',flags(1),...
            'MemoryConstraintPassed',flags(2));
        end
    end

    methods
        function varargout=approximate(this,varargin)
            result=approximate(this.Solution,varargin{:});
            if this.Options.ApproximateSolutionType==FunctionApproximation.internal.ApproximateSolutionType.Simulink
                if nargout>0

                    varargout{1}=result.ModelObject;
                end

                if nargout>1

                    varargout{2}=result.BlockObject;
                end
            else
                if nargout>0
                    varargout{1}=result;
                end
            end
        end

        function varargout=compare(this)
            [compareData,h]=compare(this.Solution);
            varargout{1}=compareData;
            if nargout>1
                varargout{2}=h;
            end
        end

        function displayAllSolutions(this)
            displayallsolutions(this);
        end

        function displayFeasibleSolutions(this)
            displayfeasiblesolutions(this);
        end

        function sol=solutionFromID(this,id)
            sol=solutionfromID(this,id);
        end

        function memoryUsage=totalMemoryUsage(this,varargin)
            memoryUsage=totalmemoryusage(this,varargin{:});
        end

        function replaceWithApproximate(this,varargin)
            [isValid,diagnostic]=replaceWithApproximate(this.Solution,varargin);
            if~isValid
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end
        end

        function revertToOriginal(this,varargin)
            [isValid,diagnostic]=revertToOriginal(this.Solution,varargin);
            if~isValid
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end
        end

        function errorStruct=getErrorValue(this)
            errorStruct=struct(...
            'MaxErrorInSolution',this.DBUnit.ConstraintValue(1),...
            'ErrorUpperBound',this.Options.AbsTol);
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(this)
            detailsStruct=this.getDisplayDetails(this);
            propgrp(1)=matlab.mixin.util.PropertyGroup(detailsStruct);
        end

        function footerString=getFooter(this)
            footerString=this.getStringForInfeasibility(this);
        end
    end

    methods(Hidden)
        function bestSolution=getBestWithSpacing(this,spacing)
            bestSolution=getBestWithSpacing(this.Solution,spacing);
        end
    end

    methods(Static,Hidden)
        function detailsStruct=getDisplayDetails(this)
            detailsStruct={'ID','Feasible'};
            if numel(this)==1
                detailsStruct=struct(detailsStruct{1},this.ID,...
                detailsStruct{2},string(this.Feasible));
            end
        end

        function stringForInfeasibility=getStringForInfeasibility(this)
            stringForInfeasibility='';
            if numel(this)==1
                if~this.Feasible
                    details=getFeasibilityDetails(this);
                    stringForInfeasibility=sprintf('\t%s\n',message('SimulinkFixedPoint:functionApproximation:footerReasonForInfeasibility').getString());
                    if~details.ErrorConstraintPassed
                        stringForInfeasibility=sprintf('%s\t\t%s\n',stringForInfeasibility,message('SimulinkFixedPoint:functionApproximation:footerReasonForInfeasibilityError').getString());
                    end
                    if~details.MemoryConstraintPassed
                        stringForInfeasibility=sprintf('%s\t\t%s\n',stringForInfeasibility,message('SimulinkFixedPoint:functionApproximation:footerReasonForInfeasibilityMemory').getString());
                    end
                end
            end
        end
    end
end
