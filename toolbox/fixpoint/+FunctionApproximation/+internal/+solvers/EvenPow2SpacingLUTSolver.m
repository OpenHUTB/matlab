classdef EvenPow2SpacingLUTSolver<FunctionApproximation.internal.solvers.EvenSpacingLUTSolver







    methods(Access=protected)
        function setSpacing(this)
            this.Spacing=FunctionApproximation.BreakpointSpecification.EvenPow2Spacing;
        end

        function gridingStrategy=getGridCreator(~,inputTypes)
            gridingStrategy=FunctionApproximation.internal.gridcreator.QuantizedEvenPow2SpacingCartesianGrid(inputTypes,true);
        end
    end

    methods(Access={?FunctionApproximation.internal.solvers.LUTSolver,...
        ?FunctionApproximation.internal.progresstracking.TrackingStrategy})
        function dbUnits=getFeasibleDBUnits(this,varargin)
            dbUnits=getFeasibleDBUnits(this.DataBase,varargin{:});
            if~isempty(dbUnits)
                dbUnits=dbUnits([dbUnits.BreakpointSpecification]=="EvenPow2Spacing");
            end
        end
    end
end
