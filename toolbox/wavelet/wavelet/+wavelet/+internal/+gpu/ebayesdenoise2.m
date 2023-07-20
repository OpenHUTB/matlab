function[imden,denoisedcfs,origcfs,S]=ebayesdenoise2(x,Lo_D,Hi_D,Lo_R,Hi_R,level,noiseestimate,threshold,noisedir,ns)





%#codegen


    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');

    if ns~=0
        shifts=wavelet.internal.getCycleSpinShifts2(ns);

    else
        shifts=[0;0;0];
    end


    N=size(shifts,2);



    imden=zeros(size(x),'like',x);



    if coder.internal.isConst(level)&&coder.internal.isConst(size(x))
        sx=coder.const(wavelet.internal.gpu.sizeOfCoefficientsWdenoise2(size(x),level,size(Lo_D(:)')));
    else
        sx=wavelet.internal.gpu.sizeOfCoefficientsWdenoise2(size(x),level,size(Lo_D(:)'));
    end

    sizeIter=0;
    for i=1:level
        sizeIter=sizeIter+(3*prod(sx(i+1,:)));
    end
    sizeIter=sizeIter+prod(sx(1,:));

    origcfs=coder.nullcopy(zeros(N,sizeIter,'like',x));
    denoisedcfs=coder.nullcopy(zeros(N,sizeIter,'like',x));


    for nt=1:N
        imcs=coder.nullcopy(zeros(size(x),'like',x));

        imcs=circshift(x,shifts(:,nt));



        [ca,cell_h,cell_v,cell_d,c]=wavelet.internal.gpu.wavedec2Impl(imcs,level,Lo_D,Hi_D);

        cfs=coder.nullcopy(cell(1,level));
        outcfs=coder.nullcopy(cell(1,level));


        if coder.internal.ndims(imcs)==2

            coder.gpu.kernel;
            for lev=1:level
                cfs{lev}=coder.nullcopy(zeros([size(cell_h{lev}),3],'like',x));
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
                cfs{lev}=coder.nullcopy(zeros([size(cell_h{lev},1),size(cell_h{lev},2),9],'like',x));
            end


            coder.gpu.kernel;
            for lev=1:level
                cfs{lev}(:,:,1:3)=cell_h{lev};
                cfs{lev}(:,:,4:6)=cell_v{lev};
                cfs{lev}(:,:,7:9)=cell_d{lev};
            end
        end


        if strcmpi(noiseestimate,'levelindependent')
            normfac=1/(-sqrt(2)*erfcinv(2*0.75));
            d1=wavelet.internal.getdetcoef2(c,sx,noisedir,1);

            numelD1=numel(d1);

            d1=gpucoder.sort(abs(d1));
            if mod(numelD1,2)
                vscale=d1((numelD1+1)/2)*normfac;
            else
                vscaleTemp=d1(numelD1/2)+d1((numelD1/2)+1);
                vscale=(vscaleTemp/2)*normfac;
            end

        end


        coder.gpu.kernel;
        for lev=1:level
            cfsLev=cfs{lev}(:);

            if strcmpi(noiseestimate,'leveldependent')
                outcfs{lev}=wavelet.internal.ebayesthresh(cfsLev,'leveldependent',...
                threshold,'decimated');

            elseif strcmpi(noiseestimate,'levelindependent')
                outcfs{lev}=wavelet.internal.ebayesthresh(cfsLev,vscale,...
                threshold,'decimated');
            end
        end


        imcurr=wavelet.internal.gpu.waverec2Impl(outcfs,ca,cell_h,cell_v,cell_d,level,Lo_R,Hi_R,sx);


        imcurr=circshift(imcurr,-shifts(:,nt));
        imden=imden*(nt-1)/nt+imcurr/nt;


        origcfs(nt,:)=c;

        startVal=sizeIter;
        for i=1:level
            endVal=startVal;
            startVal=startVal-3*prod(sx(level-i+2,:));
            denoisedcfs(nt,startVal+1:endVal)=outcfs{i}(:).';
            if i==level
                denoisedcfs(nt,1:prod(sx(level-i+2,:)))=ca(:).';
            end
        end
    end

    S=sx;
end



