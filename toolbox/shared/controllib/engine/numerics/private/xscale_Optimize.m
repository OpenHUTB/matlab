function[sl,sr]=xscale_Optimize(SYSDATA,CommonAE)




    Ts=SYSDATA(1).Ts;

    if CommonAE

        Pa=abs(SYSDATA(1).a);
        Pe=abs(SYSDATA(1).e);
        nx=size(Pa,1);
        ne=size(Pe,1);
        Qa=zeros(nx);Qe=zeros(ne);
        R1=zeros(nx);R2=zeros(nx);

        for k=1:numel(SYSDATA)

            w=SYSDATA(k).w;
            h=SYSDATA(k).h;
            beta=SYSDATA(k).beta;
            gamma=SYSDATA(k).gamma;
            [ny,nu,nf]=size(h);
            if nf<2
                continue
            end
            dw=[w(2:nf);w(nf)]-[w(1);w(1:nf-1)];


            if ny==1&&nu==1
                hmag=abs(h(:));
            else
                hmag=zeros(nf,1);
                for ct=1:nf
                    hmag(ct)=norm(h(:,:,ct),'fro');
                end
            end
            Eh=sum(dw.*hmag.^2);

            if Eh>0

                hmag=(SYSDATA(k).Weight/Eh)*hmag;

                BetaS=zeros(nx,1);GammaS=zeros(1,nx);
                for ct=1:nf
                    tau=dw(ct)*hmag(ct);
                    bw=tau*sum(beta(:,:,ct),2);
                    gw=sum(gamma(:,:,ct),1);
                    BetaS=BetaS+bw;
                    GammaS=GammaS+tau*gw;
                    aux=bw*gw;
                    Qa=Qa+aux;
                    if Ts==0&&ne>0
                        Qe=Qe+w(ct)*aux;
                    end
                end
                R1=R1+sum(abs(SYSDATA(k).b),2)*GammaS;
                R2=R2+BetaS*sum(abs(SYSDATA(k).c),1);
            end
        end



        if ne==0

            sr=quadgp1(Pa,Qa,R1+R2);
            sl=1./sr;
        elseif Ts==0

            [sl,sr]=quadgp2(Pa,Qa,Pe,Qe,R1,R2);
        else

            Pa=Pa+Pe;
            [sl,sr]=quadgp2(Pa,Qa,[],[],R1,R2);
        end

    else

        error('NOT IMPLEMENTED YET')

    end