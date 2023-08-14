function markedCleanCallback(hObj)










    [becomesVisible,visibleAxes]=getNewlyVisibleAxes(hObj);
    setXLimitsForVisibleAxes(hObj,becomesVisible);


    if~isempty(hObj.Axes_I)
        hObj.AxesVisibleCache=strcmp({hObj.Axes_I.Visible},'on');
    end

    unifyXLimits(hObj,visibleAxes);
    layoutChanged=detectLayoutChanged(hObj,visibleAxes);
    if layoutChanged
        hObj.MarkDirty('all');
    end
end

function[becomesVisible,visibleAxes]=getNewlyVisibleAxes(hObj)

    visibleAxes=[];
    becomesVisible=[];
    if~isempty(hObj.Axes_I)
        isVisible=strcmp({hObj.Axes_I.Visible},'on');
        visibleAxes=hObj.Axes_I(isVisible);

        if isequal(size(hObj.AxesVisibleCache),size(isVisible))
            becomesVisible=~hObj.AxesVisibleCache&isVisible;
        else


            becomesVisible=[];
        end
    end
end

function setXLimitsForVisibleAxes(hObj,becomesVisible)

    if any(becomesVisible)
        newaxes=hObj.Axes_I(becomesVisible);
        newaxesprops=hObj.AxesProperties_I(becomesVisible);
        for i=1:length(newaxes)






            set(newaxes(i),'YLimMode',newaxesprops(i).YLimitsMode);
            xLimManual=strcmp(hObj.XLimitsMode_I,'manual');
            if xLimManual
                set(newaxes(i),'XLim',hObj.XLimits_I);
            else
                set(newaxes(i),'XLimMode','auto');
            end
        end

        drawnow nocallbacks;
    end
end

function unifyXLimits(hObj,visibleAxes)


    xLimManual=strcmp(hObj.XLimitsMode_I,'manual');
    numAxesShown=length(visibleAxes);
    if~xLimManual&&numAxesShown>1&&~isequal(visibleAxes.XLim)
        tf=whichAxesToCheckLimits(hObj);
        if any(tf)
            [xmin,xmax]=bounds([hObj.Axes_I(tf).XLim]);
        else
            [xmin,xmax]=bounds([visibleAxes.XLim]);
        end
        set(visibleAxes,'XLim',[xmin,xmax]);

        drawnow nocallbacks;
    end
end

function tf=whichAxesToCheckLimits(hObj)







    tf=false(size(hObj.Plots));
    for i=1:length(hObj.Plots)

        if strcmp({hObj.Axes_I(i).Visible},'on')
            curraxes=hObj.Plots{i};
            nfinites=0;
            for j=1:length(curraxes)
                nfinites=nfinites+sum(isfinite(curraxes(j).XDataCache)&...
                isfinite(curraxes(j).YDataCache));
            end



            tf(i)=nfinites>=2;
        end
    end
end

function layoutChanged=detectLayoutChanged(hObj,visibleAxes)





    layoutChanged=false;
    numAxesShown=length(visibleAxes);
    if numAxesShown>0&&hObj.PositionConstraint=="outerposition"&&~isempty(hObj.OuterPositionPixelsCache)


        if hObj.Reupdate>1
            hObj.Reupdate=hObj.Reupdate-1;
            layoutChanged=true;
        elseif hObj.Reupdate==1

            info=GetLayoutInformation(visibleAxes(1));
            axesInnerWidthInPixels=info.Position(3);
            if hObj.ChartLegendWidthPixelsCache>axesInnerWidthInPixels&&hObj.ChartLegendHandle.NumColumns>1

                layoutChanged=true;
                hObj.ChartLegendWidthPixelsCache=0;
            else
                hObj.Reupdate=0;
            end
        else
            decoratedPlotBox=zeros(length(visibleAxes),4);
            for i=1:length(visibleAxes)
                info=GetLayoutInformation(visibleAxes(i));
                decoratedPlotBox(i,:)=info.DecoratedPlotBox;
            end
            boxBoundaries=[
            decoratedPlotBox(:,1:2)...
            ,decoratedPlotBox(:,1)+decoratedPlotBox(:,3)...
            ,decoratedPlotBox(:,2)+decoratedPlotBox(:,4)...
            ];
            outerBoundaries=[
            hObj.OuterPositionPixelsCache(1:2)...
            ,hObj.OuterPositionPixelsCache(1)+hObj.OuterPositionPixelsCache(3)...
            ,hObj.OuterPositionPixelsCache(2)+hObj.OuterPositionPixelsCache(4)...
            ];


            isoutside=[1,1,-1,-1].*(outerBoundaries-boxBoundaries)>=1;
            if any(isoutside(:))



                hObj.Reupdate=hObj.Reupdate+1;
                layoutChanged=true;
            end

            info=GetLayoutInformation(visibleAxes(1));
            axesInnerWidthInPixels=info.Position(3);
            if hObj.ChartLegendWidthPixelsCache>axesInnerWidthInPixels&&hObj.ChartLegendHandle.NumColumns>1
                hObj.Reupdate=hObj.Reupdate+1;
                layoutChanged=true;
            end
        end
    end
end
