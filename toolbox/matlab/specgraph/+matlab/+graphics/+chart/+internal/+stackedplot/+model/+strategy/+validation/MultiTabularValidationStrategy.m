classdef MultiTabularValidationStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.ValidationStrategy




    methods
        function validate(~,chartData)
            import matlab.graphics.chart.internal.stackedplot.model.index.MultiTabularIndex

            cnames=chartData.CombineMatchingNames;
            vars=chartData.DisplayVariables;
            if chartData.DisplayVariablesMode=="manual"
                for i=length(vars):-1:1
                    if~MultiTabularIndex.areVarsCompatible(chartData.SourceTable,vars{i},cnames)
                        msg=getInvalidCombinedDisplayVariablesMessage(vars{i});
                        error(msg);
                    end
                end
            end
        end
    end
end

function msg=getInvalidCombinedDisplayVariablesMessage(vars)
    vars=unique(string(vars),"stable");
    switch length(vars)
    case 1
        msg=message("MATLAB:stackedplot:OneInvalidCombinedDisplayVariable",vars);
    case 2
        msg=message("MATLAB:stackedplot:TwoInvalidCombinedDisplayVariables",vars(1),vars(2));
    case 3
        msg=message("MATLAB:stackedplot:ThreeInvalidCombinedDisplayVariables",vars(1),vars(2),vars(3));
    otherwise
        msg=message("MATLAB:stackedplot:MoreInvalidCombinedDisplayVariables",vars(1),vars(2),length(vars)-2);
    end
end
