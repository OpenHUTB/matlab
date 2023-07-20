function[z,p,k]=iodynamics(D,~)








    if~isempty(D.Delay.Internal)
        D=pade(D,inf,inf,0);
    end
    Ts=D.Ts;




    FLAGS=false(1,2);


    [a,b,c,d,~,e]=getABCDE(D);
    [ny,nu]=size(d);
    if hasInfNaN(d)
        z=repmat({zeros(0,1)},[ny,nu]);p=z;k=NaN(ny,nu);return
    end


    if D.Scaled
        WarnID='';
    else
        [a,b,c,e,~,~,info]=xscale(a,b,c,d,e,Ts,'Warn',false);
        WarnID=info.WarnID;
    end


    z=cell(ny,nu);
    p=cell(ny,nu);
    k=zeros(ny,nu);
    if ny==1&&nu==1

        [a,b,c,e]=smreal(a,b,c,e);
        [a,b,c,e,rkE]=minreal_inf(a,b,c,e);
        if rkE<size(a,1)

            [z{1},p{1},k(1)]=zpk_minreal_inf(a,b,c,d,e,Ts);
            FLAGS(1)=FLAGS(1)||~isfinite(k(1));
        else
            [z{1},k(1)]=ltipack.sszero(a,b,c,d,e,Ts);
            p{1}=ltipack.sspole(a,e);
            FLAGS(2)=FLAGS(2)||~isfinite(k(1));
        end
    else

        nx=size(a,1);
        [xkeep,ekeep]=iosmreal(a,b,c,e);

        FullPoles=zeros(0,1);
        for j=1:nu
            for i=1:ny

                dij=d(i,j);
                jx=find(xkeep(:,i,j));
                if isempty(e)
                    aij=a(jx,jx);bj=b(jx,j);ci=c(i,jx);eij=[];rkE=length(jx);
                else
                    ie=find(ekeep(:,i,j));
                    [aij,bj,ci,eij,rkE]=minreal_inf(a(ie,jx),b(ie,j),c(i,jx),e(ie,jx));
                end

                nxij=size(aij,1);
                if rkE<nxij
                    [z{i,j},p{i,j},k(i,j)]=zpk_minreal_inf(aij,bj,ci,dij,eij,Ts);
                    FLAGS(1)=FLAGS(1)||~isfinite(k(i,j));
                else

                    [z{i,j},k(i,j)]=ltipack.sszero(aij,bj,ci,dij,eij,Ts);
                    FLAGS(2)=FLAGS(2)||~isfinite(k(i,j));
                    if nxij<nx
                        p{i,j}=ltipack.sspole(aij,eij);
                    else
                        if isempty(FullPoles)&&nx>0
                            FullPoles=ltipack.sspole(aij,eij);
                        end
                        p{i,j}=FullPoles;
                    end
                end

                if k(i,j)==0
                    p{i,j}=zeros(0,1);z{i,j}=zeros(0,1);
                end
            end
        end
    end


    if nargin<2
        if FLAGS(1)
            warning(message('Control:ltiobject:SingularDescriptor'))
        elseif FLAGS(2)
            warning(message('Control:analysis:zero5'))
        elseif~isempty(WarnID)

            warning(message(WarnID))
        end
    end
