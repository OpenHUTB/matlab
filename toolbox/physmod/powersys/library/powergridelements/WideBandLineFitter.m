function[YcSERA,YcSERC,YcSERD,HSERA,HSERCph,tau,Ng,NH,Norder]=WideBandLineFitter(Z,Y,LLength,Nc,Nw,f,errlim,modegroup,~,~)




























































    w=2*pi*f;
    bigZ=zeros(Nw,Nc,Nc);
    bigY=zeros(Nw,Nc,Nc);


    for ii=1:Nw
        bigZ(ii,:,:)=Z(:,:,ii);
        bigY(ii,:,:)=Y(:,:,ii);
    end


    [bigveloc,bigHmode,bigH,bigYc]=HYccalculation(Nc,Nw,w,LLength,bigZ,bigY);


    Nstop=20;
    lastloop=20;
    optimize=0;
    gradlim=10.0d0;
    weight(1:Nw,1)=1;
    errarray(1:Nc)=1.0d6;
    dumerr=0.25d0;

    NH(1:Nc,1)=0;
    first=0;

    conloop=1;

    Ng=0;
    tau=[];
    HSERA=[];
    taulimit=[];
    tauerr=zeros(2,50);
    tau12=[];

    while conloop==1


        [Ng,tau,HSERA,NH,first,tau12,errarray,bigHmode,tauerr,taulimit]=HgroupFit(NH,Nstop,Nc,Nw,w,bigveloc,bigHmode,LLength,weight,dumerr,HSERA,optimize,lastloop,gradlim,first,Ng,tau,tau12,errarray,tauerr,taulimit,modegroup);


        [HSERCph,maxabserr,maxrespolrat]=Hfit(NH,Nc,Ng,Nw,w,bigH,weight,errlim,tau,HSERA);

        idum=NH(1);
        for i=1:Ng
            idum=min(idum,NH(i));
        end

        if((maxabserr>errlim)&&(idum<Nstop))&&(dumerr>0.007)
            dumerr=dumerr/2.0d0;
        else
            conloop=0;
        end

    end


    if maxrespolrat>100
        HSERCph=HfitLS(NH,Nc,Ng,Nw,w,bigH,tau,HSERA);
    end


    [YcSERA,YcSERC,YcSERD,~,Norder]=Ycfit(Nstop,Nc,Nw,w,bigYc,errlim,weight);

end

function[bigveloc,bigHmode,bigH,bigYc]=HYccalculation(Nc,Nw,w,LLength,bigZ,bigY)

    oldT=zeros(Nc,Nc);

    for k=1:Nw

        for row=1:Nc
            for col=1:Nc
                Z(row,col)=bigZ(k,row,col);
                Y(row,col)=bigY(k,row,col);

            end
        end




        for row=1:Nc
            for col=1:Nc
                ZY(row,col)=0;
                for m=1:Nc
                    ZY(row,col)=ZY(row,col)+Z(row,m)*Y(m,col);
                end
            end
        end



        [T,EIG]=eig(ZY);


        [T,oldT,EIG]=interch(T,oldT,EIG,Nc,k);




        for col=1:Nc
            bigveloc(k,col)=w(k)/imag(sqrt(EIG(col,col)));
        end





        for col=1:Nc
            b=zeros(Nc,1);
            for row=1:Nc
                if row==col
                    b(col,1)=1;
                end
            end
            x=Z\b;
            invZ(1:Nc,col)=x;
            x=T\b;
            invT(1:Nc,col)=x;
        end

        for row=1:Nc
            for col=1:Nc
                biginvT(k,row,col)=invT(row,col);
            end
        end

        for row=1:Nc
            for col=1:Nc
                zdum1(row,col)=0;
                for m=1:Nc
                    zdum1(row,col)=zdum1(row,col)+invZ(row,m)*T(m,col);
                end
            end
        end


        for col=1:Nc
            for row=1:Nc
                zdum1(row,col)=zdum1(row,col)*sqrt(EIG(col,col));
            end
        end


        for row=1:Nc
            for col=1:Nc
                bigYc(k,row,col)=0;
                for m=1:Nc
                    bigYc(k,row,col)=bigYc(k,row,col)+zdum1(row,m)*invT(m,col);
                end
            end
        end



        for row=1:Nc
            zdum2(row)=exp(-LLength*sqrt(EIG(row,row)));
            bigHmode(k,row)=zdum2(row);
        end



        for col=1:Nc
            for row=1:Nc
                zdum1(row,col)=T(row,col)*zdum2(col);
            end
        end


        for row=1:Nc
            for col=1:Nc
                bigH(k,col,row)=0;
                for m=1:Nc
                    bigH(k,col,row)=bigH(k,col,row)+zdum1(row,m)*invT(m,col);
                end
            end
        end

    end
end

