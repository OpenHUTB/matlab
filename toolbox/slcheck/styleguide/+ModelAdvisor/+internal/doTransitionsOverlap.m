function result=doTransitionsOverlap(transition1,transition2)

    result=false;
    if isempty(transition1)||isempty(transition2)
        return;
    end

    t1_srcX=fix(transition1.SourceEndpoint(1));
    t2_srcX=fix(transition2.SourceEndpoint(1));
    t1_srcY=fix(transition1.SourceEndpoint(2));
    t2_srcY=fix(transition2.SourceEndpoint(2));

    t1_dstX=fix(transition1.DestinationEndpoint(1));
    t2_dstX=fix(transition2.DestinationEndpoint(1));
    t1_dstY=fix(transition1.DestinationEndpoint(2));
    t2_dstY=fix(transition2.DestinationEndpoint(2));

    t1_midX=fix(transition1.MidPoint(1));
    t2_midX=fix(transition2.MidPoint(1));
    t1_midY=fix(transition1.MidPoint(2));
    t2_midY=fix(transition2.MidPoint(2));



    src_dst_same=((t1_srcX==t2_srcX&&t1_dstX==t2_dstX)&&...
    (t1_srcY==t2_srcY&&t1_dstY==t2_dstY));

    if~src_dst_same

        src_dst_same=((t1_srcX==t2_dstX&&t1_dstX==t2_srcX)&&...
        (t1_srcY==t2_dstY&&t1_dstY==t2_srcY));



        if src_dst_same
            [t1_dstX,t1_srcX,t1_dstY,t1_srcY]=...
            deal(t1_srcX,t1_dstX,t1_srcY,t1_dstY);


            if t1_dstX==t1_srcX||t2_dstX==t2_srcX
                result=true;
                return;
            end


            if t1_dstY==t1_srcY||t2_dstY==t2_srcY
                result=true;
                return;
            end


            delta_t1X=abs(t1_dstX-t1_midX);
            delta_t1Y=abs(t1_dstY-t1_midY);


            delta_t2X=abs(t2_dstX-t2_midX);
            delta_t2Y=abs(t2_dstY-t2_midY);


            if fix(delta_t2Y/delta_t2X)==fix(delta_t1Y/delta_t1X)
                result=true;
                return;
            end

            delta_t1X=abs(t1_srcX-t1_midX);
            delta_t1Y=abs(t1_srcY-t1_midY);

            delta_t2X=abs(t2_srcX-t2_midX);
            delta_t2Y=abs(t2_srcY-t2_midY);


            if fix(delta_t2Y/delta_t2X)==fix(delta_t1Y/delta_t1X)
                result=true;
                return;
            end
        end
    end

end

