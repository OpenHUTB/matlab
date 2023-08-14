function th=getNormalizedAngleDeg(p,theta)













    th=theta-90-p.AngleAtTop-p.AngleDrag_Delta;
    if strcmpi(p.AngleDirection,'ccw')
        th=180-th;
    end
    for i=1:numel(th)
        if th(i)>0
            th(i)=th(i)-fix(th(i)./360).*360;
        elseif th(i)<0
            th(i)=th(i)+fix(th(i)./360).*360;
        end
        th(i)=-th(i);
        if th(i)<=-180
            th(i)=th(i)+360;
        elseif th(i)>180
            th(i)=th(i)-360;
        end
    end
