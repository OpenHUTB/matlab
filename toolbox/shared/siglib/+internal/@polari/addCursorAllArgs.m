function m=addCursorAllArgs(p,dataIdx,datasetIndex)









    if isempty(dataIdx)

        m=[];
    else
        [newCursorIdx,oldNumCursors,currShowDetail]=...
        nextAvailableMarkerIndex(p,'C');


        m=angleMarker(p,'C',newCursorIdx,dataIdx,datasetIndex);
        m.ContextMenuFcn=@(h,~)updateCursorsContextMenu(p,h,m);

        m.ShowDetail=currShowDetail;





        moveAngleMarkerVectorToFront(p,m);

        if oldNumCursors==0
            p.hCursorAngleMarkers=m;
        else

            p.hCursorAngleMarkers=[p.hCursorAngleMarkers;m];
        end
    end