function[Ng,tau,HSERA,NH,first,tau12,errarray,bigHmode,tauerr,taulimit]=HgroupFit(NH,Nstop,Nc,Nw,w,veloc,bigHmode,LLength,weight,dumerr,HSERA,optimize,lastloop,gradlim,first,Ng,tau,tau12,errarray,tauerr,taulimit,modegroup)

    first=first+1;dum1=0;dum2=0;
    zi=sqrt(-1);
    itermax=50;
    Ncmax=20;

    if first==1

        for i=1:Nc
            for k=1:Nw
                v(k)=veloc(k,i);
                f(k,1)=bigHmode(k,i);
            end

            [dum1,dum2]=taucalc(v,f,Nw,w,LLength,dumerr,dum1,dum2);

            if((errarray(i)>dumerr)&(NH(i)<Nstop))
                tau(i)=dum1;
                tau12(i)=dum2;
                taulimit(i)=abs(dum1)*0.6;
            end
        end

        wNw=w(Nw);

        if modegroup==1
            [Ng,bigHmode,tau,tau12,taulimit]=lumpP2(Ng,Nc,Nw,bigHmode,tau,tau12,wNw,gradlim,taulimit);
        else
            Ng=Nc;
        end

    end



    asympflag=1;
    kill=2;
    skip=0;
    rmserr=100.0d2;
























    for i=1:Ng
        mantik=1;
        if(((NH(i))<Nstop))
            NH(i)=NH(i)+1;
            ttau12(i)=1.0d0*tau12(i);

            while(mantik==1)
                oldrmserr=1.0d6;
                ttau=tau(i);
                dtau=0.5d0*ttau12(i);
                weight(1:Nw)=1.0d0;
                weight2(1,1:Nw)=1.0d0;


                for m=1:NH(i)
                    [logsp]=logkspace(m,w(1),w(Nw),NH(i));
                    SERA(m)=-1.0d0*logsp;
                end


                if(optimize==0)
                    lastloop=1;
                    dtau=0.0d0;
                end

                for tauloop=1:lastloop

                    for k=1:Nw
                        f(k,1)=(bigHmode(k,i))*exp(zi*w(k)*ttau);
                    end




                    skipflag=0;
                    for m=1:itermax

                        if(ttau==tauerr(1,m))
                            rmserr=tauerr(2,m);
                            skipflag=1;
                        end

                    end

                    if((skipflag==0)||(tauloop==lastloop))
                        for iter=1:3



                            [SERA,SERC,SERD,SERE,maxerr,rmserr,maxrelerr,weight]=vfSS(Nw,1,NH(i),w,f,...
                            weight,kill,asympflag,skip,SERA);


                        end
                    end

                    tauerr(1,tauloop)=ttau;
                    tauerr(2,tauloop)=rmserr;

                    tau(i)=ttau;
                    if tau(i)<taulimit(i)
                        tau(i)=taulimit(i);
                    end

                    if(rmserr<oldrmserr)
                        ttau=ttau+dtau;
                        tau12(i)=tau12(i)+dtau;

                    else
                        ttau=ttau-dtau/2;
                        tau12(i)=tau12(i)-dtau/2;
                        dtau=-dtau/2;
                    end
                    oldrmserr=rmserr;

                end

                if((maxerr>dumerr)&&(NH(i)<Nstop))
                    NH(i)=NH(i)+1;
                    mantik=1;
                else
                    mantik=0;
                end

            end

            errarray(i)=maxerr;

            for m=1:NH(i)
                HSERA(i,m)=SERA(m);
            end

        end

    end


    for m=Ng+1:Ncmax
        tau(m)=0.0d0;
    end

end

function[HSERCph,maxabserr,maxrespolrat,ffitted,RESPOL,maxrmserr]=Hfit(Norder,Nc,Ng,Nw,w,Hph,weight,~,tau,HSERA)























    Nwmax=120;Ncmax=1;Nmax=20;RCOND=1.0d-12;
    Nccmax=1;

    zi=sqrt(-1);

    for i=1:Ng
        for m=1:Norder(i)
            cindex(m,i)=0;
        end
    end


    for i=1:Ng
        for m=1:Norder(i)
            if(imag(HSERA(i,m))~=0.0d0)
                if(m==1)
                    cindex(m,i)=1;
                else
                    if((cindex(m-1,i)==0)|(cindex(m-1,i)==2))
                        cindex(m,i)=1;
                        cindex(m+1,i)=2;
                    else
                        cindex(m,i)=2;
                    end
                end
            end
        end
    end


    ind2=0;
    for i=1:Ng
        for m=1:Norder(i)
            ind2=ind2+1;
            for k=1:Nw
                sk=zi*w(k);
                if(cindex(m,i)==0)
                    pfract=1.0d0/(sk-HSERA(i,m));

                elseif(cindex(m,i)==1)
                    pfract=1.0d0/(sk-HSERA(i,m))+1.0d0/(sk-conj(HSERA(i,m)));

                elseif(cindex(m,i)==2)
                    pfract=zi/(sk-HSERA(i,m-1))-zi/(sk-conj(HSERA(i,m-1)));
                else
                    'ERROR1';
                end

                pfract=pfract*weight(k)*exp(-sk*tau(i));
                A(k,ind2)=real(pfract);
                A(k+Nw,ind2)=imag(pfract);
            end
        end
    end
    Acol=ind2;


    ind2=0;
    for row=1:Nc
        for col=1:Nc
            ind2=ind2+1;
            for k=1:Nw
                B(k,ind2)=weight(k)*real(Hph(k,row,col));
                B(k+Nw,ind2)=weight(k)*imag(Hph(k,row,col));
            end
        end
    end


    Arow=2*Nw;
    NRHS=Nc*Nc;


    X=pinv(A)*B;





    ind2=0;
    for i=1:Ng
        for m=1:Norder(i)
            ind2=ind2+1;
            for row=1:Nc
                for col=1:Nc
                    if(cindex(m,i)==0)
                        HSERCph(row,col,i,m)=X(ind2,(row-1)*Nc+col);
                    elseif(cindex(m,i)==1)
                        dum1=X(ind2,(row-1)*Nc+col);
                        dum2=X(ind2+1,(row-1)*Nc+col);
                        HSERCph(row,col,i,m)=dum1+zi*dum2;
                        HSERCph(row,col,i,m+1)=dum1-zi*dum2;
                    end
                end
            end
        end
    end



    dum2=0.0d0;
    for i=1:Ng
        for m=1:Norder(i)
            for row=1:Nc
                for col=1:Nc
                    zdum1=HSERCph(row,col,i,m)/HSERA(i,m);
                    RESPOL(row,col,i,m)=zdum1;
                    dum1=abs(zdum1);
                    if((dum1>1.1*dum2)&(abs(imag(HSERA(i,m)))==0.0d0))
                        dum2=dum1;
                        kill(1)=i;
                        kill(2)=m;
                    end

                end
            end
        end
    end
    maxrespolrat=dum2;



    maxabserr=0.0d0;
    maxrmserr=0.0d0;
    for row=1:Nc
        for col=1:Nc
            dum2=0.0d0;
            for k=1:Nw
                fcalc=0.0d0;
                sk=zi*w(k);
                ind2=0;
                for i=1:Ng
                    for m=1:Norder(i)
                        ind2=ind2+1;
                        fcalc=fcalc+HSERCph(row,col,i,m)*exp(-sk*tau(i))/(sk-HSERA(i,m));
                    end
                end
                dum1=abs(fcalc-Hph(k,row,col));
                maxabserr=max(dum1,maxabserr);
                dum2=dum2+dum1^2;
                ffitted(k,row,col)=fcalc;
            end
            dum2=sqrt(dum2/Nw);
            rmserr(row,col)=dum2;
            maxrmserr=max(maxrmserr,dum2);
        end
    end

