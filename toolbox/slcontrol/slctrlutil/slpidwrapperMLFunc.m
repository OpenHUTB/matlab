function[P,I,D,N,achievedPM]=slpidwrapperMLFunc(w4,hG4,K0,targetPM,Ts,typeidx,formidx,IFidx,DFidx,TimeDomain)





%#codegen
    coder.allowpcode('plain');
    datatype=class(w4);
    Zero=zeros(datatype);
    One=ones(datatype);

    if TimeDomain==One

        [P,I,D,N,achievedPM]=slpidthreepoint(typeidx,formidx,w4,hG4,targetPM,K0,Ts,IFidx,DFidx);
    else
        [P,I,D,N,achievedPM]=slpidthreepoint(typeidx,formidx,w4,hG4,targetPM,K0,Zero,IFidx,DFidx);
    end
