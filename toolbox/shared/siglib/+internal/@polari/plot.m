function plot(p,varargin)






    if~isvalid(p)
        error('Cannot plot using an invalid or deleted object.');
    end












    dataUnitsWereDirty=p.DataCacheDirty;
    dataPassed=nargin>1;




    np=p.NextPlot;
    dataReplaced=dataPassed&&strcmpi(np,'replace');
    if dataReplaced
        prevCursorAngles=[];
        if dataPassed



            mC=p.hCursorAngleMarkers;
            if~isempty(mC)
                prevCursorAngles=getAngleFromVec(mC);
            end
        end
    end







    if dataPassed

        parseData(p,varargin);
    end
    updateTransformedData(p);
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

        if dataReplaced



            updateMarkersForDatasetChanges(p,prevCursorAngles);
        elseif wasDirty






            hideAngleMarkerDataDots(p,false);
        end





        if firstTime

        end
    end


    if~firstTime&&dataUnitsWereDirty
        notify(p,'DataUnitsChanged');
    end
