function[UBcert,NLMI]=LMICarve(a,b,c,d,Ts,index4mu,wInterval,V,Focus)




    NLMI=0;


    wmin=wInterval(1);
    wmax=wInterval(2);
    w=rctutil.intervalmean(wInterval);
    M=rctutil.freqresp(a,b,c,d,Ts,w);
    dwmin=max((V.RelIntervalTol-1)*w/2,V.AbsIntervalTol);
    TinyInterval=(wmax-wmin<6*dwmin);


    if TinyInterval

        M3=cat(3,M,rctutil.freqresp(a,b,c,d,Ts,[max(0,w-dwmin),w+dwmin]));
        [ptUB,DG]=constantDGub(M3,index4mu,V);
    else

        [ptUB,DG,DGInfo]=constantDGub(M,index4mu,V);
    end
    NLMI=NLMI+1;
    if isinf(ptUB)


        UBcert=struct('Interval',wInterval,'gUB',Inf,...
        'VLmi',DG,'ptUB',Inf,'w',w,'Jump',true);
        return
    end


    carveUB=max([V.abstol,V.gUBmax,(1+V.etol)*ptUB]);
    [wL,wR]=findIntervalHam(a,b,c,d,Ts,DG,carveUB,w);







    if any(V.userMuOpt=='a')&&~TinyInterval&&wR-wL<0.25*min(w,wmax-wmin)
        nx=size(a,1);
        Aw=1i*w*eye(nx)-a;
        dM=(1i*w)*matlab.internal.math.nowarn.mrdivide(c,Aw)*...
        matlab.internal.math.nowarn.mldivide(Aw,b);
        [tau,DGmax]=maxCarveDG(M,dM,carveUB,index4mu,DGInfo);
        NLMI=NLMI+1;
        if w*tau>min(wR-w,w-wL)

            DG=DGmax;
            [wL,wR]=findIntervalHam(a,b,c,d,Ts,DG,carveUB,w);



        end
    end


    wL=max(wL,Focus(1));
    wR=min(wR,Focus(2));
    UBcert=struct('Interval',[wL,wR],'gUB',carveUB,...
    'VLmi',DG,'ptUB',ptUB,'w',w,'Jump',(carveUB>V.gUBmax));