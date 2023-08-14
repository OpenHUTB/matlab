function DCM=aeroblkrod2dcm(rod)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    DCM=eye(3,3);
    s=zeros(3,1);
    th=0;
    sth=0;
    cth=0;

    n=norm(rod);
    if n~=0
        th=2*atan(n);
        s=rod/n;
        cth=cos(th);
        sth=sin(th);
        DCM=[s(1)^2+(1-s(1)^2)*cth,s(1)*s(2)*(1-cth)+s(3)*sth,s(1)*s(3)*(1-cth)-s(2)*sth;...
        s(1)*s(2)*(1-cth)-s(3)*sth,s(2)^2+(1-s(2)^2)*cth,s(2)*s(3)*(1-cth)+s(1)*sth;...
        s(1)*s(3)*(1-cth)+s(2)*sth,s(2)*s(3)*(1-cth)-s(1)*sth,s(3)^2+(1-s(3)^2)*cth];
    end
