classdef(Sealed)ApproximationSolutionsDataBase<handle






    properties(SetAccess=private)
        DBUnits(:,1)FunctionApproximation.internal.database.DBUnit=FunctionApproximation.internal.database.DBUnit.empty;
        Observers={};
    end

    properties(SetAccess={?FunctionApproximation.internal.database.ApproximationSolutionsDataBase,...
        ?FunctionApproximation.internal.ApproximateGeneratorEngine})
        Count=0;
    end

    methods
        function add(this,databaseUnit)

            for k=1:numel(databaseUnit)

                databaseUnit(k).ID=this.Count;
                this.Count=this.Count+1;
            end
            this.DBUnits=[this.DBUnits;databaseUnit];
            notifyAllObservers(this);
        end

        function bestSolution=getBest(this,dbUnits)


            if nargin==1

                dbUnits=getAllDBUnits(this);
            end



            bestSolution=getBestFeasible(this,dbUnits);
            if isempty(bestSolution)
                bestSolution=getBestInfeasible(this,dbUnits);
            end
        end

        function bestSolution=getBestFeasible(this,dbUnits)


            if nargin==1

                dbUnits=getAllDBUnits(this);
            end
            bestSolution=[];


            constraintMet=logical([dbUnits.ConstraintMet]);
            indices=1:numel(dbUnits);
            indicesConstraintMet=indices(constraintMet);


            feasibleDBUnits=dbUnits(indicesConstraintMet);
            if~isempty(feasibleDBUnits)
                spacing=zeros(1,numel(feasibleDBUnits));
                bpSpec=[feasibleDBUnits.BreakpointSpecification];
                spacing(bpSpec=="EvenSpacing")=1;
                spacing(bpSpec=="ExplicitValues")=2;
                objectiveValues=[feasibleDBUnits.ObjectiveValue];
                dataToSort=[objectiveValues',spacing'];
                [~,sortedIndices]=sortrows(dataToSort,'ascend');
                bestSolution=feasibleDBUnits(sortedIndices(1));
            end
        end

        function bestSolution=getBestInfeasible(this,dbUnits)
            if nargin==1


                dbUnits=getInfeasibleDBUnits(this);
            end
            if~isempty(dbUnits)
                constraintValues=cell2mat({dbUnits.ConstraintValue}');
                constraintValuesMustBeLessThan=dbUnits(1).ConstraintValueMustBeLessThan;
                bestSolution=dbUnits(FunctionApproximation.internal.getClosestSolution(constraintValues,constraintValuesMustBeLessThan));
            else
                bestSolution=dbUnits;
            end
        end

        function dbUnit=getDBUnitFromID(this,ID)

            dbUnit=this.DBUnits([this.DBUnits.ID]==ID);
        end

        function ids=getAllIDs(this)

            ids=[this.DBUnits.ID];
        end

        function dbUnits=getAllDBUnits(this)

            dbUnits=this.DBUnits;
        end

        function dbUnits=getFeasibleDBUnits(this,index)



            if nargin<2
                dbUnits=this.DBUnits([this.DBUnits.ConstraintMet]);
            else
                allValues=cell2mat({this.DBUnits.IndividualConstraintMet}');
                dbUnits=this.DBUnits([]);
                if~isempty(allValues)
                    dbUnits=this.DBUnits(allValues(:,index));
                end
            end
        end

        function dbUnits=getInfeasibleDBUnits(this,index)




            if nargin<2
                dbUnits=this.DBUnits(~[this.DBUnits.ConstraintMet]);
            else
                allValues=cell2mat({this.DBUnits.IndividualConstraintMet}');
                dbUnits=this.DBUnits([]);
                if~isempty(allValues)
                    dbUnits=this.DBUnits(~allValues(:,index));
                end
            end
        end

        function dbUnit=getLastAdded(this)

            dbUnit=FunctionApproximation.internal.database.DBUnit.empty;
            if numel(this.DBUnits)>0
                dbUnit=this.DBUnits(end);
            end
        end

        function clearDBUnits(this)
            this.DBUnits=FunctionApproximation.internal.database.DBUnit.empty();
            this.Count=0;
        end

        function notifyAllObservers(this)
            for idx=1:numel(this.Observers)
                this.Observers{idx}.update(this);
            end
        end

        function addObserver(this,observer)
            this.Observers{end+1}=observer;
        end
    end

    methods(Hidden)
        function flag=hasDBUnit(this,dbUnit,hexType)





            hexString=getHexString(dbUnit,hexType);
            flag=~isempty(getDBUnit(this,hexString,hexType));
        end

        function dbUnit=getDBUnit(this,hexString,hexType)
            dbUnit=[];
            if~isempty(this.DBUnits)
                for ii=1:numel(this.DBUnits)
                    if strcmp(getHexString(this.DBUnits(ii),hexType),hexString)
                        dbUnit=this.DBUnits(ii);
                        break;
                    end
                end
            end
        end
    end
end


