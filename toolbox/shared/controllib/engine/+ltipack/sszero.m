function[z,g]=sszero(a,b,c,d,e,Ts,varargin)





















    DCBA=[d,c;b,a];
    REAL=isreal(DCBA)&&isreal(e);
    DESCRIPTOR=~isempty(e);
    REFINE_GAIN=nargout>1&&~any(strcmpi(varargin,'norefine'));
    zerotol=eps^0.75;
    z=zeros(0,1);


    if isnan(d)
        g=NaN;
        return
    elseif all(DCBA(:,1)==0)||all(DCBA(1,:)==0)

        g=0;
        return
    end


    [DCBA,e,g]=sisozeroReduce(DCBA,e,zerotol);
    nz=size(DCBA,1)-1;


    if nz>0
        bnorm=norm(DCBA(2:nz+1,1));
        cnorm=norm(DCBA(1,2:nz+1));
        if bnorm>0&&cnorm>0
            [aa,ee]=localDeflateInf(DCBA,e,nz,bnorm,cnorm);
            z=eig(aa,ee);

            z=z(isfinite(z),:);


            if REFINE_GAIN
                ar=DCBA(2:nz+1,2:nz+1);
                dr=DCBA(1,1);
                if DESCRIPTOR
                    p=eig(ar,e);
                else
                    p=eig(ar);
                end
                fact=ltipack.adjustGain(ar,DCBA(2:nz+1,1),DCBA(1,2:nz+1),dr,e,Ts,z,p,dr);
                g=g*fact;
            end
        else

            z=ltipack.sspole(DCBA(2:nz+1,2:nz+1),e);
        end
    end

    if REAL
        g=real(g);
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