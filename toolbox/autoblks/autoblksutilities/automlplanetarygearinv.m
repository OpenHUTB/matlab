function[y,xdot]=automlplanetarygearinv(u,x,Nsp,Nsr,rp,Ksc,Kcr,Jp,bs,br,bp,bc,bcr,bsc)


%#codegen
    coder.allowpcode('plain')


    rs=Nsp.*rp;
    rr=Nsp./Nsr.*rp;

    Leinv=[Ksc,0,0;...
    0,1/Jp,0;...
    0,0,Kcr];

    Ae=[0,rp,0;...
    -rp,-rp.^2.*bsc-bp-rp.^2.*bcr,-rp;...
    0,rp,0];

    Be=[rs,-rs,0;...
    -rs.*bsc.*rp,rs.*bsc.*rp-rr.*bcr.*rp,rr.*bcr.*rp;...
    0,rr,-rr];

    C=[rs,rs.*bsc.*rp,0;...
    -rs,-rs.*bsc.*rp+rr.*bcr.*rp,rr;...
    0,-rr.*bcr.*rp,-rr];

    D=[bs+rs.^2.*bsc,-rs.^2.*bsc,0;...
    -rs.^2.*bsc,bc+rs.^2.*bsc+rr.^2.*bcr,-rr.^2.*bcr;...
    0,-rr.^2.*bcr,br+rr.^2.*bcr];


    A=Leinv*Ae;
    B=Leinv*Be;


    xdot=A*x+B*u;
    y=C*x+D*u;

end