end

function[HSERCph,maxabserr,maxrespolrat,ffitted,RESPOL,maxrmserr]=HfitLS(NH,Nc,Ng,Nw,w,bigH,tau,HSERA)






    bound=10;
    A=[];
    lowbound=[];
    upbound=[];
    residual=[];
    x=[];

    zi=sqrt(-1);

    for i=1:Ng
        for m=1:NH(i)
            cindex(m,i)=0;
        end
    end

    for i=1:Ng
        for m=1:NH(i)
            if(imag(HSERA(i,m))~=0.0d0)
                if(m==1)
                    cindex(m,i)=1;
                else
                    if((cindex(m-1,i)==0)|(cindex(m-1,i)==2))
                        cindex(m,i)=1;
                        cindex(m+1,i)=2;
                    else
                        cindex(m,i)=2;
                    end
                end
            end
        end
    end


    for k=1:Nw
        dum1=0;
        dum2=1;
        ind2=0;
        for i=1:Ng

            for m=1:NH(i)

                ind2=ind2+1;

                sk=zi*w(k);
                if(cindex(m,i)==0)
                    pfract=1.0d0/(sk-HSERA(i,m));
                    lowbound(ind2,1)=abs(HSERA(i,m))*-bound;
                    upbound(ind2,1)=abs(HSERA(i,m))*bound;

                elseif(cindex(m,i)==1)
                    pfract=1.0d0/(sk-HSERA(i,m))+1.0d0/(sk-conj(HSERA(i,m)));
                    lowbound(ind2,1)=abs(real(HSERA(i,m)))*-bound;
                    upbound(ind2,1)=abs(real(HSERA(i,m)))*bound;
                    lowbound(ind2+1,1)=abs(imag(HSERA(i,m)))*-bound;
                    upbound(ind2+1,1)=abs(imag(HSERA(i,m)))*bound;

                    dum=HSERA(i,m);


                elseif(cindex(m,i)==2)
                    pfract=zi/(sk-HSERA(i,m-1))-zi/(sk-conj(HSERA(i,m-1)));
                else
                    'ERROR1';
                end
                pfract=pfract*exp(-sk*tau(i));
                A(k,ind2)=real(pfract);
                A(k+Nw,ind2)=imag(pfract);

            end
        end
    end
    ind2=0;b=0;
    for i=1:Ng
        for m=1:NH(i)
            ind2=ind2+1;
            b=b+abs(HSERA(i,m));
            AA(1,ind2)=1;
        end
    end


    for row=1:Nc
        for col=1:Nc
            for k=1:Nw
                Fs(k,1)=real(bigH(k,row,col));
                Fs(k+Nw,1)=imag(bigH(k,row,col));
            end



            options=optimoptions('lsqlin','Display','off');
            [x,~,~,exitflag]=lsqlin(A,Fs,[],[],[],[],lowbound,upbound,[],options);
            if exitflag==0

                x=A\Fs;
            end

            ind2=0;
            for i=1:Ng
                for m=1:NH(i)
                    ind2=ind2+1;
                    if(cindex(m,i)==0)
                        HSERCph(row,col,i,m)=x(ind2,1);
                    elseif(cindex(m,i)==1)
                        dum1=x(ind2,1);
                        dum2=x(ind2+1,1);
                        HSERCph(row,col,i,m)=dum1+zi*dum2;
                        HSERCph(row,col,i,m+1)=dum1-zi*dum2;
                    end
                end
            end

        end
    end



    dum2=0.0d0;
    for i=1:Ng
        for m=1:NH(i)
            for row=1:Nc
                for col=1:Nc
                    zdum1=HSERCph(row,col,i,m)/HSERA(i,m);
                    RESPOL(row,col,i,m)=zdum1;
                    dum1=abs(zdum1);
                    if((dum1>1.1*dum2)&(abs(imag(HSERA(i,m)))==0.0d0))
                        dum2=dum1;
                        kill(1)=i;
                        kill(2)=m;
                    end


                end
            end
        end
    end
    maxrespolrat=dum2;



    maxabserr=0.0d0;
    maxrmserr=0.0d0;
    for row=1:Nc
        for col=1:Nc
            dum2=0.0d0;
            for k=1:Nw
                fcalc=0.0d0;
                sk=zi*w(k);
                ind2=0;
                for i=1:Ng
                    for m=1:NH(i)
                        ind2=ind2+1;
                        fcalc=fcalc+HSERCph(row,col,i,m)*exp(-sk*tau(i))/(sk-HSERA(i,m));
                    end
                end
                dum1=abs(fcalc-bigH(k,row,col));
                maxabserr=max(dum1,maxabserr);
                dum2=dum2+dum1^2;
                ffitted(k,row,col)=fcalc;
            end
            dum2=sqrt(dum2/Nw);
            rmserr(row,col)=dum2;
            maxrmserr=max(maxrmserr,dum2);
        end
    end

end

