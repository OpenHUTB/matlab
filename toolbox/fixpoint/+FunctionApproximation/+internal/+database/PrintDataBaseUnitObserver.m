classdef PrintDataBaseUnitObserver<FunctionApproximation.internal.database.DataBaseObserver





    methods
        function update(this,database)
            count=database.Count;
            if count>0
                dbUnit=getLastAdded(database);
                if count==1


                    FunctionApproximation.internal.DisplayUtils.displayDBUnitHeader(dbUnit,this.Options);
                end
                FunctionApproximation.internal.DisplayUtils.displayDBUnit(dbUnit,this.Options);
            end
        end
    end
end
