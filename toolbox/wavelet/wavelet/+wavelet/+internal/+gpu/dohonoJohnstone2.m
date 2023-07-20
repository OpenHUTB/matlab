function[imden,Cden,C,S,sigmahat,thr]=dohonoJohnstone2(im,level,Lo_D,Hi_D,Lo_R,Hi_R,denoisemethod,threshrule,noiseestimate,noisedir,ns)





%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');

    if strcmpi(threshrule,"hard")
        threshrule='h';
    else
        threshrule='s';
    end


    if strcmpi(denoisemethod,"universalthreshold")
        temp_denoisemethod='sqtwolog';
    elseif strcmpi(denoisemethod,"minimax")
        temp_denoisemethod='minimaxi';
    else
        temp_denoisemethod='rigrsure';
    end
    N=1;
    if ns~=0
        shifts=wavelet.internal.getCycleSpinShifts2(ns);
        N=size(shifts,2);
    else
        shifts=[0;0;0];
    end

    if strcmpi(noiseestimate,'leveldependent')
        sigmahat=coder.nullcopy(zeros(level,N,'like',im));
    else
        sigmahat=coder.nullcopy(zeros(1,N,'like',im));
    end



    imden=zeros(size(im),'like',im);



    if coder.internal.isConst(level)&&coder.internal.isConst(size(im))
        sx=coder.const(wavelet.internal.gpu.sizeOfCoefficientsWdenoise2(size(im),level,size(Lo_D(:)')));
    else
        sx=wavelet.internal.gpu.sizeOfCoefficientsWdenoise2(size(im),level,size(Lo_D(:)'));
    end

    sizeIter=0;
    for i=1:level
        sizeIter=sizeIter+(3*prod(sx(i+1,:)));
    end
    sizeIter=sizeIter+prod(sx(1,:));

    Cden=coder.nullcopy(zeros(1,sizeIter*N,'like',im));
    C=coder.nullcopy(zeros(1,sizeIter*N,'like',im));


    for nt=1:N
        imcs=coder.nullcopy(zeros(size(im),'like',im));

        imcs=circshift(im,shifts(:,nt));



        [ca,cell_h,cell_v,cell_d,c]=wavelet.internal.gpu.wavedec2Impl(imcs,level,Lo_D,Hi_D);

        cfs=coder.nullcopy(cell(1,level));


        if coder.internal.ndims(imcs)==2

            coder.gpu.kernel;
            for lev=1:level
                cfs{lev}=coder.nullcopy(zeros([size(cell_h{lev}),3],'like',im));
            end


            coder.gpu.kernel;
            for lev=1:level
                cfs{lev}(:,:,1)=cell_h{lev};
                cfs{lev}(:,:,2)=cell_v{lev};
                cfs{lev}(:,:,3)=cell_d{lev};
            end
        elseif coder.internal.ndims(imcs)==3

            coder.gpu.kernel;
            for lev=1:level
                cfs{lev}=coder.nullcopy(zeros([size(cell_h{lev},1),size(cell_h{lev},2),9],'like',im));
            end


            coder.gpu.kernel;
            for lev=1:level
                cfs{lev}(:,:,1:3)=cell_h{lev};
                cfs{lev}(:,:,4:6)=cell_v{lev};
                cfs{lev}(:,:,7:9)=cell_d{lev};
            end
        end


        sigmahat(:,nt)=varest(c,sx,level,noiseestimate,noisedir);

        threst=threshest(cfs,sizeIter,sigmahat(:,nt),temp_denoisemethod,level);
        thr=bsxfun(@times,threst,sigmahat(:,nt));
        outcfs=coder.nullcopy(cell(1,level));

        coder.gpu.kernel;
        for lev=1:level
            cfsLev=cfs{lev}(:);


            if strcmpi(noiseestimate,'levelindependent')&&...
                (strcmpi(temp_denoisemethod,"sqtwolog")||strcmpi(temp_denoisemethod,"minimaxi"))

                outcfs{lev}=wthresh2(cfsLev,threshrule,thr);
            else

                outcfs{lev}=wthresh2(cfsLev,threshrule,thr(lev));
            end
        end


        imcurr=wavelet.internal.gpu.waverec2Impl(outcfs,ca,cell_h,cell_v,cell_d,level,Lo_R,Hi_R,sx);


        imcurr=circshift(imcurr,-shifts(:,nt));
        imden=imden*(nt-1)/nt+imcurr/nt;


        C(1,((nt-1)*sizeIter)+1:nt*sizeIter)=c;


        startVal=nt*sizeIter;
        for i=1:level
            endVal=startVal;
            startVal=startVal-3*prod(sx(level-i+2,:));
            Cden(1,startVal+1:endVal)=outcfs{i}(:).';
            if i==level
                Cden(1,((nt-1)*sizeIter)+1:((nt-1)*sizeIter)+(prod(sx(level-i+2,:))))=ca(:).';
            end
        end

    end
    S=sx;
end


function sigmahat=varest(c,sx,numlevels,levelmethod,noisedir)



    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');




    normfac=-sqrt(2)*erfcinv(2*0.75);

    if strcmpi(levelmethod,'LevelIndependent')
        wavecfs=wavelet.internal.getdetcoef2(c,sx,noisedir,1);

        numelWaveCfs=numel(wavecfs);

        wavecfs=gpucoder.sort(abs(wavecfs));
        if mod(numelWaveCfs,2)
            sigmaest=wavecfs((numelWaveCfs+1)/2)*(1/normfac);
        else
            vscaleTemp=wavecfs(numelWaveCfs/2)+wavecfs((numelWaveCfs/2)+1);
            sigmaest=(vscaleTemp/2)*(1/normfac);
        end


        if sigmaest<realmin('double')
            sigmaest=realmin('double');
        end
        sigmahat=sigmaest;
    elseif strcmpi(levelmethod,'LevelDependent')
        sigmahat=coder.nullcopy(NaN(numlevels,1));
        for lev=1:numlevels
            wavecfs=wavelet.internal.getdetcoef2(c,sx,noisedir,lev);
            numelWaveCfs=numel(wavecfs);


            wavecfs=gpucoder.sort(abs(wavecfs));
            if mod(numelWaveCfs,2)
                sigmaest=wavecfs((numelWaveCfs+1)/2)*(1/normfac);
            else
                vscaleTemp=wavecfs(numelWaveCfs/2)+wavecfs((numelWaveCfs/2)+1);
                sigmaest=(vscaleTemp/2)*(1/normfac);
            end



            if sigmaest<realmin('double')
                sigmaest=realmin('double');
            end
            sigmahat(lev)=sigmaest;
        end
    else
        sigmahat=NaN(numlevels,1);
    end
end


function thr=threshest(wavecfs,sizeIter,sigmahat,denoisemethod,level)

    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');

    levsigma=sigmahat;
    if strcmpi(denoisemethod,'sqtwolog')||strcmpi(denoisemethod,'minimaxi')
        thr=thselect(ones(sizeIter,1),denoisemethod);
    else
        thr=coder.nullcopy(zeros(level,1));
        if numel(sigmahat)~=level
            levsigma=repmat(sigmahat,level,1);
        end

        coder.gpu.kernel;
        for lev=1:level
            cfs=wavecfs{lev}(:);
            thr(lev)=thselect(cfs./levsigma(lev,:),denoisemethod);
        end

    end
end


function xRet=wthresh2(x,in2,t)

    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');

    temp_in2=char(in2);
    xRet=zeros(size(x),'like',x);

    if strcmpi(temp_in2,'s')
        coder.gpu.kernel;
        for xIter=1:numel(x)
            tmp=abs(x(xIter))-t;
            tmp=(tmp+abs(tmp))/2;
            xRet(xIter)=sign(x(xIter))*tmp;
        end
    else
        temp=bsxfun(@gt,abs(x),t);
        xRet=x.*temp;
    end

end
