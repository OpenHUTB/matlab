function[z,g]=sszeroCG(a,b,c,d,e)
















%#codegen
    coder.allowpcode('plain');
    MATLAB=coder.target('MATLAB');


    nx=size(a,1);
    DCBA=[d,c;b,a];
    REAL=isreal(DCBA)&&isreal(e);
    DESCRIPTOR=~isempty(e);
    ONE=cast(1,'like',DCBA);
    zerotol=eps(ONE)^0.75;

    if MATLAB
        z=zeros(0,1,'like',ONE);
    else

        z=inf(nx,1,'like',ONE)+0i;
    end


    if isnan(d)
        g=cast(NaN,'like',ONE);
        return
    elseif all(DCBA(:,1)==0)||all(DCBA(1,:)==0)

        g=cast(0,'like',ONE);
        return
    end

    if MATLAB


        g=ONE;
        nz=nx;
        if abs(d)*(1+max(abs(a),[],'all'))<=zerotol*norm(b)*norm(c)
            if DESCRIPTOR

                [q,e]=qr(e);
                DCBA(2:nx+1,:)=q'*DCBA(2:nx+1,:);
            end
            for ct=1:nx
                [DCBA,e,g]=localDeflate(DCBA,e,g,nz,nz);

                DCBA=DCBA([1,3:nz+1],2:nz+1);
                if DESCRIPTOR
                    e=e(2:nz,2:nz);
                end
                nz=nz-1;

                if all(DCBA(:,1)==0)||all(DCBA(1,:)==0)
                    nz=0;break
                elseif abs(DCBA(1,1))*(1+max(abs(DCBA(2:nz+1,2:nz+1)),[],'all'))>...
                    zerotol*norm(DCBA(2:nz+1,1))*norm(DCBA(1,2:nz+1))
                    break
                end
            end
        end
        g=g*DCBA(1,1);


        if nz>0
            bnorm=norm(DCBA(2:nz+1,1));
            cnorm=norm(DCBA(1,2:nz+1));
            if bnorm>0&&cnorm>0
                [aa,ee]=localDeflateInf(DCBA,e,nz,bnorm,cnorm);
                z=eig(aa,ee);

                z=z(isfinite(z),:);
            else

                z=ltipack.sspole(DCBA(2:nz+1,2:nz+1),e);
            end
        end

    else



        g=ONE+0i;
        nz=nx;
        if abs(d)*(1+max(abs(a),[],'all'))<=zerotol*norm(b)*norm(c)
            if DESCRIPTOR

                [q,e]=qr(e);
                DCBA(2:nx+1,:)=q'*DCBA(2:nx+1,:);
            end
            for ct=1:nx
                [DCBA,e,g]=localDeflate(DCBA,e,g,nx,nz);

                for j=1:nz
                    DCBA(1,j)=DCBA(1,j+1);
                    for i=2:nz
                        DCBA(i,j)=DCBA(i+1,j+1);
                    end
                end
                for k=1:nz+1
                    DCBA(k,nz+1)=0;DCBA(nz+1,k)=0;
                end
                if DESCRIPTOR
                    for j=1:nz-1
                        for i=1:nz-1
                            e(i,j)=e(i+1,j+1);
                        end
                    end
                    for k=1:nz
                        e(k,nz)=0;e(nz,k)=0;
                    end
                end
                nz=nz-1;

                if all(DCBA(:,1)==0)||all(DCBA(1,:)==0)
                    nz=0;break
                elseif abs(DCBA(1,1))*(1+max(abs(DCBA(2:nx+1,2:nx+1)),[],'all'))>...
                    zerotol*norm(DCBA(2:nx+1,1))*norm(DCBA(1,2:nx+1))
                    break
                end
            end
        end


        assert(nz<=nx)
        g=g*DCBA(1,1);
        if nz>0
            bnorm=norm(DCBA(2:nx+1,1));
            cnorm=norm(DCBA(1,2:nx+1));
            if bnorm>0&&cnorm>0
                [aa,ee]=localDeflateInf(DCBA,e,nx,bnorm,cnorm);
            else
                aa=DCBA(2:nx+1,2:nx+1);
                if DESCRIPTOR
                    ee=e;
                else
                    ee=eye(nx,'like',aa);
                end
            end

            for k=nz+1:nx
                aa(k,k)=1;ee(k,k)=0;
            end
            z(1:nx,1)=eig(aa,ee);
        end
    end

    if REAL
        g=real(g);
    end



    function[DCBA,e,g]=localDeflate(DCBA,e,g,n,nz)


        if isempty(e)






            if DCBA(2,1)==0

                [~,imax]=max(abs(DCBA(2:n+1,1)));
                imax=imax+1;
                DCBA([2,imax],:)=DCBA([imax,2],:);
                DCBA(:,[2,imax])=DCBA(:,[imax,2]);
            end


            [v,w,tau]=ltipack.householder(DCBA(2:n+1,1));
            g=g*(-tau);
            DCBA(2:n+1,:)=DCBA(2:n+1,:)-v*(w'*DCBA(2:n+1,:));
            DCBA(:,2:n+1)=DCBA(:,2:n+1)-(DCBA(:,2:n+1)*v)*w';
        else
            [DCBA,e]=localGivens(DCBA,e,nz);
            g=g*DCBA(2,1)/e(1,1);
        end


        function[aa,ee]=localDeflateInf(DCBA,e,n,bnorm,cnorm)


            s=sqrt(cnorm/bnorm);
            bcnorm=sqrt(bnorm*cnorm);
            alpha=min((1+norm(DCBA(2:n+1,2:n+1),'fro'))/bcnorm,bcnorm/abs(DCBA(1,1)));
            DCBA(:,1)=(alpha*s)*DCBA(:,1);
            DCBA(1,:)=(alpha/s)*DCBA(1,:);


            [v,w]=ltipack.householder(DCBA(:,1));
            aux=DCBA-v*(w'*DCBA);
            aa=aux(2:n+1,2:n+1);
            if isempty(e)
                ee=eye(n,'like',DCBA)-v(2:n+1,:)*w(2:n+1,:)';
            else
                ee=e-v(2:n+1,:)*(w(2:n+1,:)'*e);
            end


            function[DCBA,e]=localGivens(DCBA,e,nz)

                for ct=nz:-1:2

                    b1=DCBA(ct,1);b2=DCBA(ct+1,1);
                    if b2~=0
                        r=norm([b1,b2]);b1=b1/r;b2=b2/r;

                        G=[conj(b1),conj(b2);-b2,b1];
                        DCBA([ct,ct+1],:)=G*DCBA([ct,ct+1],:);
                        e([ct-1,ct],:)=G*e([ct-1,ct],:);

                        e1=e(ct,ct);e2=e(ct,ct-1);
                        r=norm([e1,e2]);e1=e1/r;e2=e2/r;
                        G=[conj(e1),-e2;conj(e2),e1];
                        DCBA(:,[ct+1,ct])=DCBA(:,[ct+1,ct])*G;
                        e(:,[ct,ct-1])=e(:,[ct,ct-1])*G;
                        e(ct,ct-1)=0;
                    end
                end
