function th=getNormalizedAngle(p,theta)












    th=theta-90-p.AngleAtTop-p.AngleDrag_Delta;
    if strcmpi(p.AngleDirection,'ccw')
        th=180-th;
    end
    th=-th*pi/180;
