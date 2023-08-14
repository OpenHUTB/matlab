function[weight,deltaweight]=weightfromdata(x,whi,wlo,...
    tmpweight,beta,maxiter,shi)%#codegen

    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');

    deltaweight=[];



    shiNonNegFlag=0;
    returnFlag=1;
    coder.gpu.kernel;
    for iter=1:numel(shi)
        if shi(iter)>=0
            tmpweight(iter)=1;
            shiNonNegFlag=1;
        else
            returnFlag=0;
        end
    end



    if returnFlag&&shiNonNegFlag
        weight=tmpweight;
        return;
    end

    temp=bsxfun(@times,wlo,beta);
    slo=sum(bsxfun(@rdivide,beta,(1+temp)));
    initialwlo=coder.nullcopy(zeros(size(slo),'like',x));



    coder.gpu.kernel;
    for iter=1:numel(slo)
        if slo(iter)<=0
            tmpweight(iter)=wlo(iter);
            initialwlo(iter)=wlo(iter);
        end
    end


    [~,n]=size(x);
    conTol=Inf;


    wtol=100*eps(1);
    stol=1e-7;
    ii=1;

    temp_deltaweight=coder.nullcopy(zeros([maxiter+1,n],'like',x));
    temp_deltaweight(1,:)=whi-wlo;

    while conTol>wtol






        wmid=sqrt(whi.*wlo);



        temp_prod=1+bsxfun(@times,wmid,beta);
        smid=sum(bsxfun(@rdivide,beta,temp_prod));



        smidNonZeroFlag=0;
        coder.gpu.kernel;
        for iter=1:numel(smid)
            if abs(smid(iter))<stol
                tmpweight(iter)=wmid(iter);
                smidNonZeroFlag=1;
            end
        end
        returnFlag=1;



        tmpweightNan=isnan(tmpweight);
        coder.gpu.kernel;
        for iter=1:numel(tmpweightNan)
            if tmpweightNan(iter)
                returnFlag=0;
            end
        end



        if smidNonZeroFlag&&returnFlag
            weight=tmpweight;
            return;
        end




        coder.gpu.kernel;
        for iter=1:numel(smid)
            if smid(iter)>0
                wlo(iter)=wmid(iter);
            elseif smid(iter)<0
                whi(iter)=wmid(iter);
            end
        end


        temp_deltaweight(ii+1,:)=whi-wlo;
        temp_Preii=temp_deltaweight(ii+1);
        temp_Postii=temp_deltaweight(ii);


        conTol=abs(temp_Preii-temp_Postii);
        ii=ii+1;
        if ii>maxiter
            break;
        end
    end

    tmpweight=sqrt(wlo.*whi);
    tmpweight(shi>=0)=1;

    coder.gpu.kernel;
    for iter=1:numel(slo)
        if slo(iter)<=0
            tmpweight(iter)=initialwlo(iter);
        end
    end


    deltaweight=repmat(temp_deltaweight(1:ii,:),1,n);
    weight=tmpweight;
end