function[YcSERA,YcSERC,YcSERD,maxrelerr,Norder,Ycfitted]=Ycfit(Nstop,Nc,Nw,w,Yc,errlim,weight)
























    Nmax=20;Norder=ones(Nc,1);
    Nstop=min(Nstop,Nmax);







    for m=1:Norder(1)

        dum1=-1*logkspace(m,w(1),w(Nw),Norder(1));
        SERAstart(m)=dum1;
    end


    for k=1:Nw
        trace(k,1)=0;
        for row=1:Nc
            trace(k,1)=trace(k,1)+Yc(k,row,row);
        end
    end


    kill=2;
    asympflag=2;

    for m=1:Norder(1)
        SERA(m)=SERAstart(m);
    end


    for k=1:Nw
        weight(k,1)=weight(k,1)/abs(trace(k,1));
    end

    loop1=1;

    while loop1==1


        skip=1;
        for iter=1:2

            [SERA,SERC,SERD,SERE,maxerr,rmserr,maxrelerr]=vectfit(Nw,1,Norder(1),w,trace(:,1),weight,kill,asympflag,skip,SERA);

        end
        skip=0;
        [SERA,SERC,SERD,SERE,maxerr,rmserr,maxrelerr]=vectfit(Nw,1,Norder(1),w,trace(:,1),weight,kill,asympflag,skip,SERA);


        zi=sqrt(-1);

        cindex(1:Norder(1))=0;


        for m=1:Norder(1)
            if(imag(SERA(m))~=0.0d0)
                if(m==1)
                    cindex(m)=1;
                else
                    if((cindex(m-1)==0)|(cindex(m-1)==2))
                        cindex(m)=1;
                        cindex(m+1)=2;
                    else
                        cindex(m)=2;
                    end
                end
            end
        end


        ind2=0;
        for m=1:Norder(1)
            ind2=ind2+1;
            for k=1:Nw
                sk=zi*w(k);

                if(cindex(m)==0)
                    pfract=1.0d0/(sk-SERA(m));

                elseif(cindex(m)==1)
                    pfract=1.0d0/(sk-SERA(m))+1.0d0/(sk-conj(SERA(m)));

                elseif(cindex(m)==2)
                    pfract=zi/(sk-SERA(m-1))-zi/(sk-conj(SERA(m-1)));
                else
                    'ERROR1';
                end
                pfract=weight(k)*pfract;
                A(k,ind2)=real(pfract);
                A(k+Nw,ind2)=imag(pfract);
            end
        end

        for k=1:Nw
            A(k,ind2+1)=weight(k);
        end
        Acol=ind2+1;


        ind2=0;
        for row=1:Nc
            for col=1:Nc
                ind2=ind2+1;
                for k=1:Nw
                    B(k,ind2)=weight(k)*real(Yc(k,row,col));
                    B(k+Nw,ind2)=weight(k)*imag(Yc(k,row,col));
                end
            end
        end

        Arow=2*Nw;
        NRHS=Nc*Nc;
        X=A\B;


        for row=1:Acol
            for col=1:NRHS
                X(row,col)=X(row,col);
            end
        end


        ind2=0;
        for m=1:Norder(1)
            ind2=ind2+1;
            for row=1:Nc
                for col=1:Nc
                    if(cindex(m)==0)
                        YcSERC(row,col,m)=X(ind2,(row-1)*Nc+col);
                    elseif(cindex(m)==1)
                        dum1=X(ind2,(row-1)*Nc+col);
                        dum2=X(ind2+1,(row-1)*Nc+col);
                        YcSERC(row,col,m)=dum1+zi*dum2;
                        YcSERC(row,col,m+1)=dum1-zi*dum2;
                    end
                end
            end
        end

        for row=1:Nc
            for col=1:Nc
                YcSERD(row,col)=X(Norder(1)+1,(row-1)*Nc+col);
            end
        end


        maxabserr=0.0d0;
        maxrelerr=0.0d0;
        for k=1:Nw
            for row=1:Nc
                for col=1:Nc
                    fcalc(row,col)=YcSERD(row,col);
                    sk=zi*w(k);
                    for m=1:Norder(1)
                        ind2=ind2+1;
                        fcalc(row,col)=fcalc(row,col)+YcSERC(row,col,m)/(sk-SERA(m));
                    end
                end
            end

            dum1=0.0d0;
            dum2=0.0d0;
            for row=1:Nc
                for col=1:Nc
                    dum1=max(dum1,abs(Yc(k,row,col)));
                    dum2=max(dum2,abs(fcalc(row,col)-Yc(k,row,col)));
                    Ycfitted(k,row,col)=fcalc(row,col);
                end
            end
            maxrelerr=max(maxrelerr,dum2/dum1);

        end



        if((maxrelerr>errlim)&(Norder(1)<=(Nstop-1)))
            Norder(1)=Norder(1)+1;
            for m=1:Norder(1)
                SERA(m)=-logkspace(m,w(1),w(Nw),Norder(1));
            end
        else
            loop1=0;
        end
    end


    temp_text=' ';





    for col=1:Nc
        Norder(col)=Norder(1);
        for m=1:Norder(1)
            YcSERA(col,m)=SERA(m);
        end
    end



    for k=1:Nw
        weight(k)=weight(k)*abs(trace(k));
    end
    Norder(1);

end

function[T,oldT,EIG]=interch(T,oldT,EIG,Nc,fstep)




    if fstep>1



        for ii=1:Nc
            ilargest=0;
            rlargest=0;
            for j=1:Nc
                dotprod=0;
                for k=1:Nc

                    dotprod=dotprod+conj(oldT(k,ii))*T(k,j);
                end

                if(abs(real(dotprod))>rlargest)
                    rlargest=abs(real(dotprod));
                    ilargest=j;
                end
            end

            dot(ii)=rlargest;
            ind(ii)=ii;
            taken(ii)=0;
        end


        for ii=1:Nc
            for j=1:Nc-1
                if(dot(j)<dot(j+1))
                    dum=dot(j+1);
                    idum=ind(j+1);
                    dot(j+1)=dot(j);
                    ind(j+1)=ind(j);
                    dot(j)=dum;
                    ind(j)=idum;
                end
            end
        end


        for l=1:Nc
            ii=ind(l);
            ilargest=0;
            rlargest=0;

            for j=1:Nc
                if(taken(j)==0)
                    dotprod=0;
                    for k=1:Nc

                        dotprod=dotprod+conj(oldT(k,ii))*T(k,j);
                    end

                    if(abs(real(dotprod))>rlargest)
                        rlargest=abs(real(dotprod));
                        ilargest=j;
                    end
                end
            end

            taken(ii)=1;



            for k=1:Nc
                cdum=T(k,ii);
                T(k,ii)=T(k,ilargest);
                T(k,ilargest)=cdum;
            end

            cdum=EIG(ii,ii);
            EIG(ii,ii)=EIG(ilargest,ilargest);
            EIG(ilargest,ilargest)=cdum;
        end




        for ii=1:Nc
            dotprod=0;
            for k=1:Nc

                dotprod=dotprod+(real(oldT(k,ii))-imag(oldT(k,ii)))*T(k,j)*sqrt(-1);

            end

            if(real(dotprod)<0)
                for j=1:Nc
                    T(k,ii)=-T(k,ii);
                    T(k,ii)=-T(k,ii);
                end
            end
        end


    end

    oldT=T;

