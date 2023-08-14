function generateLHSMfie(obj,I)




    geom=obj.Geom;
    srcinfo.nd=3;
    targ=geom.RWGCenter';
    zk=norm(obj.Wavenumber);
    prec=obj.Precision;
    pg=0;
    pgt=1;


    nsource=geom.FacesTotal;
    srcinfo.sources=geom.CenterF';
    select=I(geom.BFnumber);
    J(:,1)=2*sum(geom.BFrhox.*select,2);
    J(:,2)=2*sum(geom.BFrhoy.*select,2);
    J(:,3)=2*sum(geom.BFrhoz.*select,2);


    temp1(:,1)=zeros(nsource,1);
    temp1(:,2)=-J(:,3);
    temp1(:,3)=+J(:,2);

    temp2(:,1)=+J(:,3);
    temp2(:,2)=+zeros(nsource,1);
    temp2(:,3)=-J(:,1);

    temp3(:,1)=-J(:,2);
    temp3(:,2)=+J(:,1);
    temp3(:,3)=+zeros(nsource,1);
    srcinfo.dipoles(1,:,:)=conj(temp1.');
    srcinfo.dipoles(2,:,:)=conj(temp2.');
    srcinfo.dipoles(3,:,:)=conj(temp3.');
    U=em.solvers.FMMSolver.hfmm3d(prec,zk,srcinfo,pg,targ,pgt);
    Int=conj(U.pottarg.');
    LHS=I.*geom.AngleCorrection-1/(4*pi)*sum(Int.*geom.RWGevector,2);

    obj.LHSMfie=LHS;
end

