function[xden,denoisedcfs,origcfs,sigmahat,thr]=...
    donohoJohnstone(x,level,Lo_D,Hi_D,Lo_R,Hi_R,denoisemethod,threshrule,noisestimate)
%#codegen



    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');





    [cd,ca]=wavelet.internal.gpu.mdwtdecWdenoise(x,level,Lo_D,Hi_D);

    origcfs=coder.nullcopy(cell(1,level+1));
    numCoefsArr=coder.nullcopy(zeros(1,level,'like',x));



    coder.gpu.kernel;
    for j=1:level
        origcfs{j}=cd{j};
        numCoefsArr(j)=size(cd{j},1);
    end
    origcfs{level+1}=ca;
    numCoefs=sum(numCoefsArr)+size(ca,1);

    N=size(x,2);


    sigmahat=varest(x,cd,N,noisestimate,level);


    threst=threshest(x,cd,numCoefs,sigmahat,denoisemethod,level);
    thr=sigmahat.*threst;


    for lev=1:level

        cd{lev}=wthresh2(cd{lev},threshrule,thr(lev,:));
    end


    denoisedcfs=coder.nullcopy(cell(1,level+1));
    for j=1:level
        denoisedcfs{j}=cd{j};
    end
    denoisedcfs{level+1}=ca;



    xden=coder.nullcopy(zeros(size(x),'like',x));
    xden=wavelet.internal.gpu.mdwtrecWdenoise(cd,ca,level,Lo_R,Hi_R,size(x));

end


function sigmahat=varest(x,wavecfs,numsignals,levelmethod,numlevels)



    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');

    [~,n]=size(x);
    normfac=coder.const(-sqrt(2)*erfcinv(2*0.75));
    sigmahat=coder.nullcopy(NaN(numlevels,numsignals));


    if strcmpi(levelmethod,'LevelIndependent')
        sigmaest=coder.nullcopy(zeros(1,n,'like',x));


        wavecfs{1}=gpucoder.sort(abs(wavecfs{1}),1);
        coder.gpu.kernel;
        for iter=1:n
            len=size(wavecfs{1},1);
            if mod(len,2)
                tempVal=wavecfs{1}((len+1)/2,iter)*(1/normfac);
            else
                meanVal=wavecfs{1}(len/2,iter)+wavecfs{1}((len/2)+1,iter);
                tempVal=(meanVal/2)*(1/normfac);
            end


            if tempVal<realmin('double')
                tempVal=realmin('double');
            end
            sigmaest(iter)=tempVal;
        end

        coder.gpu.kernel;
        for iter=1:numlevels
            sigmahat(iter,:)=sigmaest;
        end


    elseif strcmpi(levelmethod,'LevelDependent')
        sigmaest=coder.nullcopy(zeros(numlevels,n,'like',x));


        for lev=1:numlevels
            wavecfs{lev}=gpucoder.sort(abs(wavecfs{lev}),1);
        end

        coder.gpu.kernel;
        for lev=1:numlevels
            for iter=1:n
                len=size(wavecfs{lev},1);
                if mod(len,2)
                    tempVal=wavecfs{lev}((len+1)/2,iter)*(1/normfac);
                else
                    meanVal=wavecfs{lev}(len/2,iter)+wavecfs{lev}((len/2)+1,iter);
                    tempVal=(meanVal/2)*(1/normfac);
                end


                if tempVal<realmin('double')
                    tempVal=realmin('double');
                end
                sigmaest(lev,iter)=tempVal;
            end
        end
        sigmahat=sigmaest;
    end

end


function thr=threshest(x,wavecfs,sz,sigmahat,denoisemethod,M)
    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');

    N=size(x,2);
    thr=coder.nullcopy(zeros(M,N,'like',x));


    if strcmpi(denoisemethod,'sqtwolog')||strcmpi(denoisemethod,'minimaxi')
        thrVal=thselect(ones(sz,N,'like',x),denoisemethod);
        thr=repmat(thrVal,M,1);
    else
        if isvector(x)
            coder.gpu.kernel;
            for jj=1:M
                temp=bsxfun(@rdivide,wavecfs{jj},sigmahat(jj,:));
                thr(jj)=thselect(temp,denoisemethod);
            end
        else
            coder.gpu.kernel;
            for jj=1:M
                temp=bsxfun(@rdivide,wavecfs{jj},sigmahat(jj,:));
                thr(jj,:)=thselect(temp,denoisemethod);
            end
        end
    end

end


function x=wthresh2(x,in2,t)

    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');

    temp_in2=char(in2);

    if strcmpi(temp_in2,'s')
        tmp=bsxfun(@minus,abs(x),t);
        tmp=(tmp+abs(tmp))/2;
        x=bsxfun(@times,sign(x),tmp);
    else
        temp=bsxfun(@gt,abs(x),t);
        x=x.*temp;
    end

end




