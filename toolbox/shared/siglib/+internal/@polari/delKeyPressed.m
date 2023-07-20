function delKeyPressed(p)


    s=computeHoverLocation(p,[]);
    if s.overMarker




        ID=p.pAngleMarkerHoverID;
        if~isempty(ID)
            m=findAngleMarkerByID(p,ID);
            switch lower(ID(1))
            case 'p'
                m_removePeaks(p,getDataSetIndex(m));
            case 'c'
                m_removeCursors(p,m.Index);
            case 'a'
                showAngleLimCursors(p,false);
            otherwise

            end
        end

    elseif s.overLegend
        p.LegendVisible=false;




    elseif s.overSpan||s.overSpanReadout
        showAngleSpan(p,false);

    elseif s.overMagnitudeTicks


    elseif s.overAngleTicks


    elseif s.overGrid



    elseif s.overLobes||s.overAntennaReadout
        if removeAngleMarkersWithDialog(p)
            p.AntennaMetrics=false;
        end

    elseif s.overTitleTop

        p.TitleTop='';

    elseif s.overTitleBottom

        p.TitleBottom='';



    end
