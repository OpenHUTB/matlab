function[map,swapIdx,constraintRows,singularRows]=descriptor2map(mats,Jcx,Jcu,swapIdx,constraintRows,singularRows)







































    nxd=size(mats.J_m,1);
    ny=size(mats.J_y_xd,1);
    nu=size(mats.J_d_u,2);
    nxa=size(mats.J_a_xa,1);

    M=logical(mats.J_m);
    Jdd=logical(mats.J_d_xd);
    Jda=logical(mats.J_d_xa);
    Jdu=logical(mats.J_d_u);

    Jad=logical(mats.J_a_xd);
    Jaa=logical(mats.J_a_xa);
    Jau=logical(mats.J_a_u);

    Jcx=logical(Jcx);
    Jcu=logical(Jcu);

    Jyd=logical(mats.J_y_xd);
    Jya=logical(mats.J_y_xa);
    Jyu=logical(mats.J_y_u);


    if isempty(Jcx)||all(all(~Jcx))
        constraintRows=[];
    else
        if nargin<5
            constraintRows=any([Jcx,Jcu],2);
        end
    end

    if nargin<6


        singularRows=sum(Jaa,2)<1;
    end

    isc=any(singularRows);
    if isc

        jcx=Jcx(constraintRows,:);
        jcu=Jcu(constraintRows,:);
        Jad(singularRows,:)=jcx(:,1:nxd);
        Jaa(singularRows,:)=jcx(:,nxd+1:end);
        Jau(singularRows,:)=jcu;
    end

    Ix=logical(eye(nxd));
    Iu=logical(eye(nu));
    Iy=logical(eye(ny));

    A_hat1=[...
    M,Jdd,Jda,false(nxd,ny),Jdu;
    Ix,Ix,false(nxd,nxa),false(nxd,ny),false(nxd,nu);
    false(nxa,nxd),Jad,Jaa,false(nxa,ny),Jau;
    false(ny,nxd),Jyd,Jya,Iy,Jyu;
    false(nu,2*nxd+nxa+ny),Iu];

    if nargin<4
        swapIdx=LocalGetSwapIdx(A_hat1,nxd,nxa,ny,nu,isc);
    end
    A_hat3=A_hat1;
    A_hat3=A_hat3(swapIdx,:);


    A_hat3(logical(eye(size(A_hat3,1))))=false;
    map=A_hat3;

    function swapIdx=LocalGetSwapIdx(A,nxd,nxa,ny,nu,isc)


        if isc
            NX=2*nxd+nxa;
            A_=A(1:NX,1:NX);
            swapIdx=linearize.advisor.graph.swapEquations(A_);
        else






            Ad=A(1:nxd,1:nxd);
            Aa=A(2*nxd+1:2*nxd+nxa,2*nxd+1:2*nxd+nxa);
            swapd=linearize.advisor.graph.swapEquations(Ad);
            swapa=linearize.advisor.graph.swapEquations(Aa);
            swapIdx=[swapd,nxd+1:2*nxd,swapa+2*nxd];
        end
        swapIdx=[swapIdx,2*nxd+nxa+1:2*nxd+nxa+ny+nu];






