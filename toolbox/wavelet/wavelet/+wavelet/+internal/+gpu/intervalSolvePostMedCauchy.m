function[muhat,delta]=intervalSolvePostMedCauchy(zeromd,lo,hi,maxiter,magdata,weight)%#codegen

    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');

    [m,n]=size(zeromd);
    conTol=Inf;

    loUp=coder.nullcopy(zeros(m,size(lo,2),'like',zeromd));
    hiUp=coder.nullcopy(zeros(m,size(hi,2),'like',zeromd));

    coder.gpu.kernel;
    for i=1:m
        loUp(i,:)=lo;
        hiUp(i,:)=hi;
    end

    Tol=1e-9;
    numiter=0;
    temp_delta=coder.nullcopy(zeros([maxiter+1,n],'like',zeromd));
    while conTol>Tol
        numiter=numiter+1;
        midpoint=(loUp+hiUp)./2;

        fmidpoint=wavelet.internal.cauchymedzero(midpoint,magdata,weight);


        coder.gpu.kernel;
        for iter=1:numel(fmidpoint)
            if fmidpoint(iter)<=zeromd(iter)
                loUp(iter)=midpoint(iter);
            else
                hiUp(iter)=midpoint(iter);
            end
        end


        if isvector(hiUp)
            tempVal=gpucoder.internal.max(abs(hiUp-loUp));
            temp_delta(numiter)=tempVal(1);
            conTol=temp_delta(numiter);
        else

            coder.gpu.kernel;
            for i=1:n
                tempVal=gpucoder.internal.max(abs(hiUp(:,i)-loUp(:,i)));
                temp_delta(numiter,i)=tempVal(1);
            end
            temp_max=temp_delta(numiter);

            conTol=gpucoder.internal.max(temp_max);
        end

        if numiter>maxiter
            break;
        end
    end

    delta=coder.nullcopy(zeros(numiter,n,'like',zeromd));
    delta=temp_delta(1:numiter,:);
    muhat=(loUp+hiUp)./2;
end