end

function[tau,tau12]=taucalc(veloc,H,Nw,w,length,~,~,~)




    dumerr=0.25;
    flag=0;
    j=Nw;
    for k=1:Nw
        absH(k)=abs(H(k));
        if((absH(k)<dumerr)&(flag==0))
            j=k;
            flag=1;
        end
    end



    if(j==Nw)
        j=Nw-1;
    end







    jlow=1;
    jhigh=1;
    for k=1:Nw
        if(w(k)/w(j)<0.1d0)
            jlow=k;
        end
        if(w(k)/w(j)<10.0d0)
            jhigh=k;
        end
    end

    for ii=jhigh:-1:jlow
        if absH(ii)==0
            jhigh=jhigh-1;
        end
    end






    tau0=length/veloc(j);

    ang1=(pi/2.0d0)*log((absH(j+1)/absH(j-1)))/(log(w(j+1)/w(j-1)));
    tau1=ang1/w(j);



    ang2=0;
    for k=jlow:jhigh-1
        term1=log((absH(k+1)/absH(k)))/(log(w(k+1)/w(k)));
        term2=log((absH(j+1)/absH(j-1)))/(log(w(j+1)/w(j-1)));
        ang2=ang2+(abs(term1)-abs(term2))*...
        log(1.0d0/tanh(abs(log((w(k)+w(k+1))/(2*w(j))))/2))*...
        log(w(k+1)/w(k));
    end
    ang2=ang2/pi;
    tau2=ang2/w(j);
    tau12=tau1+tau2;
    tau=tau0+tau1+tau2;

end

function[Ng,Hmode,tau,tau12,tau1]=lumpP2(~,Nc,Nw,Hmode,tau,tau12,wNw,gradlim,tau1)

















    Nwmax=1000;
    Ncmax=20;
    Nmax=20;
    RCOND=1.0d-16;


    PI=4.0*atan(1);
    crit=2*PI*gradlim/(360*wNw);
    for m=1:Ncmax
        grindex(m)=0;
        Nelems(m)=0;
        taug(m)=1.0d16;
        taug12(m)=1.0d16;
        taug1(m)=1.0d16;
        for k=1:Nwmax
            dum2(k,m)=0.0d0;
        end
    end


    for col=1:Nc
        for m=1:Nc-1
            if(tau(m+1)<tau(m))
                dum1=tau(m);
                tau(m)=tau(m+1);
                tau(m+1)=dum1;
                dum1=tau12(m);
                tau12(m)=tau12(m+1);
                tau12(m+1)=dum1;
                dum1=tau1(m);
                tau1(m)=tau1(m+1);
                tau1(m+1)=dum1;
                for k=1:Nw
                    zdum=Hmode(k,m);
                    Hmode(k,m)=Hmode(k,m+1);
                    Hmode(k,m+1)=zdum;
                end
            end
        end
    end


    for m=1:Nc
        if(grindex(m)==0)
            for nn=1:Nc
                if(((tau(nn)-tau(m))<crit)&(grindex(nn)==0))
                    if(m==1)
                        grindex(nn)=1;
                    else
                        grindex(nn)=grindex(m-1)+1;
                    end
                end
            end
        end
    end


    for m=1:Nc
        Nelems(grindex(m))=Nelems(grindex(m))+1;
    end


    Ng=0;
    for m=1:Nc
        if(Nelems(m)>0)
            Ng=Ng+1;
        end
    end


    for m=1:Nc
        nn=grindex(m);
        for k=1:Nw
            dum2(k,nn)=dum2(k,nn)+Hmode(k,m);
        end
    end




    for m=1:Ng
        for k=1:Nw
            dum2(k,m)=dum2(k,m)/Nelems(m);
        end
    end



    for m=1:Nc
        for nn=1:Nc
            if(grindex(m)==grindex(nn))
                if(taug(grindex(m))>tau(nn))
                    taug(grindex(m))=tau(nn);
                    taug12(grindex(m))=tau12(nn);
                    taug1(grindex(m))=tau1(nn);
                end
            end
        end
    end


    for m=1:Nc
        tau(m)=taug(m);
        tau12(m)=taug12(m);
        tau1(m)=taug1(m);
        for k=1:Nw
            Hmode(k,m)=dum2(k,m);
        end
    end

end

function[logsp]=logkspace(m,w1,wN,N)













    if(N>=2)
        d1=log10(w1);
        d2=log10(wN);
        alfa=(d2-d1)/(N-1);
        wm=d1+alfa*(m-1);
        wm=10^(wm);
        logsp=wm;
    else
        logsp=w1;
    end

end

