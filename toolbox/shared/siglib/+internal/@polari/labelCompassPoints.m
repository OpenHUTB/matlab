function labelCompassPoints(p)








    if p.pAngleTickCompassPoints
        map=p.pCompassPointsMap;
        if isempty(map)

            t={'N','NNE','NE','ENE','E','ESE','SE','SSE',...
            'S','SSW','SW','WSW','W','WNW','NW','NNW'};
            Nt=numel(t);
            td=(0:Nt-1)./Nt*360;
            map=containers.Map(td,t);
            p.pCompassPointsMap=map;
        end



        cacheCoords_AngleTickLabels(p);
        s=p.pAngleLabelCoords;
        N=numel(s.th);


        u=repmat({''},1,N);
        for i=1:N
            ang_i=(i-1)/N*360;
            if isKey(map,ang_i)
                u{i}=map(ang_i);
            end
        end








        p.pAngleTickLabel=u;
        p.AngleTickLabelMode='manual';

        labelAngles(p);
        adjustAngleLabelsPos(p.hAngleText);
    end
