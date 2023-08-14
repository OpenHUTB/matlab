function rEstimated=chradiiImpl(centers,gradientImg,radiusRange)%#codegen
















    coder.allowpcode('plain');

    rEstimated=coder.nullcopy(zeros(size(centers,1),1,'like',centers));
    [M,N]=size(gradientImg);






    for k=1:size(centers,1)

        left=max(floor(centers(k,1)-radiusRange(2)),1);
        right=min(ceil(centers(k,1)+radiusRange(2)),N);
        top=max(floor(centers(k,2)-radiusRange(2)),1);
        bottom=min(ceil(centers(k,2)+radiusRange(2)),M);

        bins=cast(radiusRange(1):radiusRange(2),class(centers));
        hist=zeros(size(bins),'like',gradientImg);
        coder.gpu.kernel;
        for rowitr=left:right
            coder.gpu.kernel;
            for colitr=top:bottom


                yEdge=colitr;
                xEdge=rowitr;
                xCandidate=centers(k,1);
                yCandidate=centers(k,2);
                dx=double(xEdge-xCandidate);
                dy=double(yEdge-yCandidate);

                radius=hypot(dx,dy);
                radius=round(radius);


                keep=(radius>=radiusRange(1))&(radius<=radiusRange(2));
                if keep
                    binIdx=(radius-radiusRange(1))+1;
                    gradientAdj=gradientImg(colitr,rowitr)./(2.*pi.*radius);
                    hist(binIdx)=gpucoder.atomicAdd(hist(binIdx),gradientAdj);
                end
            end
        end


        [~,idx]=max(hist);
        rEstimated(k)=bins(idx);
    end
end
