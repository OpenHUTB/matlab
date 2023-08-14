classdef(Abstract)DerivativeBasedNumberOfPointsInitializer<FunctionApproximation.internal.gridsizeinitializer.Initializer






    properties(Abstract,Constant)
DerivativeOrder
DerivativeCalculator
    end

    methods
        function gridSize=getGridSize(this,context)

            functionWrapper=context.FunctionWrapper;
            absTol=context.AbsTol;
            relTol=context.RelTol;
            nD=functionWrapper.NumberOfDimensions;
            rangeObject=context.RangeObject;
            dataTypes=context.InputTypes;
            spacing=context.Spacing;


            gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(dataTypes);
            log2Points=repmat(floor(12/nD),1,nD);
            grid=gridCreator.getGrid(rangeObject,2.^log2Points);
            gridObject=FunctionApproximation.internal.Grid(grid,gridCreator);
            ranges=gridObject.RangeObject.getRangeForDimension(1:nD);
            inputValues=gridObject.getSets;
            nInputs=size(inputValues,1);


            u=arrayfun(@(x)FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(x),dataTypes);
            stepSize=max(u,2^-8);
            derivativeStrategy=FunctionApproximation.internal.derivativecalculator.DerivativeStrategy(...
            this.DerivativeOrder,...
            this.DerivativeCalculator,...
            stepSize);
            derivativeObject=FunctionApproximation.internal.derivativecalculator.DerivativeObject(derivativeStrategy,functionWrapper);


            derivatives=getDerivativeVector(derivativeObject,inputValues);
            absDerivatives=abs(derivatives/factorial(this.DerivativeOrder));


            m=mean(absDerivatives);
            s=std(absDerivatives);
            l=all(absDerivatives<=(m+2*s),2);
            absDerivatives=absDerivatives(l,:);


            scaledRanges=(ranges/ranges(1)).^(1/this.DerivativeOrder);
            absDerivatives=absDerivatives*scaledRanges(:);


            if relTol>0


                denominator=max(abs(functionWrapper).*relTol,absTol);
                denominatorValues=denominator.evaluate(inputValues);
            else
                denominatorValues=absTol*ones(nInputs,1);
            end


            hDenominator=absDerivatives'*absDerivatives;
            if hDenominator==0
                gridSize=2*ones(1,nD);
            else
                denominatorValues=denominatorValues(l);
                gridSpacing=((absDerivatives'*denominatorValues)/hDenominator)^(1/this.DerivativeOrder);
                hVec=gridSpacing*scaledRanges;
                gridSize=1+ranges./hVec;
                if spacing=="EvenPow2Spacing"
                    gridSize=2.^round(log2(gridSize))+1;
                else
                    gridSize=round(gridSize);
                end
                gridSize=max(gridSize,2);
                gridSize(isinf(gridSize)|isnan(gridSize))=2;
            end
        end
    end
end


