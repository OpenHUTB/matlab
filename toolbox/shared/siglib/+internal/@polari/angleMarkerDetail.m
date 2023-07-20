function state=angleMarkerDetail(p,state,ID)


















    if nargin<3
        ID=p.pAngleMarkerHoverID;
    end
    if isempty(ID)
        state=[];
        return
    end
    [m_i,is_peak]=findAngleMarkerByID(p,ID);
    if nargin<2||isempty(state)
        state=m_i.ShowDetail;
        return
    end
    if strcmpi(state,'cycle')

        state=1+mod(m_i.ShowDetail,3);

    end

    if is_peak

        if p.SyncPeakMarkerDetailChange
            mAll=p.hPeakAngleMarkers;
            mAll=mAll(getDataSetIndex(mAll)==getDataSetIndex(m_i));
            set(mAll,'ShowDetail',state);
        else
            m_i.ShowDetail=state;
        end
    else

        if p.SyncCursorMarkerDetailChange
            set(p.hCursorAngleMarkers,'ShowDetail',state);
        else
            m_i.ShowDetail=state;
        end
    end
