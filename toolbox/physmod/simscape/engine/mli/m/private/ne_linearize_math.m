function[status,ABCD,c_err_id,c_err_msg]=ne_linearize_math(ld)






























    n=ld.n;
    n_d=ld.n_d;
    n_u=ld.n_u;
    n_o=ld.n_o;
    h_c=ld.h_c;
    Mpattern=ld.Mpattern;
    M=ld.M;
    J=ld.J;
    dfdu=ld.dfdu;


    dydx=ld.dydx;
    dydu=ld.dydu;


    dMdx=ld.dMdx;
    dMdu=ld.dMdu;
    fval=ld.fval;
    if ld.h_c
        dcdx=ld.dcdx;
        dcdu=ld.dcdu;
    end

    pm_assert(~any(any(Mpattern(:,n_d+1:n))),'Mass matrix should have nonzero coefficients for differential variables only.');
    Md=M(1:n_d,1:n_d);
    Md_pattern=Mpattern(1:n_d,1:n_d);
    Md_restriction_pattern=logical(sparse(size(Mpattern,1),size(Mpattern,2)));
    Md_restriction_pattern(1:n_d,1:n_d)=Md_pattern;

    if h_c

        mwhole_nz=find(Mpattern);
        md_nz=find(Md_restriction_pattern);
        is_in_md=ismember(mwhole_nz,md_nz);
        dMd_dx=dMdx(is_in_md,:);
        dMd_du=dMdu(is_in_md,:);
    else
        dMd_dx=dMdx;
        dMd_du=dMdu;
    end
    clear dMdx;
    clear dMdu;

    statedepM=(nnz(dMd_dx)>0)||(nnz(dMd_du)>0);








    Jdd=J(1:n_d,1:n_d);
    Jad=J(n_d+1:end,1:n_d);
    Jda=J(1:n_d,n_d+1:end);
    Jaa=J(n_d+1:end,n_d+1:end);


    dfd_du=dfdu(1:n_d,:);
    dfa_du=dfdu(n_d+1:end,:);

    dy_dxd=dydx(:,1:n_d);
    dy_dxa=dydx(:,n_d+1:end);

    if statedepM
        xd_dot=Md\fval(1:n_d);
        dMd_dxd=dMd_dx(:,1:n_d);
        dMd_dxa=dMd_dx(:,n_d+1:end);






        mat_xd_dot=sparse(size(Md_pattern,1),nnz(Md_pattern));
        Md_pattern_helper=double(Md_pattern);
        Md_pattern_helper(Md_pattern)=1:nnz(Md_pattern);



        for i=1:size(mat_xd_dot,1)
            mat_xd_dot(i,Md_pattern_helper(i,Md_pattern(i,:)))=xd_dot(Md_pattern(i,:));
        end
    end




    [lastWarnMsg,lastWarnId]=lastwarn;
    lastwarn('');

    smw=warning('off','MATLAB:singularMatrix');
    nsmw=warning('off','MATLAB:nearlySingularMatrix');

    if~h_c

        dxa_dxd=-Jaa\Jad;
        dxa_du=-Jaa\dfa_du;

        Arhs=Jdd+Jda*dxa_dxd;
        Brhs=dfd_du+Jda*dxa_du;
        if statedepM

            dMwhole_dxd=dMd_dxd+dMd_dxa*dxa_dxd;
            dMwhole_du=dMd_du+dMd_dxa*dxa_du;

            Mstatedep_A_correction=mat_xd_dot*dMwhole_dxd;
            Mstatedep_B_correction=mat_xd_dot*dMwhole_du;
            Arhs=Arhs-Mstatedep_A_correction;
            Brhs=Brhs-Mstatedep_B_correction;
        end

        A=Md\Arhs;
        B=Md\Brhs;
        C=dy_dxd+dy_dxa*dxa_dxd;
        D=dydu+dy_dxa*dxa_du;
    else










        nz_dc_inds=any(dcdx');
        dcdx=dcdx(nz_dc_inds,:);
        dcdu=dcdu(nz_dc_inds,:);

        dc_dxd=dcdx(:,1:n_d);
        [hdep,trueind]=ne_findindrows(dc_dxd',[1:n_d]);
        n_hdep=length(hdep);
        n_trueind=length(trueind);



        if length(hdep)~=size(dc_dxd,1)
            trueind=1:(n_d-size(dc_dxd,1));
            hdep=(n_d-size(dc_dxd,1)+1):n_d;
        end

        dc_dxh=dc_dxd(:,hdep);
        dc_dxi=dc_dxd(:,trueind);
        dxd_dxi=sparse(n_d,n_trueind);

        dxd_dxi(hdep,:)=-dc_dxh\dc_dxi;
        dxh_du=-dc_dxh\dcdu;

        dxd_dxi(trueind,:)=speye(n_trueind);








        G=sparse(n,n);
        G(:,1:n_d)=M(:,1:n_d);
        G(1:n_d,n_d+1:n)=-Jda;
        if statedepM
            G(1:n_d,n_d+1:n)=G(1:n_d,n_d+1:n)+mat_xd_dot*dMd_dxa;
        end
        G(n_d+1:n,n_d+1:n)=-Jaa;

        rhs=sparse(n,n_d+n_u);
        rhs(1:n_d,1:n_d)=Jdd;
        if statedepM
            rhs(1:n_d,1:n_d)=rhs(1:n_d,1:n_d)-mat_xd_dot*dMd_dxd;
        end
        rhs(n_d+1:n,1:n_d)=Jad;
        rhs(1:n_d,n_d+1:n_d+n_u)=dfd_du;
        if statedepM
            rhs(1:n_d,n_d+1:n_d+n_u)=rhs(1:n_d,n_d+1:n_d+n_u)-mat_xd_dot*dMd_du;
        end
        rhs(n_d+1:n,n_d+1:n_d+n_u)=dfa_du;

        dxddotxa_dxdu=G\rhs;
        dxddot_dxd=dxddotxa_dxdu(1:n_d,1:n_d);
        dxa_dxd=dxddotxa_dxdu(n_d+1:n,1:n_d);
        dxddot_du=dxddotxa_dxdu(1:n_d,n_d+1:n_d+n_u);
        dxa_du=dxddotxa_dxdu(n_d+1:n,n_d+1:n_d+n_u);



        dy_du1=dydu+dy_dxa*dxa_du;

        dy_dxd1=dy_dxd+dy_dxa*dxa_dxd;

        A=sparse(n_d,n_d);
        B=sparse(n_d,n_u);
        C=sparse(n_o,n_d);
        D=sparse(n_o,n_u);








        A(trueind,trueind)=dxddot_dxd(trueind,:)*dxd_dxi;
        B(trueind,:)=dxddot_du(trueind,:)+dxddot_dxd(trueind,hdep)*dxh_du;
        C(:,trueind)=dy_dxd1*dxd_dxi;

        D=dy_du1+dy_dxd1(:,hdep)*dxh_du;
    end


    [dummy,ourWarnId]=lastwarn;
    c_err_msg='';
    if strcmp(ourWarnId,'MATLAB:singularMatrix')||strcmp(ourWarnId,'MATLAB:nearlySingularMatrix')
        c_err_id='network_engine:ne_linearize:NearSingular';
        status=1;
    else
        c_err_id='';
        status=0;
    end


























    [indrows,deprows,T]=ne_findindrows([A,B],1:n_d);
    xd_from_xd_ind=sparse(n_d,n_d);
    xd_from_xd_ind(indrows,indrows)=speye(length(indrows));
    xd_from_xd_ind(deprows,indrows)=-T(:,indrows);
    A=A*xd_from_xd_ind;
    C=C*xd_from_xd_ind;
    ABCD=[A,B;C,D];


    ABCD(deprows,:)=0;






    ABCD=[full(ABCD),zeros(n_d+n_o,n_u)];

    lastwarn(lastWarnMsg,lastWarnId);
    warning(smw);
    warning(nsmw);
