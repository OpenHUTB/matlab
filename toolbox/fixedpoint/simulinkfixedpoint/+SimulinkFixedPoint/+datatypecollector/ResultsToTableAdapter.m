classdef ResultsToTableAdapter<handle





    methods(Abstract)
        tableObject=getTable(this,results);
    end
end