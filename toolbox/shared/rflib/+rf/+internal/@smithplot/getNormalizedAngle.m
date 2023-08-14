function th=getNormalizedAngle(p,theta)







    th=theta-p.AngleDrag_Delta;
    th=180-th;
    th=-th*pi/180;
