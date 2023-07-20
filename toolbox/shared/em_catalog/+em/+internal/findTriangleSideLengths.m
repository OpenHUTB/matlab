function[l1,l2,l3]=findTriangleSideLengths(pt)

    l1=norm(pt(1,:)-pt(2,:));
    l2=norm(pt(1,:)-pt(3,:));
    l3=norm(pt(2,:)-pt(3,:));
