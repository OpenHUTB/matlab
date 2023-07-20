function result=doTransitionsOverlap(transition1,transition2)

    result=false;
    if isempty(transition1)||isempty(transition2)
        return;
    end
    t1_srcX=transition1.SourceEndpoint(1);
    t2_srcX=transition2.SourceEndpoint(1);
    t1_srcY=transition1.SourceEndpoint(2);
    t2_srcY=transition2.SourceEndpoint(2);

    t1_dstX=transition1.DestinationEndpoint(1);
    t2_dstX=transition2.DestinationEndpoint(1);
    t1_dstY=transition1.DestinationEndpoint(2);
    t2_dstY=transition2.DestinationEndpoint(2);








    delta_t1X=(t1_srcX-t1_dstX);
    delta_t1Y=(t1_srcY-t1_dstY);
    delta_t2X=(t2_srcX-t2_dstX);
    delta_t2Y=(t2_srcY-t2_dstY);

    areTransStraight=Advisor.Utils.Stateflow.isTransitionStraight(transition1)&&...
    Advisor.Utils.Stateflow.isTransitionStraight(transition2);
    areverttrans=(abs(delta_t1X)<1||abs(delta_t2X)<1);
    arehorztrans=(abs(delta_t1Y)<1||abs(delta_t2Y)<1);
    isslopeeql=~arehorztrans&&~areverttrans&&areTransStraight&&...
    (abs((delta_t2Y/delta_t2X)-(delta_t1Y/delta_t1X))<1);


    dohorztransoverlap=false;
    doverttransoverlap=false;
    delta_t1X=abs(delta_t1X);
    delta_t1Y=abs(delta_t1Y);
    delta_t2X=abs(delta_t2X);
    delta_t2Y=abs(delta_t2Y);

    if(delta_t1X<1&&delta_t2X<1)&&(abs(t1_srcX-t2_srcX)<1)
        t1_max_h=max(transition1.SourceEndpoint(2),transition1.DestinationEndpoint(2));
        t1_min_h=min(transition1.SourceEndpoint(2),transition1.DestinationEndpoint(2));
        t2_max_h=max(transition2.SourceEndpoint(2),transition2.DestinationEndpoint(2));
        t2_min_h=min(transition2.SourceEndpoint(2),transition2.DestinationEndpoint(2));
        if~((t2_min_h>t1_max_h)||(t2_max_h<t1_min_h))
            dohorztransoverlap=true;
        end
    end
    if(delta_t1Y<1&&delta_t2Y<1)&&(abs(t1_srcY-t2_srcY)<1)
        t1_max_v=max(transition1.SourceEndpoint(1),transition1.DestinationEndpoint(1));
        t1_min_v=min(transition1.SourceEndpoint(1),transition1.DestinationEndpoint(1));
        t2_max_v=max(transition2.SourceEndpoint(1),transition2.DestinationEndpoint(1));
        t2_min_v=min(transition2.SourceEndpoint(1),transition2.DestinationEndpoint(1));
        if~((t2_min_v>t1_max_v)||(t2_max_v<t1_min_v))
            doverttransoverlap=true;
        end
    end


    if(dohorztransoverlap||doverttransoverlap)
        result=true;
        return;
    elseif(isslopeeql)
        t1_max=max(transition1.SourceEndpoint,transition1.DestinationEndpoint);
        t1_min=min(transition1.SourceEndpoint,transition1.DestinationEndpoint);
        t2_sx=transition2.SourceEndpoint;
        t2_dx=transition2.DestinationEndpoint;

        do_ptsoverlap=~(((t2_sx(1)>t1_max(1))&&(t2_dx(1)>t1_max(1)))||...
        ((t2_sx(1)<t1_min(1))&&(t2_dx(1)<t1_min(1))))&&...
        ~(((t2_sx(2)>t1_max(2))&&(t2_dx(2)>t1_max(2)))||...
        ((t2_sx(2)<t1_min(2))&&(t2_dx(2)<t1_min(2))));
        Thrshld=3;

        if do_ptsoverlap






            nr=abs((t2_dstX-t2_srcX)*(t2_srcY-t1_srcY)-(t2_srcX-t1_srcX)*(t2_dstY-t2_srcY));
            dr=min(sqrt(((t2_dstX-t2_srcX)^2)+((t2_dstY-t2_srcY)^2)),1e6);
            if((nr/dr)<Thrshld)
                result=true;
                return;
            end
        end
    end
    if~(areTransStraight)

        Threshold=1;

        if all(abs(fix(transition1.SourceEndpoint-transition2.SourceEndpoint))<Threshold)||...
            all(abs(fix(transition1.DestinationEndpoint-transition2.DestinationEndpoint))<Threshold)||...
            all(abs(fix(transition1.SourceEndpoint-transition2.DestinationEndpoint))<Threshold)
            result=true;
            return;
        end
    end
end