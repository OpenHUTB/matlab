function[accumulatorReal,accumulatorImag,Gmag]=chaccumImpl(A,radiusRange,edgeThreshIn,method,objPolarity)%#codegen





















    coder.allowpcode('plain');




    if~coder.gpu.internal.isGpuEnabled
        computeDataType='double';
    else
        computeCapability=gpucoder.getComputeCapability;
        if computeCapability>=6.1
            computeDataType='double';
        else
            computeDataType='single';
        end
    end

    accumulatorReal=zeros(size(A),computeDataType);
    accumulatorImag=zeros(size(A),computeDataType);


    flat=isFlat(A);
    if(flat)
        Gmag=zeros(size(A,1),size(A,2),'single');
        return;
    end

    dimY=size(A,1);
    dimX=size(A,2);



    [Gx,Gy,Gmag]=imgradientgpu(A);
    GmagMax=gpucoder.reduce(Gmag(:),@funcMax);
    if isempty(edgeThreshIn)
        threshFactor=graythresh(Gmag./GmagMax);
        edgeThresh=double(threshFactor.*GmagMax);
    else
        edgeThresh=double(edgeThreshIn.*GmagMax);
    end



    radiusMin=double(radiusRange(1));
    if numel(radiusRange)==2
        radiusMax=double(radiusRange(2));
        radiusCount=(radiusMax-radiusMin)*2+1;
    else
        radiusMax=radiusMin;
        radiusCount=1;
    end
    votesReal=coder.nullcopy(zeros(radiusCount,1,computeDataType));
    votesImag=zeros(radiusCount,1,computeDataType);



    switch objPolarity
    case 'bright'
        polarityFactor=1;
    case 'dark'
        polarityFactor=-1;
    otherwise
        polarityFactor=0;
    end


    switch method
    case 'phasecode'
        coder.gpu.kernel;
        for itr=1:radiusCount
            currentRadius=radiusMin+0.5*(itr-1);
            if numel(radiusRange)==2
                phiLog=(2*pi*((log(currentRadius)-log(radiusMin))./(log(radiusMax)-log(radiusMin))))-pi;
            else
                phiLog=0;
            end
            vote=exp(1i*phiLog)./(2*pi*currentRadius);
            votesReal(itr)=real(vote);
            votesImag(itr)=imag(vote);
        end
    case 'twostage'
        coder.gpu.kernel;
        for itr=1:radiusCount
            currentRadius=radiusMin+0.5*(itr-1);
            votesReal(itr)=1./(2*pi*currentRadius);
        end
    end



    Gmagidx=1:numel(Gmag);
    Gmagpred=Gmag>edgeThresh;
    [edgeIdx,edgecount]=images.internal.coder.gpu.imfindcircles.findImpl(Gmagidx,Gmagpred(:));


    coder.gpu.kernel;
    for cntr=1:edgecount
        coder.gpu.kernel;
        for candidateItr=1:radiusCount
            pixelIdx=edgeIdx(cntr);
            [Ey,Ex]=ind2sub(size(A),pixelIdx);


            radius=radiusMin+0.5*(candidateItr-1);
            radius=radius*polarityFactor;
            candidateX=round(Ex-(radius.*(Gx(pixelIdx)./Gmag(pixelIdx))));
            candidateY=round(Ey-(radius.*(Gy(pixelIdx)./Gmag(pixelIdx))));

            insideX=candidateX>=1&candidateX<=dimX;
            insideY=candidateY>=1&candidateY<=dimY;
            validcandidate=(insideX&insideY);
            if validcandidate

                accumulatorReal(candidateY,candidateX)=gpucoder.atomicAdd(accumulatorReal(candidateY,candidateX)...
                ,votesReal(candidateItr));
                accumulatorImag(candidateY,candidateX)=gpucoder.atomicAdd(accumulatorImag(candidateY,candidateX)...
                ,votesImag(candidateItr));
            end
        end
    end
end

function[Gx,Gy,GMag]=imgradientgpu(I)%#codegen

    hy=coder.const(-fspecial('sobel'));
    hx=hy';

    Gx=imfilter(I,hx,'replicate','conv');
    Gy=imfilter(I,hy,'replicate','conv');

    GMag=single(hypot(Gx,Gy));
end

function c=funcMax(a,b)%#codegen
    c=max(a,b);
end

function flat=isFlat(I)%#codegen

    flat=true;
    coder.gpu.kernel;
    for itr=1:numel(I)
        if I(itr)~=I(1)
            flat=false;
        end
    end
end