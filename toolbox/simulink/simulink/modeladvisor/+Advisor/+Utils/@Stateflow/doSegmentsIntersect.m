
function result=doSegmentsIntersect(segmentA,segmentB)

    x1=segmentA(1);
    y1=segmentA(2);
    x2=segmentA(3);
    y2=segmentA(4);
    x3=segmentB(1);
    y3=segmentB(2);
    x4=segmentB(3);
    y4=segmentB(4);

















    a1=(x2-x1);
    a2=(y2-y1);
    b1=(x3-x4);
    b2=(y3-y4);
    c1=(x3-x1);
    c2=(y3-y1);


    s0=(c1*b2-c2*b1)/(a1*b2-a2*b1);
    t0=(a1*c2-a2*c1)/(a1*b2-a2*b1);


    result=(0<=s0&&s0<=1&&0<=t0&&t0<=1);
end

