

function result=doSegmentsIntersect(segmentA,segmentB)

    x1=segmentA.srcX;
    y1=segmentA.srcY;
    x2=segmentA.dstX;
    y2=segmentA.dstY;
    x3=segmentB.srcX;
    y3=segmentB.srcY;
    x4=segmentB.dstX;
    y4=segmentB.dstY;










    a1=(x2-x1);
    a2=(y2-y1);
    b1=-(x4-x3);
    b2=-(y4-y3);
    c1=(x3-x1);
    c2=(y3-y1);


    s0=(c1*b2-c2*b1)/(a1*b2-a2*b1);
    t0=(a1*c2-a2*c1)/(a1*b2-a2*b1);


    result=(0<=s0&&s0<=1&&0<=t0&&t0<=1);
end

