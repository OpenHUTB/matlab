function rod=aeroblkangle2rod(ang,seq)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    r1=ang(1);
    r2=ang(2);
    r3=ang(3);
    rod=zeros(3,1);


    cps=cos(r1);
    sps=sin(r1);
    cth=cos(r2);
    sth=sin(r2);
    cph=cos(r3);
    sph=sin(r3);

    switch seq
    case 0
        tr=cth.*cps+sph.*sth.*sps+cph.*cps+cth.*cph;
        r31=cph.*sth.*cps+sph.*sps+sth;
        r23=cth.*sph-cph.*sth.*sps+sph.*cps;
        r12=cth.*sps-sph.*sth.*cps+cph.*sps;
    case 1
        tr=cph.*cth.*cps-sph.*sps-sph.*cth.*sps+cph.*cps+cth;
        r31=sth.*cps+cph.*sth;
        r23=sph.*sth-sth.*sps;
        r12=cph.*cth.*sps+sph.*cps+sph.*cth.*cps+cph.*sps;
    case 2
        tr=cph.*cps-sph.*sth.*sps+cth.*cps+cph.*cth;
        r31=sph.*cps+cph.*sth.*sps+cth.*sph;
        r23=sth-sph.*sps+cph.*sth.*cps;
        r12=cph.*sps+sph.*sth.*cps+cth.*sps;
    case 3
        tr=cph.*cps-sph.*cth.*sps-sph.*sps+cph.*cth.*cps+cth;
        r31=sth.*sps-sph.*sth;
        r23=cph.*sth+sth.*cps;
        r12=cph.*sps+sph.*cth.*cps+sph.*cps+cph.*cth.*sps;
    case 4
        tr=cph.*cps+sph.*sth.*sps+cth.*cph+cth.*cps;
        r31=cth.*sps+cph.*sps-sph.*sth.*cps;
        r23=sph.*sps+cph.*sth.*cps+sth;
        r12=sph.*cth+sph.*cps-cph.*sth.*sps;
    case 5
        tr=cph.*cps-sph.*cth.*sps+cth-sph.*sps+cph.*cth.*cps;
        r31=sph.*cps+cph.*cth.*sps+cph.*sps+sph.*cth.*cps;
        r23=sth.*cps+sth.*cph;
        r12=sth.*sph-sth.*sps;
    case 6
        tr=cth.*cps+cph.*cth-sph.*sth.*sps+cph.*cps;
        r31=sph.*sth.*cps+cph.*sps+cth.*sps;
        r23=cph.*sth.*sps+sph.*cps+sph.*cth;
        r12=sth+cph.*sth.*cps-sph.*sps;
    case 7
        tr=cph.*cth.*cps-sph.*sps+cth-sph.*cth.*sps+cph.*cps;
        r31=sph.*cth.*cps+cph.*sps+cph.*cth.*sps+sph.*cps;
        r23=sth.*sps-sph.*sth;
        r12=cph.*sth+sth.*cps;
    case 8
        tr=cph.*cth+cph.*cps-sph.*sth.*sps+cps.*cth;
        r31=sth-sph.*sps+cph.*sth.*cps;
        r23=cph.*sps+sph.*sth.*cps+sps.*cth;
        r12=sph.*cps+cph.*sth.*sps+sph.*cth;
    case 9
        tr=cth+cph.*cps-sph.*cth.*sps-sph.*sps+cph.*cth.*cps;
        r31=cph.*sth+sth.*cps;
        r23=cph.*sps+sph.*cth.*cps+sph.*cps+cph.*cth.*sps;
        r12=sth.*sps-sph.*sth;
    case 10
        tr=cph.*cth+cth.*cps+sph.*sth.*sps+cph.*cps;
        r31=sph.*cth-cph.*sth.*sps+sph.*cps;
        r23=cth.*sps-sph.*sth.*cps+cph.*sps;
        r12=cph.*sth.*cps+sph.*sps+sth;
    case 11
        tr=cth+cph.*cth.*cps-sph.*sps-sph.*cth.*sps+cph.*cps;
        r31=sph.*sth-sps.*sth;
        r23=cph.*cth.*sps+sph.*cps+sph.*cth.*cps+cph.*sps;
        r12=cps.*sth+cph.*sth;
    otherwise
        tr=0;
        r31=0;
        r23=0;
        r12=0;
    end

    th=acos((tr-1)/2);
    t0=th~=0;

    sx=0;
    sy=0;
    sz=0;
    if t0
        sy=r31/(2*sin(th));
        sx=r23/(2*sin(th));
        sz=r12/(2*sin(th));


        rod(1)=tan(th/2)*sx;
        rod(2)=tan(th/2)*sy;
        rod(3)=tan(th/2)*sz;
    end