function[SERA,SERC,SERD,SERE,maxerr,rmserr,maxrelerr,weight]=vfSS(Nw,Ncol,Norder,w,f,weight,...
    kill,asympflag,skip,SERA);





















































































    Nwmax=120;Ncmax=1;Nmax=20;RCOND=1.0d-12;
    Nccmax=1;









    Arowmax=2*Nccmax*Nwmax;Acolmax=(Nccmax+1)*(Nmax+2);
    NRHSmax=Nccmax*Nccmax;
    NLWORKmax=3*Arowmax;
    A=zeros(Arowmax,Acolmax);

    WORK=zeros(NLWORKmax);


















    zi=sqrt(-1);

    if(asympflag==1)
        offs=0;
    elseif(asympflag==2)
        offs=1;
    elseif(asympflag==3)
        offs=2;
    else
        'error';
    end


    Arow=2*Ncol*Nw;
    Acol=(Ncol+1)*Norder+Ncol*2;
    A=zeros(Arow,Acol);A=[];


    cindex(1:Norder)=0;

    for m=1:Norder
        if(imag(SERA(m))~=0.0d0)
            if(m==1)
                cindex(m)=1;
            else
                if((cindex(m-1)==0)|(cindex(m-1)==2))
                    cindex(m)=1;
                    cindex(m+1)=2;
                else
                    cindex(m)=2;
                end
            end
        end
    end



    ind3=Ncol*(Norder+offs);
    for k=1:Nw
        sk=zi*w(k);
        for m=1:Norder

            if(cindex(m)==0)
                pfract=1.0d0/(sk-SERA(m));

            elseif(cindex(m)==1)
                pfract=1.0d0/(sk-SERA(m))+1.0d0/(sk-conj(SERA(m)));

            elseif(cindex(m)==2)
                pfract=zi/(sk-SERA(m-1))-zi/(sk-conj(SERA(m-1)));
            end
            pfract=pfract*weight(k);

            for i=1:Ncol
                ind1=(i-1)*Nw+k;
                ind2=(i-1)*(Norder+offs)+m;

                A(ind1,ind2)=real(pfract);
                A(ind1+Ncol*Nw,ind2)=imag(pfract);



                fpfract=-pfract*f(k,i);
                A(ind1,ind3+m)=real(fpfract);
                A(Ncol*Nw+ind1,ind3+m)=imag(fpfract);
            end
        end
    end


    for k=1:Nw
        for i=1:Ncol
            ind1=(i-1)*Nw+k;
            ind2=(i-1)*(Norder+offs)+Norder;
            if(asympflag==2)
                A(ind1,ind2+1)=weight(k);
                A(Ncol*Nw+ind1,ind2+1)=0.0d0;
            elseif(asympflag==3)
                A(ind1,ind2+1)=weight(k);
                A(Ncol*Nw+ind1,ind2+1)=0.0d0;
                A(ind1,ind2+2)=0.0d0;
                A(Ncol*Nw+ind1,ind2+2)=weight(k)*w(k);
            else
            end
        end
    end




    for k=1:Nw
        for i=1:Ncol
            ind1=(i-1)*Nw+k;
            B(ind1,1)=weight(k)*real(f(k,i));
            B(ind1+Nw*Ncol,1)=weight(k)*imag(f(k,i));
        end
    end



    Arow=2*Ncol*Nw;
    Acol=(Ncol+1)*Norder+Ncol*offs;
    for col=1:Acol
        Escale(col)=0.0d0;
        for row=1:Arow
            Escale(col)=Escale(col)+abs(A(row,col))^2;
        end
        Escale(col)=sqrt(Escale(col));
        if(Escale(col)==0.0d0)
            Escale(col)=1.0d0;
        end
    end

    for col=1:Acol
        for row=1:Arow
            A(row,col)=A(row,col)/Escale(col);
        end
    end





    NRHS=Ncol;











    X=(A)\B;

    X=X./Escale';










    eigB=[];eigC=[];eigH=[];SERC=[];SERD=[];SERE=[];
    for row=1:Norder
        eigB(row,1)=0.0d0;
        eigC(1,row)=0.0d0;
        for col=1:Norder
            eigH(row,col)=0.0d0;
        end
    end

    for m=1:Norder
        if(cindex(m)==0)
            eigH(m,m)=SERA(m);
        elseif(cindex(m)==1)
            eigH(m,m)=real(SERA(m));
            eigH(m+1,m+1)=real(SERA(m));
            eigH(m,m+1)=imag(SERA(m));
            eigH(m+1,m)=-1*imag(SERA(m));
        end
    end

    for m=1:Norder
        if(cindex(m)==0)
            eigB(m,1)=1.0d0;
        elseif(cindex(m)==1)
            eigB(m,1)=2.0d0;
            eigB(m+1,1)=0.0d0;
        end
    end

    ind2=Ncol*(Norder+offs);
    for m=1:Norder
        eigC(1,m)=X(ind2+m,1);
    end
    eigH=eigH-eigB*eigC;







    [T,EIG]=eig(eigH);






    for m=1:Norder
        SERA(m)=real(EIG(m,m))+zi*imag(EIG(m,m));
    end



    for m=1:Norder
        for k=m:Norder
            if(abs(SERA(k))<abs(SERA(m)))
                zdum=SERA(k);
                SERA(k)=SERA(m);
                SERA(m)=zdum;
            end
        end
    end
    SERA;

    for m=1:Norder
        cindex(m)=0;
    end

    for m=1:Norder
        if(imag(SERA(m))~=0.0d0)
            if(m==1)
                cindex(m)=1;
            else
                if((cindex(m-1)==0)|(cindex(m-1)==2))
                    cindex(m)=1;
                    cindex(m+1)=2;
                else
                    cindex(m)=2;
                end
            end
        end
    end


    if(kill==2)
        for m=1:Norder
            if(real(SERA(m))>0.0d0)
                SERA(m)=SERA(m)-2.0d0*real(SERA(m));
            end
        end
    end



    for col=1:1
        for m=1:Norder
            if(cindex(m)==1)
                dum1=X(ind2+m);
                dum2=X(ind2+m+1);
                X(m)=dum1+zi*dum2;
                X(m+1)=dum1-zi*dum2;
            end
        end
    end


    Den=zeros(Nw,1);
    for i=1:Nw
        for m=1:Norder
            Den(i)=Den(i)+X(ind2+m)/(sqrt(-1)*w(i)-SERA(m));
        end
        weight(i)=1/(1+Den(i));
        weight(i)=abs(weight(i));
    end









    A=[];
    for k=1:Nw
        sk=zi*w(k);
        for m=1:Norder

            if(cindex(m)==0)
                pfract=1.0d0/(sk-SERA(m));

            elseif(cindex(m)==1)
                pfract=1.0d0/(sk-SERA(m))+1.0d0/(sk-conj(SERA(m)));

            elseif(cindex(m)==2)
                pfract=zi/(sk-SERA(m-1))-zi/(sk-conj(SERA(m-1)));
            end
            pfract=pfract*1;

            for i=1:Ncol
                ind2=(i-1)*(Norder+offs);
                A(k,ind2+m)=real(pfract);
                A(k+Nw,ind2+m)=imag(pfract);
            end
        end
    end

    for k=1:Nw
        if(asympflag==2)
            A(k,Norder+1)=1;
            A(Nw+k,Norder+1)=0.0d0;
        elseif(asympflag==3)
            A(k,Norder+1)=1;
            A(Nw+k,Norder+1)=0.0d0;
            A(k,Norder+2)=0.0d0;
            A(Nw+k,Norder+2)=1*w(k);
        end
    end


    B=[];
    for col=1:Ncol
        for k=1:Nw
            B(k,col)=real(f(k,col));
            B(k+Nw,col)=imag(f(k,col));
        end
    end




    Arow=2*Nw;
    Acol=Norder+offs;Escale=[];
    for col=1:Acol
        Escale(col)=0.0;
        for row=1:Arow;
            Escale(col)=Escale(col)+abs(A(row,col))^2;
        end
        Escale(col)=sqrt(Escale(col));
        if(Escale(col)==0.0)
            Escale(col)=1.0;
        end
    end

    for col=1:Acol
        for row=1:Arow
            A(row,col)=A(row,col)/Escale(col);
        end
    end









    X=(A)\B;







    X=X./Escale';



    for col=1:Ncol
        for m=1:Norder
            SERC(m,col)=X(m,col);
        end
        if(asympflag==1)
            SERD(col)=0.0;
            SERE(col)=0.0d0;
        elseif(asympflag==2)
            SERD(col)=X(Norder+1,col);
            SERE(col)=0.0d0;
        else
            SERD(col)=X(Norder+1,col);
            SERE(col)=X(Norder+2,col);
        end
    end



    for col=1:1
        for m=1:Norder
            if(cindex(m)==1)
                dum1=SERC(m,col);
                dum2=SERC(m+1,col);
                SERC(m,col)=dum1+zi*dum2;
                SERC(m+1,col)=dum1-1*zi*dum2;
            end
        end
    end


    for i=1:Ncol
        for k=1:Nw
            sk=zi*w(k);
            ffit(k,i)=SERD(i)+sk*SERE(i);
            for m=1:Norder
                ffit(k,i)=ffit(k,i)+SERC(m,i)/(sk-SERA(m));
            end
        end
    end























    maxrelerr=0.0d0;
    rmserr=0.0d0;
    maxerr=0.0d0;
    for k=1:Nw
        maxval=1.0d-6;
        dum2=0.0d0;
        for i=1:Ncol
            dum1=abs(ffit(k,i)-f(k,i));
            rmserr=rmserr+dum1^2;
            if(dum1>maxerr)
                maxerr=dum1;
            end

            if(dum1>dum2)
                dum2=dum1;
            end

            dum3=abs(f(k,i));
            if(dum3>maxval)
                maxval=dum3;
            end
        end

        maxrelerr=max(maxrelerr,dum2/maxval);
    end
    rmserr=sqrt(rmserr/(Nw*Ncol));

