classdef DataContext




    properties(GetAccess=public,SetAccess=?FunctionApproximation.internal.visualizer.DataCollector)
        Breakpoints cell
        Original double
        Approximate double
        AbsDiff double
        MaxDiff double
        Feasible logical
        Options FunctionApproximation.Options
    end
end