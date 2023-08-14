classdef EvenSpacingLUTSolver<FunctionApproximation.internal.solvers.LUTSolver







    methods
        function registerDependencies(this,problemObject)
            registerDependencies@FunctionApproximation.internal.solvers.LUTSolver(this,problemObject);




            if problemObject.InputFunctionType=="LUTBlock"
                this.GridSizeInitializer=FunctionApproximation.internal.gridsizeinitializer.MinimumNumberOfPointsInitializer();
            else
                if(this.Options.Interpolation=="Linear")
                    this.GridSizeInitializer=FunctionApproximation.internal.gridsizeinitializer.SecondDerivativeNumberOfPointsInitializer();
                else
                    this.GridSizeInitializer=FunctionApproximation.internal.gridsizeinitializer.FirstDerivativeNumberOfPointsInitializer();
                end
            end
        end
    end

    methods(Access=protected)
        function setSpacing(this)
            this.Spacing=FunctionApproximation.BreakpointSpecification.EvenSpacing;
        end

        function gridCreator=getGridCreator(~,inputTypes)
            gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(inputTypes,true);
        end

        function gridObject=getGrid(this,gridSize)
            gridCreator=getGridCreator(this,this.StorageTypes(1:end-1));
            rangeObject=this.TableDataRangeObject;
            grid=getGrid(gridCreator,rangeObject,gridSize);
            gridObject=FunctionApproximation.internal.Grid(grid,gridCreator);
        end

        function flag=proceedToValidateConstraint(this,dbUnit)
            flag=~hasDBUnit(this.DataBase,dbUnit,"Partial");
        end

        function flag=attemptConstraintCheck(this,currentObjectiveValue)
            flag=(this.MaxObjectiveValue>currentObjectiveValue);
        end

        function performSearch(this)


            currentError=getError(this,2*ones(1,this.NumberOfDimensions));




            nDSearchStart=this.DataBase.Count+1;
            if~isempty(currentError)&&~passAllConstraints(this,currentError,this.ObjectiveValue)


                gridSize=initializePoints(this);
                if(this.NumberOfDimensions>1)
                    scaleMatrix=repmat([1,0.75,0.5,0.25]',1,numel(gridSize));
                    bias=[0,0,0,0]';
                    gridSets=FunctionApproximation.internal.solvers.getTransformedGrid(gridSize,scaleMatrix,bias);
                    gridSets=unique(gridSets,'rows');
                    gridSets=gridSets(all(gridSets>1,2),:);
                else
                    scaleMatrix=repmat([1,0.75,0.5]',1,numel(gridSize));
                    bias=[0,0,0]';
                    gridSets=FunctionApproximation.internal.solvers.getTransformedGrid(gridSize,scaleMatrix,bias);
                end
                for iSet=1:size(gridSets,1)
                    if this.HardConsTracker.advance()&&this.SoftConsTracker.advance()
                        startIDInfeasible=this.DataBase.Count+1;
                        findGridMeetingErrorConstraint(this,gridSets(iSet,:),currentError);
                        [low,high]=getBoundsForBinarySearch(this,startIDInfeasible);
                        binarySearch(this,low,high);
                        errorFeasibleDBUnits=getFeasibleDBUnits(this.DataBase,1);
                        bestFeasible=getBest(this.DataBase,errorFeasibleDBUnits);
                        if isempty(bestFeasible)
                            break;
                        end
                    end
                end
            end

            if this.HardConsTracker.advance()









                dbUnits=this.DataBase.DBUnits;
                dbUnits=dbUnits(nDSearchStart:end);
                bestSolution=getBest(this.DataBase,dbUnits);
                if~isempty(bestSolution)&&bestSolution.ConstraintMet
                    nD=this.NumberOfDimensions;
                    for shift=nD:-1:1
                        bestGrid=bestSolution.GridSize;
                        for ii=circshift(1:nD,shift)
                            tmp=bestGrid;
                            low=2;
                            high=bestGrid(ii);
                            mid=floor((low+high)/2);
                            tmp(ii)=mid;
                            errorMid=getError(this,tmp);

                            while~isempty(errorMid)&&(high-low>1)
                                passedConstraint=passErrorConstraint(this,errorMid);
                                if passedConstraint&&bestGrid(ii)>mid
                                    bestGrid(ii)=mid;
                                end
                                low=~passedConstraint*mid+passedConstraint*low;
                                high=passedConstraint*mid+~passedConstraint*high;

                                midOld=mid;
                                mid=floor((low+high)/2);
                                if midOld==mid
                                    break;
                                else
                                    tmp(ii)=mid;
                                    errorMid=getError(this,tmp);
                                end
                            end
                        end
                    end
                end
            end
        end

        function[recheckConstraintMet,currentError]=validateWithSaturationOn(~,constraintMet,currentError,~)
            recheckConstraintMet=constraintMet;




        end
    end

    methods(Access={?FunctionApproximation.internal.solvers.LUTSolver,...
        ?FunctionApproximation.internal.progresstracking.TrackingStrategy})

        function maxAttempts=getMaxAttempts(~)
            maxAttempts=3;
        end

        function dbUnits=getFeasibleDBUnits(this,varargin)
            dbUnits=getFeasibleDBUnits(this.DataBase,varargin{:});
            if~isempty(dbUnits)
                dbUnits=dbUnits([dbUnits.BreakpointSpecification]=="EvenSpacing");
            end
        end

    end

    methods(Access=private)
        function[low,high]=getBoundsForBinarySearch(this,startIDInfeasible)

            defaultSize=2*ones(1,this.NumberOfDimensions);
            low=defaultSize;
            high=low;

            dbUnits=this.DataBase.DBUnits;
            searchSetInfeasibleUnits=dbUnits(startIDInfeasible:end);
            errorConstraintsMet=arrayfun(@(x)x.IndividualConstraintMet(1),searchSetInfeasibleUnits);
            infeasibleDBUnits=searchSetInfeasibleUnits(~errorConstraintsMet);

            errorConstraintsMet=arrayfun(@(x)x.IndividualConstraintMet(1),dbUnits);
            feasibleDBUnits=dbUnits(errorConstraintsMet);

            numFeasible=numel(feasibleDBUnits);
            numInfeasible=numel(infeasibleDBUnits);
            swl=this.StorageWordLengths;
            if numFeasible&&numInfeasible
                [minErrorInfeasible,minErrorID]=min(arrayfun(@(x)x.ConstraintValue(1),infeasibleDBUnits));%#ok<ASGLU>
                minErrorObjective=infeasibleDBUnits(minErrorID).ObjectiveValue;
                tableValuesMemory=minErrorObjective-sum(2*swl(1:end-1));
                if tableValuesMemory>0
                    low=round(repmat(((tableValuesMemory)/swl(end))^(1/this.NumberOfDimensions),1,this.NumberOfDimensions));
                end

                minObjectiveFeasible=min(arrayfun(@(x)x.ObjectiveValue,feasibleDBUnits));
                tableValuesMemory=minObjectiveFeasible-sum(2*swl(1:end-1));
                if tableValuesMemory>0
                    high=round(repmat(((tableValuesMemory)/swl(end))^(1/this.NumberOfDimensions),1,this.NumberOfDimensions));
                end
            end

            if any(high<low)
                high=low;
            end

            low=max(low,defaultSize);
            high=max(high,defaultSize);
        end

        function binarySearch(this,low,high)




            if numel(this.DataBase.DBUnits)>=2
                mid=floor((low+high)/2);
                errorMid=getError(this,mid);

                while~isempty(errorMid)&&(sum(high-low)>this.NumberOfDimensions)&&this.HardConsTracker.advance()
                    passedConstraint=passErrorConstraint(this,errorMid);
                    low=~passedConstraint*mid+passedConstraint*low;
                    high=passedConstraint*mid+~passedConstraint*high;

                    midOld=mid;
                    mid=floor((low+high)/2);
                    if midOld==mid
                        break;
                    else
                        errorMid=getError(this,mid);
                    end
                end
            end
        end

        function findGridMeetingErrorConstraint(this,gridSize,currentError)


            while~passErrorConstraint(this,currentError)...
                &&(prod(gridSize)<2^27)...
                &&~isnan(currentError)




                bias=[1;0;];
                scaleMatrix=ones(numel(bias),numel(gridSize));
                gridSets=FunctionApproximation.internal.solvers.getAllGridSizeCombinations(gridSize,scaleMatrix,bias);
                for iSet=1:size(gridSets,1)
                    currentError=getError(this,gridSets(iSet,:));
                end



                gridSize=gridSize*2;
            end
        end
    end
end

