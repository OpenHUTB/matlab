function[Yo,Xo,tau,MVinf,YoDC]=rlgctable2yx(f,len,R,L,G,C,Linf,Cinf)
%# codegen



    nf=length(f);
    s=2i*pi*f;
    n=size(R,1);
    tau=zeros(n,1);
    gamma=complex(zeros(n,nf));
    Yo=complex(zeros(n,n,nf));
    if n==1

        R=R(:);
        L=L(:);
        G=G(:);
        C=C(:);
        Linf=Linf(1);
        Cinf=Cinf(1);
        Zc=R+s.*L;
        Yc=G+s.*C;

        Yotemp=sqrt(Yc./Zc);
        if~isfinite(Yotemp(1))
            Yotemp(1)=sqrt(C(1)/L(1));
        end

        gamma(1,1:nf)=sqrt(Yc.*Zc);
        MVinf=1;


        tau(1)=sqrt(Linf*Cinf)*len;

        temp1=s*tau(1);
        temp=temp1-len*gamma.';

        Xexp=exp(temp);

        Xo=reshape(Xexp,1,1,nf);
        Yo(1,1,1:nf)=reshape(Yotemp,1,1,nf);
        YoDC=real(Yo(1,1,1));
    else

        assert(n==size(R,2));
        s3dtemp=reshape(s,1,1,nf);
        s3d=repmat(s3dtemp,n,n,1);
        Zc=R+s3d.*L;
        Yc=G+s3d.*C;
        minusYZ=complex(zeros(n,n,nf));
        sqrtmYZ=complex(zeros(n,n,nf));

        for k=1:nf
            minusYZ(1:n,1:n,k)=-Yc(1:n,1:n,k)*Zc(1:n,1:n,k);
        end
        for k=1:nf
            if k==1
                sqrtk=sqrtm(-minusYZ(:,:,k));
            else
                sqrtk=1i*sqrtm(minusYZ(:,:,k));
            end
            sqrtmYZ(1:n,1:n,k)=sqrtk;
            Ytemp=sqrtk\Yc(1:n,1:n,k);
            Yo(1:n,1:n,k)=0.5*(Ytemp+Ytemp.');
        end
        if all(G(:)==0)
            if all(R(:)==0)
                YoDC=real(Yo(1:n,1:n,2));
            else
                YoDC=zeros(n);
            end
            Yo(1:n,1:n,1)=YoDC;
        else
            YoDC=real(Yo(1:n,1:n,1));
            if any(~isfinite(YoDC(:)))
                YoDC=real(Yo(1:n,1:n,2));
                Yo(1:n,1:n,1)=YoDC;
            end
        end




        Lsqrt=sqrtm(Linf);
        Lsqrt=real(Lsqrt);
        LCL=Lsqrt*Cinf*Lsqrt;
        LCL=0.5*(LCL+LCL.');
        [VLCL,dm]=eig(LCL);
        VLCL=real(VLCL);
        dm=real(dm);
        MVinf=Lsqrt\VLCL;
        for i=1:n
            MVinf(:,i)=MVinf(:,i)/norm(MVinf(:,i));
        end
        dG2inf=diag(dm);
        tau(1:n,1)=real(sqrt(dG2inf))*len;



        if 1==1
            [tau,tindex]=sort(tau);
            MVinf=MVinf(:,tindex);
        else
            tau=min(tau)*ones(size(tau));
            MVinf=eye(size(MVinf));
        end
        Hs=complex(zeros(size(Yo)));
        for k=1:nf
            Hs(:,:,k)=expm(-len*sqrtmYZ(:,:,k));
        end
        MHs=complex(zeros(size(Yo)));
        for k=1:nf
            MHs(:,:,k)=MVinf\(Hs(:,:,k)*MVinf);
        end
        Xo=complex(zeros(size(Yo)));
        for k=1:nf
            Xo(:,:,k)=diag(exp(s(k)*tau))*MHs(:,:,k);
        end
...
...
...
...
...
...
...
...

...
...
...
...
...
...
...
...
...
...
...
...
...
    end
