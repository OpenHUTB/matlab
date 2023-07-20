function vars=getValidVariableNames(tbl)






    import matlab.graphics.chart.internal.stackedplot.canBeDisplayVariables

    if istabular(tbl)
        vars=tbl.Properties.VariableNames;
        vars=vars(canBeDisplayVariables(tbl,false));
    elseif iscell(tbl)
        vars=cellfun(@matlab.graphics.chart.internal.stackedplot.getValidVariableNames,tbl,"UniformOutput",false);
        vars=unique([vars{:}],"stable");
    end
