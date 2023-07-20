function[Lx,Ly,Rx,Ry,hideLx,hideLy,hideRx,hideRy]=NWindingsTransformerIcon







    basex=[0,2,42,74,94,100,90,66,30,0,2,42,74,94,100,90,66,30,0,2,42,74,94,100,90,66,30,0];
    basey=[0,0,3,8,17,27,36,44,49,50,50,53,58,67,77,86,94,99,100,[0,3,8,17,27,36,44,49,50]+100];


    intx=[basex,basex];
    inty=[basey,basey+100];

    decalageX=150;
    decalageLy=100;
    Lx=basex-decalageX;
    Ly=basey-decalageLy;

    hideLx=[];
    hideLy=[];


    basey=basey*50/100;
    basex=(-basex)+decalageX;
    Rx=[basex,basex,basex];
    espacement=145;
    decalageRy=180;
    Ry=[basey,basey+espacement,basey+2*espacement]-decalageRy;

    hideRx=[decalageX,decalageX];
    hideRy=[-decalageRy,-decalageRy+2*espacement];
