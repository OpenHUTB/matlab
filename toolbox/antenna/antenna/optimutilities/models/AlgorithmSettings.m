classdef AlgorithmSettings

    properties
        SelectedSettings;
        ListOfObjectiveFunctions={};
        ListOfConstraints={};
        ListOfParameters={};
        Objectives='Single';
        ParamType;
        SmartParamFunction;
        PopType;
        AutoPenalties=0;
        GeometricConstraintFunction;
        ParentFigure;
        EnableLog;
    end

    properties(Dependent)
        AutoPopSize;
    end

    methods
        function popSize=get.AutoPopSize(obj)
            if length(obj.ListOfParameters)<=5
                popSize=AutoPopulationSize.ForLessOrEqualThanFiveParameters;
            elseif length(obj.ListOfParameters)>5&&...
                length(obj.ListOfParameters)<=10
                popSize=AutoPopulationSize.ForMoreThanFiveAndLessOrEqualThanTenParameters;
            else
                popSize=AutoPopulationSize.OtherCases;
            end
        end
    end

end