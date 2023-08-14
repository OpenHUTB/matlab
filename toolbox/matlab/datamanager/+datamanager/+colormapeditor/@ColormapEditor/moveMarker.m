function moveMarker(this,currentMarker)
    this.setMouseMoveListenerState(false);
    hFig=ancestor(currentMarker,'figure');
    if~isempty(hFig)
        LastHandledPosition=hgconvertunits(hFig,[hFig.CurrentPoint,0,0],get(hFig,'units'),'pixels',hFig);
        customString=getString(message('MATLAB:datamanager:colormapeditor:CustomColormap'));
        cList=this.getColorMarkerList();
        currentIndex=find(cList==double(currentMarker));
        prevIndex=find(cList(1:currentIndex-1),1,'last');
        nextIndex=currentIndex+find(cList(currentIndex+1:end),1,'first');

        hUpListener=addlistener(hFig,'WindowMouseRelease',@localUp);
        hMotionListener=addlistener(hFig,'WindowMouseMotion',@localMotion);
    end

    function localMotion(~,eventData)
        newPt=eventData.Point;

        newIndex=this.getIndexFromXPos(newPt(1));
        if newPt(1)<=LastHandledPosition(1)
            if newIndex<=prevIndex
                localUp();
                return;
            end
        elseif newPt(1)>=LastHandledPosition(1)
            if newIndex>=nextIndex
                localUp();
                return;
            end
        end
        cList=this.getColorMarkerList();

        currentMarker=handle(cList(currentIndex));

        newMap=this.getColormap();


        if currentIndex~=newIndex
            currentMarker=this.updateMarkerPosition(currentIndex,newIndex);
            newMap=this.updateColorCellsBetweenMarkers(prevIndex,newIndex,newMap);
            newMap=this.updateColorCellsBetweenMarkers(newIndex,nextIndex,newMap);
            this.updateColormapProperties(customString,newMap,this.getColorSpace(),this.isCMapInverse());
            this.updateObjectColormapNoUpdate(newMap);
            LastHandledPosition=newPt;
            currentIndex=newIndex;
        end
    end

    function localUp(~,~)
        delete(hUpListener);
        delete(hMotionListener);
        this.setMouseMoveListenerState(true);
    end
end