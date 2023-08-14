function omega=cwtFreqGrid(SignalLength,SignalPad)





    coder.allowpcode('plain');

%#codegen

    N=SignalLength+2*SignalPad;
    M=idivide(N,2);

    dftfactor=(2*pi)/cast(N,'double');

    omega=coder.nullcopy(zeros(1,N));

    coder.gpu.kernel();
    for kk=0:M
        omega(kk+1)=double(kk)*dftfactor;
        if kk+M+2<=N
            omega(kk+M+2)=0.0;
        end

    end





