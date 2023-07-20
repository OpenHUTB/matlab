function angleMarkerHilite(p,newID)











    oldID=p.pAngleMarkerHoverID;



    if~isempty(oldID)
        mOld=findAngleMarkerByID(p,oldID);
        if isempty(mOld)
            oldID='';
        end
    end


    if strcmpi(newID,oldID)
        return
    end

    p.pAngleMarkerHoverID=newID;

    if~isempty(oldID)




        if p.HiliteAllRelatedCursorsWhenHovering



            mOld=findAllMarkersWithSameTypeAndDataset(p,oldID);
            set(mOld,'HiliteMarker',false);
        else




            switch lower(oldID(1))
            case 'c'

                mOld.HiliteMarker=false;
            case 'p'

                if p.HiliteAllRelatedPeaksWhenHovering
                    pMarkers=findPeakMarkersOnDataset(p,getDataSetIndex(mOld));
                    set(pMarkers,'HiliteMarker',false);
                else
                    mOld.HiliteMarker=false;
                end
            case 'a'

                set(p.hAngleLimCursors,'HiliteMarker',false);
            otherwise

            end
        end
    end

    if~isempty(newID)
        if p.HiliteAllRelatedCursorsWhenHovering
            mNew=findAllMarkersWithSameTypeAndDataset(p,newID);
            set(mNew,'HiliteMarker',true);
        else
            mNew=findAngleMarkerByID(p,newID);
            switch lower(newID(1))
            case 'c'

                mNew.HiliteMarker=true;
            case 'p'

                if p.HiliteAllRelatedPeaksWhenHovering
                    pMarkers=findPeakMarkersOnDataset(p,getDataSetIndex(mNew));
                    set(pMarkers,'HiliteMarker',true);
                else
                    mNew.HiliteMarker=true;
                end
            case 'a'

                set(p.hAngleLimCursors,'HiliteMarker',true);

            otherwise

            end
        end
    end