end

function[SERA,SERC,SERD,SERE,maxerr,rmserr,maxrelerr]=vectfit(Nw,Ncol,Norder,w,f,weight,kill,asympflag,~,...
    SERA);






















































































    Nwmax=120;Ncmax=1;Nmax=20;RCOND=1.0d-12;
    Nccmax=1;









    Arowmax=2*Nccmax*Nwmax;Acolmax=(Nccmax+1)*(Nmax+2);
    NRHSmax=Nccmax*Nccmax;
    NLWORKmax=3*Arowmax;
    A=zeros(Arowmax,Acolmax);

    WORK=zeros(NLWORKmax);


















    zi=sqrt(-1);

    if(asympflag==1)
        offs=0;
    elseif(asympflag==2)
        offs=1;
    elseif(asympflag==3)
        offs=2;
    else
        'error';
    end


    Arow=2*Ncol*Nw;
    Acol=(Ncol+1)*Norder+Ncol*2;
    A=zeros(Arow,Acol);A=[];


    cindex(1:Norder)=0;

    for m=1:Norder
        if(imag(SERA(m))~=0.0d0)
            if(m==1)
                cindex(m)=1;
            else
                if((cindex(m-1)==0)|(cindex(m-1)==2))
                    cindex(m)=1;
                    cindex(m+1)=2;
                else
                    cindex(m)=2;
                end
            end
        end
    end



    ind3=Ncol*(Norder+offs);
    for k=1:Nw
        sk=zi*w(k);
        for m=1:Norder

            if(cindex(m)==0)
                pfract=1.0d0/(sk-SERA(m));

            elseif(cindex(m)==1)
                pfract=1.0d0/(sk-SERA(m))+1.0d0/(sk-conj(SERA(m)));

            elseif(cindex(m)==2)
                pfract=zi/(sk-SERA(m-1))-zi/(sk-conj(SERA(m-1)));
            end
            pfract=pfract*weight(k);

            for i=1:Ncol
                ind1=(i-1)*Nw+k;
                ind2=(i-1)*(Norder+offs)+m;



                A(ind1,ind2)=real(pfract);
                A(ind1+Ncol*Nw,ind2)=imag(pfract);



                fpfract=-pfract*f(k,i);
                A(ind1,ind3+m)=real(fpfract);
                A(Ncol*Nw+ind1,ind3+m)=imag(fpfract);
            end
        end
    end


    for k=1:Nw
        for i=1:Ncol
            ind1=(i-1)*Nw+k;
            ind2=(i-1)*(Norder+offs)+Norder;
            if(asympflag==2)
                A(ind1,ind2+1)=weight(k);
                A(Ncol*Nw+ind1,ind2+1)=0.0d0;
            elseif(asympflag==3)
                A(ind1,ind2+1)=weight(k);
                A(Ncol*Nw+ind1,ind2+1)=0.0d0;
                A(ind1,ind2+2)=0.0d0;
                A(Ncol*Nw+ind1,ind2+2)=weight(k)*w(k);
            end
        end
    end


    for k=1:Nw
        for i=1:Ncol
            ind1=(i-1)*Nw+k;
            B(ind1,1)=weight(k)*real(f(k,i));
            B(ind1+Nw*Ncol,1)=weight(k)*imag(f(k,i));
        end
    end



    Arow=2*Ncol*Nw;
    Acol=(Ncol+1)*Norder+Ncol*offs;
    for col=1:Acol
        Escale(col)=0.0d0;
        for row=1:Arow
            Escale(col)=Escale(col)+abs(A(row,col))^2;
        end
        Escale(col)=sqrt(Escale(col));
        if(Escale(col)==0.0d0)
            Escale(col)=1.0d0;
        end
    end

    for col=1:Acol
        for row=1:Arow
            A(row,col)=A(row,col)/Escale(col);
        end
    end





    NRHS=Ncol;


















    X=A\B;
    X=X./Escale';
    eigB=[];eigC=[];eigH=[];SERC=[];SERD=[];SERE=[];
    for row=1:Norder
        eigB(row,1)=0.0d0;
        eigC(1,row)=0.0d0;
        for col=1:Norder
            eigH(row,col)=0.0d0;
        end
    end

    for m=1:Norder
        if(cindex(m)==0)
            eigH(m,m)=SERA(m);
        elseif(cindex(m)==1)
            eigH(m,m)=real(SERA(m));
            eigH(m+1,m+1)=real(SERA(m));
            eigH(m,m+1)=imag(SERA(m));
            eigH(m+1,m)=-1*imag(SERA(m));
        end
    end

    for m=1:Norder
        if(cindex(m)==0)
            eigB(m,1)=1.0d0;
        elseif(cindex(m)==1)
            eigB(m,1)=2.0d0;
            eigB(m+1,1)=0.0d0;
        end
    end

    ind2=Ncol*(Norder+offs);
    for m=1:Norder
        eigC(1,m)=X(ind2+m,1);
    end

    eigH=eigH-eigB*eigC;







    [T,EIG]=eig(eigH);






    for m=1:Norder
        SERA(m)=real(EIG(m,m))+zi*imag(EIG(m,m));
    end



    for m=1:Norder
        for k=m:Norder
            if(abs(SERA(k))<abs(SERA(m)))
                zdum=SERA(k);
                SERA(k)=SERA(m);
                SERA(m)=zdum;
            end
        end
    end


    for m=1:Norder
        cindex(m)=0;
    end

    for m=1:Norder
        if(imag(SERA(m))~=0.0d0)
            if(m==1)
                cindex(m)=1;
            else
                if((cindex(m-1)==0)|(cindex(m-1)==2))
                    cindex(m)=1;
                    cindex(m+1)=2;
                else
                    cindex(m)=2;
                end
            end
        end
    end


    if(kill==2)
        for m=1:Norder
            if(real(SERA(m))>0.0d0)
                SERA(m)=SERA(m)-2.0d0*real(SERA(m));
            end
        end
    end








    A=[];
    for k=1:Nw
        sk=zi*w(k);
        for m=1:Norder

            if(cindex(m)==0)
                pfract=1.0d0/(sk-SERA(m));

            elseif(cindex(m)==1)
                pfract=1.0d0/(sk-SERA(m))+1.0d0/(sk-conj(SERA(m)));

            elseif(cindex(m)==2)
                pfract=zi/(sk-SERA(m-1))-zi/(sk-conj(SERA(m-1)));
            end
            pfract=pfract*weight(k);
            for i=1:Ncol
                ind2=(i-1)*(Norder+offs);
                A(k,ind2+m)=real(pfract);
                A(k+Nw,ind2+m)=imag(pfract);
            end
        end
    end

    for k=1:Nw
        if(asympflag==2)
            A(k,Norder+1)=weight(k);
            A(Nw+k,Norder+1)=0.0d0;
        elseif(asympflag==3)
            A(k,Norder+1)=weight(k);
            A(Nw+k,Norder+1)=0.0d0;
            A(k,Norder+2)=0.0d0;
            A(Nw+k,Norder+2)=weight(k)*w(k);
        end
    end


    B=[];
    for col=1:Ncol
        for k=1:Nw
            B(k,col)=weight(k)*real(f(k,col));
            B(k+Nw,col)=weight(k)*imag(f(k,col));
        end
    end



    Arow=2*Nw;
    Acol=Norder+offs;Escale=[];
    for col=1:Acol
        Escale(col)=0.0;
        for row=1:Arow;
            Escale(col)=Escale(col)+abs(A(row,col))^2;
        end
        Escale(col)=sqrt(Escale(col));
        if(Escale(col)==0.0)
            Escale(col)=1.0;
        end
    end

    for col=1:Acol
        for row=1:Arow
            A(row,col)=A(row,col)/Escale(col);
        end
    end








    X=A\B;


    X=X./Escale';

    for col=1:Ncol
        for m=1:Norder
            SERC(m,col)=X(m,col);
        end
        if(asympflag==1)
            SERD(col)=0.0;
            SERE(col)=0.0d0;
        elseif(asympflag==2)
            SERD(col)=X(Norder+1,col);
            SERE(col)=0.0d0;
        else
            SERD(col)=X(Norder+1,col);
            SERE(col)=X(Norder+2,col);
        end
    end


    for col=1:1
        for m=1:Norder
            if(cindex(m)==1)
                dum1=SERC(m,col);
                dum2=SERC(m+1,col);
                SERC(m,col)=dum1+zi*dum2;
                SERC(m+1,col)=dum1-1*zi*dum2;
            end
        end
    end


    for i=1:Ncol
        for k=1:Nw
            sk=zi*w(k);
            ffit(k,i)=SERD(i)+sk*SERE(i);
            for m=1:Norder
                ffit(k,i)=ffit(k,i)+SERC(m,i)/(sk-SERA(m));
            end
        end
    end







    maxrelerr=0.0d0;
    rmserr=0.0d0;
    maxerr=0.0d0;
    for k=1:Nw
        maxval=0.0d0;
        dum2=0.0d0;
        for i=1:Ncol
            dum1=abs(ffit(k,i)-f(k,i));
            rmserr=rmserr+dum1^2;
            if(dum1>maxerr)
                maxerr=dum1;
            end
            if(dum1>dum2)
                dum2=dum1;
            end
            dum3=abs(f(k,i));
            if(dum3>maxval)
                maxval=dum3;
            end
        end
        maxrelerr=max(maxrelerr,dum2/maxval);
    end
    rmserr=sqrt(rmserr/(Nw*Ncol));

end