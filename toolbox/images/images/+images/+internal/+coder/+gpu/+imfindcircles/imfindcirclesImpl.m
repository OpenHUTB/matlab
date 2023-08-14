function[centers,rEstimated,metric]=imfindcirclesImpl(A,radiusRange,method,objPolarity,edgeThresh,sensitivity)%#codegen










































    coder.allowpcode('plain');


    Agray=getGrayImage(A);


    [accumReal,accumImag,gradientImg]=images.internal.coder.gpu.imfindcircles.chaccumImpl(...
    Agray,radiusRange,edgeThresh,method,objPolarity);
    accumMatrix=double(accumReal+1i.*accumImag);


    if(~anyImpl(accumMatrix(:)))
        centers=[];
        metric=[];
        rEstimated=[];
        return;
    end


    accumThresh=1-sensitivity;
    [centers,metric]=images.internal.coder.gpu.imfindcircles.chcentersImpl(...
    accumMatrix,accumThresh);


    if(isempty(centers))
        centers=[];
        metric=[];
        rEstimated=[];
        return;
    end


    metricids=1:numel(metric);
    idx2Keep=images.internal.coder.gpu.imfindcircles.findImpl(metricids,metric>=accumThresh);
    centers=centers(idx2Keep,:);
    metric=metric(idx2Keep,:);


    if(isempty(centers))
        centers=[];
        metric=[];
        rEstimated=[];
        return;
    end


    if(nargout>1)
        if(length(radiusRange)==1)
            rEstimated=repmat(cast(radiusRange,class(centers)),size(centers,1),1);
        else
            switch(method)
            case 'phasecode'
                rEstimated=images.internal.coder.gpu.imfindcircles.chradiiphcodeImpl(...
                centers,accumMatrix,radiusRange);
            case 'twostage'
                rEstimated=images.internal.coder.gpu.imfindcircles.chradiiImpl(...
                centers,gradientImg,radiusRange);
            otherwise

                rEstimated=[];
            end
        end
    end
end

function Aout=getGrayImage(A)%#codegen

    coder.inline('always');

    N=ndims(A);
    if(N==2)
        B=A(:,:,1);
        if(islogical(B))
            filtStd=coder.const(1.5);
            filtSize=ceil(filtStd*3);
            gaussFilt=fspecial('gaussian',[filtSize,filtSize],filtStd);
            Aout=imfilter(im2single(B),gaussFilt,'replicate');
        elseif(isinteger(B))
            Aout=im2single(B);
        else
            Aout=B;
        end
    else
        Agray=rgb2gray(uint16(A));
        if(isinteger(Agray))
            Aout=im2single(Agray);
        else
            Aout=Agray;
        end
    end

end

function flag=anyImpl(I)%#codegen

    flag=false;
    coder.gpu.kernel;
    for itr=1:numel(I)
        if I(itr)~=0
            flag=true;
        end
    end
end
