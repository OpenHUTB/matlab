function plot(p,varargin)







    if~isvalid(p)
        error('Cannot plot using an invalid or deleted object.');
    end












    dataUnitsWereDirty=p.DataCacheDirty;
    dataPassed=nargin>1;

    np=p.NextPlot;
    dataReplaced=dataPassed&&...
    ((isa(p.hAxes,'matlab.graphics.axis.Axes')&&strcmpi(np,'replace'))||...
    (isa(p.hAxes,'matlab.ui.control.UIAxes')&&strcmpi(np,'replacechildren')));







    if dataPassed

        parseData(p,varargin);
    end

    p.pData=p.pData_Raw;
    p.DataCacheDirty=false;
    wasDirty=updateCache(p);
    firstTime=~p.pPlotExecutedAtLeastOnce;

    if isempty(p.pData)



        plot_axes(p,wasDirty);

    else




        dataAdded=strcmpi(np,'add');
        fastUpdate=strcmpi(np,'replacechildren');

        if dataUnitsWereDirty||wasDirty||dataPassed&&~fastUpdate





            plot_axes(p,wasDirty);
        end
        if dataUnitsWereDirty||wasDirty||dataPassed

            plot_data(p);
        end


        p.pPlotExecutedAtLeastOnce=true;

        if firstTime||p.pDataStyleChanged||dataAdded||dataReplaced

            updateLegend(p);
            p.pDataStyleChanged=false;
        end
    end

