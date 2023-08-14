classdef QuantizedExplicitValues1D<FunctionApproximation.internal.gridcreator.QuantizedExplicitValues








    properties(Constant)
        MaxWordLength=18;
        ProgressText='Trying ExplicitValues(%%):    ';
        DisplayFormat=['\b\b\b','%3.0f'];
        TerminateText=repmat('\b',1,29);
    end

    properties(SetAccess=private)
        OriginalValues=0;
        AbsOriginalValues=0;
        OriginalValuesSearchVector=0;
        GridMapper=FunctionApproximation.internal.gridcreator.GridToGridMapper();
        SearchVector=[];
        EvaluationGrid=[];
    end

    properties(Hidden)
        MaxPoints=2^9;
    end

    methods
        function this=QuantizedExplicitValues1D(dataTypes)
            this=this@FunctionApproximation.internal.gridcreator.QuantizedExplicitValues(dataTypes);
        end

        function grid=getGrid(this,rangeObject,~)

            acceptableTolerance=this.AcceptableTolerance;
            outputType=this.ErrorFunction.Approximation.Data.OutputType;
            epsOutput=FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(outputType);
            if~isfloat(outputType)&&(acceptableTolerance>epsOutput)



                acceptableTolerance=double(fixed.internal.math.castUniversal(acceptableTolerance,outputType,0,'RoundingMethod','Floor'));
                if acceptableTolerance>(2^6)*epsOutput
                    acceptableTolerance=acceptableTolerance-epsOutput;
                end
            end


            searchVector=getSearchVector(this,rangeObject);


            nEvaluationGrid=2^(min(this.InputTypes.WordLength,20));


            gridStrat=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.InputTypes);
            evaluationGrid=gridStrat.getGrid(rangeObject,nEvaluationGrid);
            this.EvaluationGrid=evaluationGrid{1}(:);


            this.SearchVector=searchVector(:);
            nSearchVector=numel(this.SearchVector);


            dispUtils=FunctionApproximation.internal.DisplayUtils;
            dispUtils.explicitValuesProgressStart(this.ProgressText,this.Options);
            dispUtils.explicitValuesProgressPercent(this.DisplayFormat,0,this.Options);



            this.OriginalValuesSearchVector=this.ErrorFunction.Original.evaluate(this.SearchVector);



            this.OriginalValues=this.ErrorFunction.Original.evaluate(this.EvaluationGrid);
            this.AbsOriginalValues=abs(this.OriginalValues);



            this=generateIndexMap(this,this.SearchVector,this.EvaluationGrid);


            currentPoint=1;
            nextPoint=2;
            grid=currentPoint;


            costBoundaryPoints=costFunction(this,[currentPoint,nSearchVector]);

            M=ceil(log2(nSearchVector));
            powXGrid=fliplr([0,1,2,4:4:(M-4)]);

            while((nextPoint<nSearchVector)...
                &&(costBoundaryPoints>acceptableTolerance)...
                &&~isinf(costBoundaryPoints))

                newNextPoint=nextPoint;
                for k=1:numel(powXGrid)
                    newNextPoint=powXSearch(this,...
                    powXGrid(k),...
                    currentPoint,...
                    newNextPoint,...
                    nSearchVector,...
                    acceptableTolerance);
                end



                if costFunction(this,[currentPoint,newNextPoint])>acceptableTolerance
                    break;
                else
                    currentPoint=newNextPoint;
                    nextPoint=currentPoint+1;
                end


                grid=[grid,currentPoint];%#ok<AGROW>


                displaySearchProgress(this,newNextPoint,nSearchVector);



                costBoundaryPoints=costFunction(this,[grid(end),nSearchVector]);
            end
            dispUtils.explicitValuesProgressTerminate(this.TerminateText,this.Options);

            if(grid(end)~=nSearchVector)
                grid=[grid,nSearchVector];
            end
            grid={this.SearchVector(grid)'};
        end
    end

    methods(Access=protected)
        function displaySearchProgress(this,currentValue,maxValue)
            percentageValue=100*currentValue/maxValue;
            FunctionApproximation.internal.DisplayUtils.explicitValuesProgressPercent(...
            this.DisplayFormat,percentageValue,this.Options);
        end

        function this=generateIndexMap(this,searchVector,evaluationGrid)




            gridMapperStrategy=FunctionApproximation.internal.gridcreator.GridMapperStrategyFactory().getStrategyForExplicitValueSolver(this.Options.Interpolation);
            this.GridMapper=FunctionApproximation.internal.gridcreator.GridMapperFactory().getGridToGridMapper(gridMapperStrategy);
            this.GridMapper.setKeyGrid(searchVector');
            this.GridMapper.setValueGrid(evaluationGrid');
            this.GridMapper.constructMap();
        end

        function newHead=powXSearch(this,powX,tail,head,maxIndex,acceptableTolerance)
















            newHead=head;
            while(head<=maxIndex)&&(costFunction(this,[tail,head])<=acceptableTolerance)
                newHead=head;
                head=head+(2^powX);
            end
            displaySearchProgress(this,newHead,maxIndex);
        end

        function cost=costFunction(this,searchVectorIndices)
            grid=this.SearchVector(searchVectorIndices);
            values=this.OriginalValuesSearchVector(searchVectorIndices);
            cost=Inf;
            if~FunctionApproximation.internal.isNaNOrInf(values)

                data=this.ErrorFunction.Approximation.Data;
                data.Data=[{grid},{values}];
                this.ErrorFunction.modify(data);


                originalValueIndices=getOriginalValueIndices(this,searchVectorIndices);
                cost=0;
                if~isempty(originalValueIndices)
                    originalValues=this.OriginalValues(originalValueIndices);
                    absOriginalValues=this.AbsOriginalValues(originalValueIndices);


                    approximateValues=this.ErrorFunction.Approximation.evaluate(this.EvaluationGrid(originalValueIndices));


                    errV=abs(originalValues-approximateValues)-max(this.ErrorFunction.AbsTol,this.ErrorFunction.RelTol*absOriginalValues);
                    cost=max(errV)+this.ErrorFunction.AbsTol;
                end
            end
        end

        function searchVector=getSearchVector(this,rangeObject)
            gridStrat=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.DataTypes(1));
            for ii=1:this.DataTypes(1).WordLength
                searchVectorCell=getGrid(gridStrat,rangeObject,1+2^ii);
                searchVector=searchVectorCell{1};
                if numel(searchVector)>this.MaxPoints
                    break;
                end
            end
        end

        function originalValueIndices=getOriginalValueIndices(this,searchVectorIndices)

            originalValueIndices=this.GridMapper.getIndices(searchVectorIndices);
        end
    end
end


