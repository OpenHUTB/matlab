function cacheCoords_MagTickLabels(p)





    S=p.pMagnitudeLabelCoords;







    if strcmpi(p.MagnitudeAxisAngleMode,'auto')
        [ang,txtAng]=computeAutoMagTickLabelAngle(p);
    else
        [ang,txtAng]=computeManualMagTickLabelAngle(p);
    end



    S.textAngle=txtAng;
    S.ang=ang*180/pi;























    r=[0,1];
    costh=cos(ang);
    sinth=sin(ang);
    S.costh=costh;
    S.sinth=sinth;

    x=r.*costh;
    y=r.*sinth;
    P=[x(1),y(1)];
    Q=[x(2),y(2)];



    PQ=Q-P;
    PQu=PQ/norm(PQ);
    ABu=[-PQu(2),PQu(1)];





    hrect=p.MagnitudeHitBoxNormHeight/2;
    A=P+hrect*ABu;
    B=P-hrect*ABu;
    C=B+PQ;
    D=A+PQ;


    xrect=[A(1),B(1),C(1),D(1)];
    yrect=[A(2),B(2),C(2),D(2)];
    S.hoverRect.x=xrect;
    S.hoverRect.y=yrect;


    p.pMagnitudeLabelCoords=S;
