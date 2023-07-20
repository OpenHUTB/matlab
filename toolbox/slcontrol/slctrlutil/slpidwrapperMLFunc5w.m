function[P,I,D,N,achievedPM]=slpidwrapperMLFunc5w(w5,hG5,HasIntegrator,LoopSign,targetPM,Ts,typeidx,formidx,IFidx,DFidx,TimeDomain)





%#codegen
    coder.allowpcode('plain');
    datatype=class(w5);
    Zero=zeros(datatype);
    One=ones(datatype);

    if TimeDomain==One

        [P,I,D,N,achievedPM]=slpidfivepoint(typeidx,formidx,w5,hG5,targetPM,HasIntegrator,LoopSign,Ts,IFidx,DFidx);
    else
        [P,I,D,N,achievedPM]=slpidfivepoint(typeidx,formidx,w5,hG5,targetPM,HasIntegrator,LoopSign,Zero,IFidx,DFidx);
    end
