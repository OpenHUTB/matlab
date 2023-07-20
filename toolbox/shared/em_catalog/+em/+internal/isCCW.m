function tf=isCCW(l1,l2)




    p1=l1(:,1)';
    p2=l1(:,2)';
    p3=l2(:,1)';
    p4=l2(:,2)';


    Dacd=[1,p1;1,p3;1,p4];
    Dbcd=[1,p2;1,p3;1,p4];

    Dabc=[1,p1;1,p2;1,p3];
    Dabd=[1,p1;1,p2;1,p4];

    tf=(det(Dacd)>0)~=(det(Dbcd)>0)&&((det(Dabc)>0)~=(det(Dabd)>0));

end







