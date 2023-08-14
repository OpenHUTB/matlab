function ax=destroyStuffThatGetsRestoredWhenPlotIsCalled(p)








    deleteListeners(p);




    deleteObjectsInProperty(p,'hPeakTabularReadout');
    deleteObjectsInProperty(p,'hAntenna');
    deleteObjectsInProperty(p,'hAngleSpan');
    deleteObjectsInProperty(p,'hPeakAngleMarkers');
    deleteObjectsInProperty(p,'hCursorAngleMarkers');
    deleteObjectsInProperty(p,'hLegend');


    destroyAxesChildren(p);

    resetWidgetHandleProperties(p);

    restoreFigurePointer(p);






    p.pPlotExecutedAtLeastOnce=false;
    p.pPublicPropertiesDirty=true;
    p.LastMouseBehavior='';

    p.pDataStyleChanged=false;
    p.pMagAxisHilite='none';
    p.pHoverDataSetIndex=[];
    p.pAngleMarkerHoverID='';
    p.pPeaks=[];
    p.pPeaksLast={};
    p.pPeakLocationList={};
    p.pLatestMotionEv=[];
    p.pUpdateCalled=false;





    ax=p.hAxes;
    p.hAxes=[];
