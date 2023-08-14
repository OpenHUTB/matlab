function[angRad,txtAng]=computeAutoMagTickLabelAngle(p)
































    offset=p.MagTickLabelAngleAutoOffset;
    switch lower(p.View)
    case{'full','top'}

        ang=90-offset;
    case 'bottom'

        ang=-90+offset;
    case 'left'

        ang=180-offset;
    case 'right'

        ang=0+offset;
    case 'top-left'

        ang=180-offset;
    case 'top-right'

        ang=0+offset;
    case 'bottom-left'

        ang=180+offset;
    case 'bottom-right'

        ang=0-offset;
    otherwise
        assert(false,'Unrecognized View value "%s"',p.View);
    end
    ang=principalRangeUserDeg(p,ang);

...
...
...
...
...
...
...
...
...
...
...
...


    if ang>=0&&ang<=180

        txtAng=ang-90;
    else

        txtAng=ang-270;
    end
    a0=transformNormDegToUserDeg(p,ang);
    angRad=ang*pi/180;


    a0=round(a0*100)/100;
    if a0==-180,a0=180;end
    p.pMagnitudeAxisAngle=a0;

end
