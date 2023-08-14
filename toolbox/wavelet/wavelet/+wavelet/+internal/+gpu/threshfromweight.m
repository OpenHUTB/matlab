function[thr,delta]=threshfromweight(weight,maxiter)%#codegen

    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');

    [m,n]=size(weight);
    zeromd=zeros(m,n);
    lo=zeros(m,1);
    hi=coder.nullcopy(zeros(m,1,'like',weight));

    coder.gpu.kernel;
    for iter=1:m
        hi(iter)=20;
    end

    Tol=1e-9;

    numiter=0;
    conTol=Inf;
    temp_delta=coder.nullcopy(zeros([maxiter+1,n],'like',weight));

    while conTol>Tol
        numiter=numiter+1;
        midpoint=(lo+hi)./2;

        fmidpoint=wavelet.internal.cauchythreshzero(midpoint,weight);


        coder.gpu.kernel;
        for iter=1:numel(fmidpoint)
            if fmidpoint(iter)<=zeromd(iter)
                lo(iter)=midpoint(iter);
            else
                hi(iter)=midpoint(iter);
            end
        end

        temp_delta(numiter)=gpucoder.internal.max(abs(hi-lo));
        conTol=temp_delta(numiter);
        if numiter>maxiter
            break;
        end
    end

    delta=coder.nullcopy(zeros(numiter,n,'like',weight));
    delta=temp_delta(1:numiter);
    thr=(lo+hi)./2;
end
