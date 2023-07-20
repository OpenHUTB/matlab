function[ar,br,cr,dr,er,SingularFlag]=elimAV(a,b,c,d,e,nx1,tol)
























    SingularFlag=false;
    nx=size(a,1);
    [ny,nu]=size(d);


    if nx1==0
        ar=[];br=zeros(0,nu);cr=zeros(ny,0);er=[];
        dr=d-c*ltipack.util.safeMdivide(a,b,[]);
        if hasInfNaN(dr)
            dr=NaN(ny,nu);SingularFlag=true;
        end
    else

        nxr=nx1;
        SCALE=norm(a,'fro');
        ar=a;br=b;cr=c;dr=d;

        while nxr<nx

            [svL,~,~,XL,~,SL]=ltipack.util.gsvd(...
            ar(nxr+1:nx,1:nxr)',ar(nxr+1:nx,nxr+1:nx)',SCALE);
            if any(isnan(svL))
                SingularFlag=true;nxr=nx;break
            end
            ixL=find(diag(SL)<tol);nzL=numel(ixL);nxL=nxr+nzL;
            if nzL>0&&nxL<nx
                [QL,~]=qr(XL(:,ixL));
                ar(nxr+1:nx,:)=QL'*ar(nxr+1:nx,:);
                br(nxr+1:nx,:)=QL'*br(nxr+1:nx,:);
            end

            [svR,~,~,XR,~,SR]=ltipack.util.gsvd(...
            ar(1:nxr,nxr+1:nx),ar(nxr+1:nx,nxr+1:nx),SCALE);
            if any(isnan(svR))
                SingularFlag=true;nxr=nx;break
            end
            ixR=find(diag(SR)<tol);nzR=numel(ixR);nxR=nxr+nzR;
            if nzR>0&&nxR<nx
                [QR,~]=qr(XR(:,ixR));
                ar(:,nxr+1:nx)=ar(:,nxr+1:nx)*QR;
                cr(:,nxr+1:nx)=cr(:,nxr+1:nx)*QR;
            end

            dn=nzL-nzR;
            if dn<0&&nxR<nx

                [Q,~]=qr(ar(nxL+1:nx,nxR+1:nx));
                Q=Q(:,[1-dn:nx-nxL,1:-dn]);
                ar(nxL+1:nx,:)=Q'*ar(nxL+1:nx,:);
                br(nxL+1:nx,:)=Q'*br(nxL+1:nx,:);
            elseif dn>0&&nxL<nx

                [Q,~]=qr(ar(nxL+1:nx,nxR+1:nx)');
                Q=Q(:,[1+dn:nx-nxR,1:dn]);
                ar(:,nxR+1:nx)=ar(:,nxR+1:nx)*Q;
                cr(:,nxR+1:nx)=cr(:,nxR+1:nx)*Q;
            end

            if nzL==0&&nzR==0
                break
            end
            nxr=max(nxL,nxR);
        end



























        if nxr<nx

            abcd=[ar,br;cr,dr];
            abcd=localSchurComplement(abcd,nxr,nx-nxr);
            ar=abcd(1:nxr,1:nxr);
            br=abcd(1:nxr,nxr+1:nxr+nu);
            cr=abcd(nxr+1:nxr+ny,1:nxr);
            dr=abcd(nxr+1:nxr+ny,nxr+1:nxr+nu);
        else

            ar=a;br=b;cr=c;dr=d;
        end


        if isempty(e)
            if nxr==nx1
                er=[];
            else
                er=diag([ones(nx1,1);zeros(nxr-nx1,1)]);
            end
        else
            er=e(1:nxr,1:nxr);
        end
    end


    function Mr=localSchurComplement(M,k0,n)

        [nr,nc]=size(M);
        ikeep=1:nr;ikeep(k0+1:k0+n)=[];
        jkeep=1:nc;jkeep(k0+1:k0+n)=[];
        Mr=M(ikeep,jkeep)-...
        M(ikeep,k0+1:k0+n)*(M(k0+1:k0+n,k0+1:k0+n)\M(k0+1:k0+n,jkeep));
