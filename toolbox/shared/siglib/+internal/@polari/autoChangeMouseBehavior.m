function autoChangeMouseBehavior(p,s)








    if s.overLegend
        changeMouseBehavior(p,'legend');
        return
    elseif s.overTitleTop
        changeMouseBehavior(p,'titletop');
        return
    elseif s.overTitleBottom
        changeMouseBehavior(p,'titlebottom');
        return
    elseif s.overFigPanel


        changeMouseBehavior(p,'peakstable');
        return
    elseif~s.inAxes

        changeMouseBehavior(p,'general');
        return
    end



    if s.overGrid

        p.MagDrag_OrigRadius=s.radius;
        changeMouseBehavior(p,'grid');

    elseif s.overMarker
        angleMarkerHilite(p,s.overMarkerID);
        changeMouseBehavior(p,'anglemarker');

    elseif s.overMagnitudeTicks

        p.MagDrag_OrigRadius=s.radius;
        if p.MagHiliteOnHover
            hiliteMagAxisDrag_Init(p,'on');
        end
        changeMouseBehavior(p,'magticks');

    elseif s.overAngleTicks


        if p.AngleHiliteOnHover
            internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Init(p,'on');
        end
        changeMouseBehavior(p,'angleticks');

    elseif s.overDataset
        p.pHoverDataSetIndex=s.overDatasetIndex;
        changeMouseBehavior(p,'dataset');

    elseif s.overSpan



        p.SpanDrag_PrevCplx=complex(cos(s.angle),sin(s.angle));
        hiliteSpanDrag_Init(p,'on');
        changeMouseBehavior(p,'anglespan');

    elseif s.overSpanReadout

        changeMouseBehavior(p,'spanreadout');

    elseif s.overLobes






        p.MagDrag_OrigRadius=s.radius;
        changeMouseBehavior(p,'grid');





        if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
            start(p.hToolTip,...
            {upper([s.overLobesType,' Lobe']),...
            'Right-click for options'});
        end

    elseif s.overAntennaReadout
        changeMouseBehavior(p,'antennareadout');

    else

        changeMouseBehavior(p,'general');
    end
