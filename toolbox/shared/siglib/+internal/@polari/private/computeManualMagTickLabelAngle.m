function[ang,txtAng]=computeManualMagTickLabelAngle(p,t)








    if nargin<2



        t=p.pMagnitudeAxisAngle-p.AngleDrag_Delta;
    end
    if t<0

        t=t+ceil(-t/360)*360;
    end


    if strcmpi(p.AngleDirection,'ccw')
        ang=90+t-p.AngleAtTop;
    else
        ang=90+p.AngleAtTop-t;
    end


    while ang>180,ang=ang-360;end
    while ang<-180,ang=ang+360;end


    if ang>=0&&ang<=180

        txtAng=ang-90;
    else

        txtAng=ang-270;
    end

    ang=ang*pi/180;

end
