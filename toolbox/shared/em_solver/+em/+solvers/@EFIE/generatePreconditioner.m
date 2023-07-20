function generatePreconditioner(obj)


    geom=obj.Geom;
    NumRWG=obj.NumRWG;
    omega=obj.c0*obj.Wavenumber;
    C1=+1/(4*pi*1i*omega*obj.epsilon0);
    C2=1i*omega*obj.mu0/(16*pi);
    signum=[1,-1,-1,1];
    signumAll=repmat(signum,NumRWG,1);

    i=zeros(geom.EdgesTotal*NumRWG,1);
    j=zeros(geom.EdgesTotal*NumRWG,1);
    v=zeros(geom.EdgesTotal*NumRWG,1);

    for m=1:geom.EdgesTotal
        for mm=1:NumRWG
            n=geom.Neighbors(m,mm);
            k=mm+(m-1)*NumRWG;
            i(k)=m;
            j(k)=n;
        end
    end

    for m=1:geom.EdgesTotal
        Tri1=[geom.TriP(m),geom.TriP(m),geom.TriM(m),geom.TriM(m)];
        Center1=geom.CenterF(Tri1,:);
        Pm=geom.FCRhoP(m,:)';
        Mm=geom.FCRhoM(m,:)';
        nAll=geom.Neighbors(m,:);
        PnAll=geom.FCRhoP(nAll,:);
        MnAll=geom.FCRhoM(nAll,:);
        Tri2All=[geom.TriP(nAll),geom.TriM(nAll),geom.TriP(nAll),geom.TriM(nAll)];
        Center2All=geom.CenterF(Tri2All,:);
        Center2All=reshape(Center2All,[size(Tri2All,1),size(Tri2All,2),3]);
        Center2All=permute(Center2All,[2,3,1]);
        Center1All=repmat(Center1,1,1,NumRWG);
        CenterDiffAll=Center1All-Center2All;
        vnorm=vecnorm(CenterDiffAll,2,2);
        vnorm=squeeze(vnorm);
        EXPpmm=exp(-1i*obj.Wavenumber*vnorm);
        chargeContribAll=1./vnorm.';
        for p=1:4
            tri1=Tri1(p);
            chargeContribAll(Tri2All(:,p)==tri1,p)=geom.IS(tri1)-1i*obj.Wavenumber;
        end
        rhorhoAll(:,1)=PnAll*Pm;
        rhorhoAll(:,2)=MnAll*Pm;
        rhorhoAll(:,3)=PnAll*Mm;
        rhorhoAll(:,4)=MnAll*Mm;
        currentContribAll=rhorhoAll.*chargeContribAll;
        xAll=C1*signumAll.*chargeContribAll+C2*currentContribAll;
        SUMALL=sum(xAll.*EXPpmm.',2);
        yy=(geom.EdgeLength(nAll).*SUMALL)/geom.EdgeLength(m);
        v((1:NumRWG)+(m-1)*NumRWG)=yy;
    end
    ZP=sparse(i,j,v);


    precon_type='lu';

    if strcmpi(precon_type,'lu')
        [L,U,P,Q,D]=lu(ZP);
    elseif strcmpi(precon_type,'ilu0')

        options.type='nofill';
        [L,U,P]=ilu(ZP,options);
        Q=[];
        D=[];
    else
        options.type='ilutp';
        options.droptol=1e-3;
        [L,U,P]=ilu(ZP,options);
        Q=[];
        D=[];
    end
















    obj.Preconditioner={L,U,P,Q,D};



end









