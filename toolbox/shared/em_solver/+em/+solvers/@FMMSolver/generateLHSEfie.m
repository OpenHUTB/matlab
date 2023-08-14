function generateLHSEfie(obj,I)



    geom=obj.Geom;
    srcinfo.nd=4;
    srcinfo.sources=geom.CenterF';
    zk=norm(obj.Wavenumber);
    prec=obj.Precision;
    pg=1;
    pgt=0;
    omega=obj.c0*obj.Wavenumber;
    IS=geom.IS'-1j*obj.Wavenumber;


    select=I(geom.BFnumber);
    rhoA=(1j/omega)*sum(geom.BFcharge.*select,2).';
    JxA=sum(geom.BFrhox.*select,2).';
    JyA=sum(geom.BFrhoy.*select,2).';
    JzA=sum(geom.BFrhoz.*select,2).';



    srcinfo.charges(1,:)=conj(JxA);
    srcinfo.charges(2,:)=conj(JyA);
    srcinfo.charges(3,:)=conj(JzA);
    srcinfo.charges(4,:)=conj(rhoA);

    U=em.solvers.FMMSolver.hfmm3d(prec,zk,srcinfo,pg);

    Phi=(1/(4*pi*obj.epsilon0))*(conj(U.pot(4,:))+rhoA.*IS).';
    Ax=(obj.mu0/(4*pi))*(conj(U.pot(1,:))+JxA.*IS).';
    Ay=(obj.mu0/(4*pi))*(conj(U.pot(2,:))+JyA.*IS).';
    Az=(obj.mu0/(4*pi))*(conj(U.pot(3,:))+JzA.*IS).';




    LHS=-1j*omega*(geom.FCRhoP(:,1).*Ax(geom.TriP)+geom.FCRhoP(:,2).*Ay(geom.TriP)+geom.FCRhoP(:,3).*Az(geom.TriP)+...
    geom.FCRhoM(:,1).*Ax(geom.TriM)+geom.FCRhoM(:,2).*Ay(geom.TriM)+geom.FCRhoM(:,3).*Az(geom.TriM))/2+...
    Phi(geom.TriP)-Phi(geom.TriM);
    LHS=-LHS./geom.EdgeLength;
    obj.LHSEfie=LHS;
end

