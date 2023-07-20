classdef MultiTabularAutoDisplayVariablesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AutoDisplayVariablesStrategy




    methods
        function setAutoDisplayVariables(~,chartData,warningFun)

            import matlab.graphics.chart.internal.stackedplot.canBeDisplayVariables







            vars=cellfun(@(t)t.Properties.VariableNames(canBeDisplayVariables(t,false)),chartData.SourceTable,"UniformOutput",false);
            vars=unique([vars{:}],"stable");
            if~isempty(chartData.XVariable)
                vars=setdiff(vars,chartData.XVariable,"stable");
            end
            vars=removeIncompatibleVariables(chartData.SourceTable,vars,chartData.CombineMatchingNames,warningFun);


            if isempty(vars)
                vars=cell(1,0);
            end
            chartData.DisplayVariables=vars;
        end
    end
end

function vars=removeIncompatibleVariables(tbls,vars,combineMatchingNames,warningFun)














    import matlab.graphics.chart.internal.stackedplot.model.index.MultiTabularIndex

    for i=length(vars):-1:1
        if~MultiTabularIndex.areVarsCompatible(tbls,vars{i},combineMatchingNames)
            msg=getInvalidCombinedDisplayVariablesMessage(vars{i});
            warningFun(msg);
            vars(i)=[];
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