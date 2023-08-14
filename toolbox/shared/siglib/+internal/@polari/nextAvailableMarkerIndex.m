function[newMarkerIdx,currNumMarkers,currShowDetail]=...
    nextAvailableMarkerIndex(p,markerType)







    if strcmpi(markerType,'c')
        markers=p.hCursorAngleMarkers;
    else
        markers=p.hPeakAngleMarkers;
    end
    currNumMarkers=numel(markers);









    if currNumMarkers==0
        newMarkerIdx=1;
        currShowDetail=1;
    else
        currIndex=[markers.Index];
        maxIndex=max(currIndex);
        allIndex=1:maxIndex;
        allIndex(currIndex)=[];
        if isempty(allIndex)

            newMarkerIdx=1+currNumMarkers;
        else

            newMarkerIdx=allIndex(1);
        end


        currShowDetail=markers(1).ShowDetail;
    end
