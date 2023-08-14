function[B,A]=designLPHPFilter(N,G,Wo,BW)




%#codegen

    coder.inline('never');
    coder.allowpcode('plain');

    Nnew=N;
    Gnew=G;
    BWnew=BW*ones(1,1,'like',BW);
    [B,A]=designEachParamEQ(Nnew,Gnew,Wo,BWnew);


    function[B,A]=designEachParamEQ(N,G,w0,BW)


        dType=class(G);


        gain=cast(0.5,dType)*ones(1,1,dType);
        GB=cast(10,dType)*log10(gain);

        No2=N/cast(2,dType);


        B=zeros(3,No2,dType);
        B(1,1:No2)=cast(1,dType);
        A=zeros(2,No2,dType);


        G0sq=ones(1,1,dType);
        tenCast=cast(10,dType);
        Gsq=tenCast^(G/tenCast);
        GBsq=tenCast^(GB/tenCast);


        [Bf,Af]=audio.internal.designHPEQFilter(No2,G0sq,Gsq,GBsq,w0,BW,dType);

        N4=ceil(N/cast(4,dType));
        B(1:3,1:N4)=Bf(:,1:3)';
        A(1:2,1:N4)=Af(:,2:3)';
