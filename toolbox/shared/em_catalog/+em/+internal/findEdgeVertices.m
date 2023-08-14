function[edgeVertex1,edgeVertex2]=findEdgeVertices(polyq,polyv,pt,r)












    if isempty(polyv)

        [in1,on1]=inpolygon(pt(1),pt(2),polyq(:,1),polyq(:,2));

        if~in1&&~on1












            d=delaunayTriangulation(polyq(:,1),polyq(:,2));
            k=freeBoundary(d);
            [in2,on2]=inpolygon(pt(1),pt(2),polyq(k,1),polyq(k,2));
            if~in2
                [isFixed,fixedVertices]=em.internal.fixVertices(pt,[polyq(k,1),polyq(k,2)],sqrt(eps));
                if isFixed
                    pt=fixedVertices;

                    [in2,on2]=inpolygon(pt(1),pt(2),polyq(k,1),polyq(k,2));
                end
            end
            in=in2;
            on=on2;
        else
            in=in1;
            on=on1;
        end



        temp=polyq;
        if any(in)||any(on)
            p1=em.internal.makeBoundingCircle(r,pt)';
            p2=em.internal.findPointsInsideRegion(p1,temp,r,pt);
            [C1,C2]=em.internal.testForEdgeVertices(p2,pt);
        else
            C1=[];
            C2=[];
        end
        edgeVertex1=C1;
        edgeVertex2=C2;
        return;
    end






    [in,on]=inpolygon(polyq(:,1),polyq(:,2),polyv(:,1),polyv(:,2));
    if any(in)||any(on)

        [in,on]=inpolygon(pt(1),pt(2),polyv(:,1),polyv(:,2));



        temp=polyq;
        if any(in)||any(on)
            p1=em.internal.makeBoundingCircle(r,pt)';
            p2=em.internal.findPointsInsideRegion(p1,temp);
            [C1,C2]=em.internal.testForEdgeVertices(p2,pt);
        else
            C1=[];
            C2=[];
        end
        edgeVertex1=C1;
        edgeVertex2=C2;
    else
        edgeVertex1=[];
        edgeVertex2=[];
    end
