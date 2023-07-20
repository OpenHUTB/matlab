function t=isPointAlongXorY(TR,e,posn)
    for i=1:size(posn,1)
        t(i)=false;
        pe=em.MeshGeometry.findEdgeThroughPoint(TR.Points,e,posn(i,1:2));
        if~isempty(pe)
            x=[1,0,0];
            y=[0,1,0];
            ev=pe(2,:)-pe(1,:);
            ev=[ev,0];
            isonX=abs(dot(x,ev))<sqrt(eps);
            isonY=abs(dot(y,ev))<sqrt(eps);
            if isonX||isonY
                t(i)=true;
            end
        end
    end
end