function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_blk_lookup:unlicensedComponentLabel'));
        return;

    end


    if(c.isSinglePlot|c.isDoublePlot)
        plotString='snapshot';
    else
        plotString='';
    end

    if(c.isSingleTable|c.isDoubleTable|c.isMultiTable)
        tableString='table';
    else
        tableString='';
    end

    if(c.isSinglePlot|c.isSingleTable)
        singleString='1-D';
    else
        singleString='';
    end

    if(c.isDoublePlot|c.isDoubleTable)
        doubleString='2-D';
    else
        doubleString='';
    end

    if(c.isMultiTable)
        multiString='N-D';
        if(~isempty(singleString)|~isempty(doubleString))
            multiConjunction='/';
        else
            multiConjunction='';
        end
    else
        multiString='';
        multiConjunction='';
    end

    if(~isempty(tableString)&~isempty(plotString))
        typeConjunction='/';
    else
        typeConjunction='';
    end

    if(~isempty(singleString)&~isempty(doubleString))
        dimensionConjunction='/';
    else
        dimensionConjunction='';
    end

    s=sprintf(getString(message('RptgenSL:rsl_csl_blk_lookup:lookUpMsg')),...
    plotString,...
    typeConjunction,...
    tableString,...
    singleString,...
    dimensionConjunction,...
    doubleString,...
    multiConjunction,...
    multiString);
