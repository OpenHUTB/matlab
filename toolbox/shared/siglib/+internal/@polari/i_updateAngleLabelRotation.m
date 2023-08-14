function i_updateAngleLabelRotation(p)





    ht=p.hAngleText;
    pos=ht(1).Position;
    r=hypot(pos(1),pos(2));


    if strcmpi(p.AngleDirection,'ccw');
        dir=-1;
    else
        dir=+1;
    end
    S=p.pAngleLabelCoords;
    th=S.th+dir*p.AngleDrag_Delta*pi/180;
    x=r.*cos(th);
    y=r.*sin(th);
    z=0.294;

    for i=1:numel(ht)
        ht(i).Position=[x(i),y(i),z];
        if p.AngleTickLabelRotation
            ht(i).Rotation=th(i)*180/pi-90;
        end
    end



    internal.polariMBAngleTicks.hiliteAngleTickLabelDrag_Update(p);
