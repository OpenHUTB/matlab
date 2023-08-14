function[status,mLinJacobian,DirectFeedthrough,other]=helperDAElinearize_math(M,A,B,C,D)


















    status=0;
    DirectFeedthrough=1;
    other.Wad=sparse(0);
    other.Wau=sparse(0);
    other.Txw=sparse(0);
    other.Twx=sparse(0);

    if(size(B,1)==0&&size(B,2)==0)





        B=sparse(size(A,1),0);
    end

    if(size(C,1)==0&&size(C,2)==0)


        C=sparse(0,size(A,2));
    end

    [U,S,V]=svd(M);

    clear M

    U=sparse(U);
    S=sparse(S);
    V=sparse(V);

    n_d=nnz(diag(S)>1e-12);

    mLinJacobian=sparse(n_d+size(C,1),n_d+size(B,2));

    tMd=S(1:n_d,1:n_d);
    tA=U'*A*V;
    tB=U'*B;
    tC=C*V;
    tD=D;

    Jdd=tA(1:n_d,1:n_d);
    Jad=tA(n_d+1:end,1:n_d);
    Jda=tA(1:n_d,n_d+1:end);
    Jaa=tA(n_d+1:end,n_d+1:end);

    dfd_du=tB(1:n_d,:);
    dfa_du=tB(n_d+1:end,:);

    dy_dxd=tC(:,1:n_d);
    dy_dxa=tC(:,n_d+1:end);











    if nnz(tD)==0


        pCV2=logical(dy_dxa);
        pB2=logical(dfa_du);

        if nnz(pCV2)==0||nnz(pB2)==0

            DirectFeedthrough=0;
        else

            pInvA22=logical(Jaa);
            origin_p=pInvA22;


            for i=2:length(pInvA22)
                tp=pInvA22|(pInvA22*origin_p);
                if tp==pInvA22
                    break
                end
                pInvA22=tp;
            end

            CVAB=logical(pCV2*pInvA22*pB2);

            if nnz(CVAB)==0
                DirectFeedthrough=0;
            end
        end
    end


    if condest(Jaa)==Inf
        status=-1;
        return
    end




    dxa_dxd=-Jaa\Jad;
    dxa_du=-Jaa\dfa_du;

    Arhs=Jdd+Jda*dxa_dxd;
    Brhs=dfd_du+Jda*dxa_du;
    rA=tMd\Arhs;
    rB=tMd\Brhs;
    rC=dy_dxd+dy_dxa*dxa_dxd;
    rD=dy_dxa*dxa_du;
    if nnz(tD)>0
        rD=rD+tD;
    end

    mLinJacobian=[rA,rB;rC,rD];


    V=sparse(V);
    Vt=V';





    other.Wad=sparse(dxa_dxd);
    other.Wau=sparse(dxa_du);
    other.Txw=V;
    other.Twx=Vt;
