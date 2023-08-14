function angleMarkerOriginLine(p,state,ID)









    if nargin<3
        ID=p.pAngleMarkerHoverID;
    end
    if~isempty(ID)
        [m,is_peak]=findAngleMarkerByID(p,ID);
        if is_peak



            mAll=findPeakMarkersOnDataset(p,getDataSetIndex(m));
            set(mAll,'OriginLine',state);
        else

            m.OriginLine=state;
        end
    end
