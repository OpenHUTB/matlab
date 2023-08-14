function hit=isAxesHit(ax,vp,pt,offset)



    hit=false;
    li=ax.GetLayoutInformation;



    pos=[offset(1:2),0,0]+li.PlotBox;

    if li.is2D
        if pt(1)>=pos(1)&&pt(1)<=pos(1)+pos(3)&&...
            pt(2)>=pos(2)&&pt(2)<=pos(2)+pos(4)
            hit=true;
        end
    else

        if vp(3)<1||vp(4)<1
            return;
        end

        b=matlab.graphics.interaction.internal.axesBox(ax,vp);

        w=double(vp(3));
        h=double(vp(4));
        if strcmp(ax.Projection,'orthographic')
            hit=(isPlaneHit(b,'backxy',pt,w,h,offset)||...
            isPlaneHit(b,'backyz',pt,w,h,offset)||...
            isPlaneHit(b,'backzx',pt,w,h,offset));
        else
            hit=(isPlaneHit(b,'backxy',pt,w,h,offset)||...
            isPlaneHit(b,'backyz',pt,w,h,offset)||...
            isPlaneHit(b,'backzx',pt,w,h,offset)||...
            isPlaneHit(b,'frontxy',pt,w,h,offset)||...
            isPlaneHit(b,'frontyz',pt,w,h,offset)||...
            isPlaneHit(b,'frontzx',pt,w,h,offset));
        end
    end

    function hit=isPlaneHit(b,plane,pt,w,h,offset)
        hit=false;
        if isfield(b,plane)
            wall=b.(plane);
            x=b.corners(1,:)*w;
            y=b.corners(2,:)*h;
            x=x(wall);
            y=y(wall);
            if matlab.graphics.interaction.internal.isPointInPolygon(pt,x+offset(1),y+offset(2))
                hit=true;
                return
            end
        end
