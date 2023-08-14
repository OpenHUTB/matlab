function[centers,metric]=chcentersImpl(accumMatrixIn,suppThreshold)%#codegen

















    coder.allowpcode('plain');
    coder.inline('never');


    medFiltSize=coder.const(5);

    outputType=class(accumMatrixIn);
    centers=cast([],outputType);
    metric=cast([],outputType);
    sigma=cast([],outputType);

    accumMatrix=abs(accumMatrixIn);


    flat=isFlat(accumMatrix);
    if(flat)
        return;
    end

    if(~isempty(sigma))
        accumMatrix=gaussianFilter(accumMatrix,sigma);
    end



    if(min(size(accumMatrix))>medFiltSize)

        Hd=medfilt2(accumMatrix,[medFiltSize,medFiltSize]);
    else
        Hd=accumMatrix;
    end
    suppThreshold=max(suppThreshold-eps(suppThreshold),0);
    Hd=imhmax(Hd,suppThreshold);





    connb=coder.const(conndef(2,'maximal'));
    floatEpsilonFlag=coder.const(true);
    bw=images.internal.coder.gpu.imregionalmaxAlgoImpl(Hd,connb,floatEpsilonFlag);

    s=regionprops(bw,accumMatrix,'weightedcentroid');
    if(~isempty(s))

        centersCandidate=coder.nullcopy(zeros(numel(s),2,outputType));
        coder.gpu.kernel;
        for idx=1:numel(s)
            centersCandidate(idx,1)=s(idx).WeightedCentroid(1);
            centersCandidate(idx,2)=s(idx).WeightedCentroid(2);
        end


        centerIsNan=coder.nullcopy(zeros(numel(s),1));
        coder.gpu.kernel;
        for idx=1:size(centersCandidate,1)
            centerIsNan(idx)=isnan(centersCandidate(idx,1))||isnan(centersCandidate(idx,2));
        end
        validcenters=centersCandidate(~centerIsNan,:);
        centersCount=size(validcenters,1);

        if(~isempty(validcenters))

            metric=coder.nullcopy(zeros(centersCount,1,outputType));
            coder.gpu.kernel;
            for idx=1:centersCount
                metric(idx)=Hd(sub2ind(size(Hd),round(validcenters(idx,2)),round(validcenters(idx,1))));
            end

            [metric,sortIdx]=gpucoder.sort(metric,1,'descend');
            centers=validcenters(sortIdx,:);
        end
    end
end

function accumMatrix=gaussianFilter(accumMatrixIn,sigma)%#codegen

    coder.inline('always');

    filtSize=ceil(sigma*3);

    filtSize=min(filtSize+ceil(rem(filtSize,2)),min(size(accumMatrixIn)));
    gaussFilt=fspecial('gaussian',[filtSize,filtSize],sigma);
    accumMatrix=imfilter(accumMatrixIn,gaussFilt,'same');
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