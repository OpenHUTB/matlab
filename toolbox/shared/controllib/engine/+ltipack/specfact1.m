function[aG,bG,cG,dG,eG,S]=specfact1(aH,bH,cH,dH,eH,Ts)













    DescFlag=(~isempty(eH));
    RealFlag=isreal(aH)&&isreal(bH)&&isreal(cH)&&isreal(dH)&&isreal(eH);
    hw=ctrlMsgUtils.SuspendWarnings;%#ok<NASGU>

    [ny,nxH]=size(cH);
    dG=eye(ny);
    eG=[];
    if nxH>0

        if DescFlag

            if Ts~=0
                H1=dH+cH*((eH-aH)\bH);
            end
            if RealFlag
                [aH,eH,q,z]=qz(aH,eH,'real');
            else
                [aH,eH,q,z]=qz(aH,eH,'complex');
            end
            ev=ordeig(aH,eH);
            if Ts==0
                if~all(isfinite(ev))

                    error(message('Control:transformation:SpectralFact2'))
                end
                nx=sum(real(ev)<0);
                if nx~=nxH/2
                    error(message('Control:transformation:SpectralFact6C'))
                end
                [aH,eH,q,z]=ordqz(aH,eH,q,z,'lhp');
            else
                nx=sum(abs(ev)<1);
                if nx>nxH/2
                    error(message('Control:transformation:SpectralFact6D'))
                end
                [aH,eH,q,z]=ordqz(aH,eH,q,z,'udi');
            end
            bH=q*bH;
            cH=cH*z;


            a=aH(1:nx,1:nx);e=eH(1:nx,1:nx);
            [~,L]=matlab.internal.math.coupled_sylvester_tri(a,aH(nx+1:nxH,nx+1:nxH),aH(1:nx,nx+1:nxH),...
            e,eH(nx+1:nxH,nx+1:nxH),eH(1:nx,nx+1:nxH));
            b=bH(1:nx,:)-L*bH(nx+1:nxH,:);
            c=cH(:,1:nx);
        else

            if Ts~=0
                H1=dH+cH*((eye(nxH)-aH)\bH);
            end
            [u,aH]=schur(aH);
            ev=ordeig(aH);
            if Ts==0
                nx=sum(real(ev)<0);
                if nx~=nxH/2
                    error(message('Control:transformation:SpectralFact6C'))
                end
                [u,aH]=ordschur(u,aH,'lhp');
            else
                nx=sum(abs(ev)<1);
                if nx>nxH/2
                    error(message('Control:transformation:SpectralFact6D'))
                end
                [u,aH]=ordschur(u,aH,'udi');
            end
            bH=u'*bH;
            cH=cH*u;


            a=aH(1:nx,1:nx);
            T=matlab.internal.math.sylvester_tri(a,-aH(nx+1:nxH,nx+1:nxH),aH(1:nx,nx+1:nxH),'I','I','notransp');
            b=bH(1:nx,:)+T*bH(nx+1:nxH,:);
            c=cH(:,1:nx);
            e=eye(nx);
        end




        if Ts==0
            d=dH;
            if norm(d-d',1)>sqrt(eps)*norm(d,1)
                error(message('Control:transformation:SpectralFact4'))
            end
            d=(d+d')/2;
        else
            if norm(H1-H1',1)>1e-4*norm(H1,1)
                error(message('Control:transformation:SpectralFact4'))
            end
            H1=(H1+H1')/2;
            aux=c*((e-a)\b);
            d=H1-(aux+aux');
        end


        if Ts==0
            [X,K,~,INFO]=icare(a,b,0,-d,-c',e);
            if INFO.Report==3
                error(message('Control:transformation:SpectralFact7C'))
            end
        else
            [X,K,~,INFO]=idare(a,b,0,-d,-c',e);
            if INFO.Report==3
                error(message('Control:transformation:SpectralFact7D'))
            end
        end
        if INFO.Report==2

            error(message('Control:transformation:SpectralFact8'))
        end


        if Ts==0
            S=d;
        else
            S=d-b'*X*b;
            S=(S+S')/2;
        end


        aG=a;
        bG=b;
        cG=K;
        dG=eye(ny);
        if DescFlag
            eG=e;
        end
    else

        S=dH;
        aG=[];
        bG=zeros(0,ny);
        cG=zeros(ny,0);
    end