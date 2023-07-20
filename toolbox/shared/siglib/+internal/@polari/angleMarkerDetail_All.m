function angleMarkerDetail_All(p,st,typ)









    ID=p.pAngleMarkerHoverID;
    if strcmpi(st,'toggle')&&isempty(ID)

        st='minority';
    end

    if strcmpi(typ,'c')
        m=p.hCursorAngleMarkers;
    else
        m=p.hPeakAngleMarkers;
    end

    switch st
    case 'minority'


        tf=sum([m.ShowDetail])<=numel(m)/2;
    case 'toggle'
        if strcmpi(typ,'c')
            mp=findCursorAngleMarkerByID(p,ID);
        else
            mp=findPeakAngleMarkerByID(p,ID);
        end
        tf=~mp.ShowDetail;
    case 'on'
        tf=true;
    case 'off'
        tf=false;
    end
    set(m,'ShowDetail',tf);
