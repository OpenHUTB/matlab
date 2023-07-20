


























classdef regionpropsGPUImpl %#codegen

    properties





        thresholdValuePerRegion=500;
    end

    methods(Static)

        function[stats,statsAlreadyComputed]=...
            ComputeAreaGPU(RegionLengths,NumObjects,stats,statsAlreadyComputed)





            if~statsAlreadyComputed.Area
                statsAlreadyComputed.Area=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                Area=coder.nullcopy(zeros(NumObjects,1));
                coder.gpu.kernel;
                for k=1:NumObjects
                    Area(k)=double(RegionLengths(k));
                end

                for k=1:NumObjects
                    stats(k).Area=Area(k);
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputePixelIdxListGPU(RegionIndices,RegionLengths,numObjs,stats,statsAlreadyComputed)






            if~statsAlreadyComputed.PixelIdxList
                statsAlreadyComputed.PixelIdxList=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);


                endPoints=cumsum(RegionLengths);
                startPoints=[1;endPoints(1:end)+1];


                for k=1:numObjs
                    PixelIdxList=zeros(RegionLengths(k),1,'like',RegionIndices);
                    for index=1:RegionLengths(k)
                        PixelIdxList(index)=RegionIndices(startPoints(k)+index-1);
                    end

                    if coder.isColumnMajor
                        stats(k).PixelIdxList=PixelIdxList;
                    else

                        stats(k).PixelIdxList=gpucoder.sort(PixelIdxList);
                    end
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeEquivDiameterGPU(RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.EquivDiameter
                statsAlreadyComputed.EquivDiameter=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                factor=2/sqrt(pi);
                EquivDiameter=coder.nullcopy(zeros(NumObjects,1));
                coder.gpu.kernel;
                for k=1:NumObjects
                    EquivDiameter(k)=factor*sqrt(double(RegionLengths(k)));
                end

                for k=1:NumObjects
                    stats(k).EquivDiameter=EquivDiameter(k);
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeCentroidGPU(imageSize,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.Centroid
                statsAlreadyComputed.Centroid=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;


                [startPoints,endPoints,RegIndXY]=...
                images.internal.coder.gpu.regionpropsGPUImpl.ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths);




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    for k=1:NumObjects
                        sumrVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),1),{@sumFunc});
                        sumcVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),2),{@sumFunc});
                        Centroid1=sumrVal(1)/double(RegionLengths(k));
                        Centroid2=sumcVal(1)/double(RegionLengths(k));
                        stats(k).Centroid=[Centroid1,Centroid2];

                    end
                else
                    Centroid=zeros(NumObjects,2);
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        for i=startPoints(k):endPoints(k)
                            Centroid(k,1)=Centroid(k,1)+RegIndXY(i,1)/double(RegionLengths(k));
                            Centroid(k,2)=Centroid(k,2)+RegIndXY(i,2)/double(RegionLengths(k));
                        end
                    end
                    for k=1:NumObjects
                        stats(k).Centroid=[Centroid(k,1),Centroid(k,2)];
                    end
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeBoundingBoxGPU(imageSize,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.BoundingBox
                statsAlreadyComputed.BoundingBox=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;


                [startPoints,endPoints,RegIndXY]=...
                images.internal.coder.gpu.regionpropsGPUImpl.ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths);




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    for k=1:NumObjects
                        minMaxrVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),2),{@minFunc,@maxFunc});
                        minMaxcVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),1),{@minFunc,@maxFunc});
                        BoundingBox1=minMaxcVal(1)-0.5;
                        BoundingBox2=minMaxrVal(1)-0.5;
                        BoundingBox3=minMaxcVal(2)-BoundingBox1+0.5;
                        BoundingBox4=minMaxrVal(2)-BoundingBox2+0.5;
                        stats(k).BoundingBox=[BoundingBox1,BoundingBox2,BoundingBox3,BoundingBox4];
                    end
                else
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        minrVal=coder.internal.inf;
                        maxrVal=-coder.internal.inf;
                        mincVal=coder.internal.inf;
                        maxcVal=-coder.internal.inf;
                        for i=startPoints(k):endPoints(k)
                            minrVal=min(minrVal,RegIndXY(i,2));
                            mincVal=min(mincVal,RegIndXY(i,1));
                            maxrVal=max(maxrVal,RegIndXY(i,2));
                            maxcVal=max(maxcVal,RegIndXY(i,1));
                        end
                        BoundingBox1=mincVal-0.5;
                        BoundingBox2=minrVal-0.5;
                        BoundingBox3=maxcVal-BoundingBox1+0.5;
                        BoundingBox4=maxrVal-BoundingBox2+0.5;
                        stats(k).BoundingBox=[BoundingBox1,BoundingBox2,BoundingBox3,BoundingBox4];
                    end
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeEllipseParamsGPU(imageSize,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)






            if~(statsAlreadyComputed.MajorAxisLength&&...
                statsAlreadyComputed.MinorAxisLength&&...
                statsAlreadyComputed.Orientation&&...
                statsAlreadyComputed.Eccentricity)
                statsAlreadyComputed.MajorAxisLength=true;
                statsAlreadyComputed.MinorAxisLength=true;
                statsAlreadyComputed.Eccentricity=true;
                statsAlreadyComputed.Orientation=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;


                [startPoints,endPoints,RegIndXY]=...
                images.internal.coder.gpu.regionpropsGPUImpl.ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths);

                MajorAxisLength=zeros(NumObjects,1);
                MinorAxisLength=zeros(NumObjects,1);
                Eccentricity=zeros(NumObjects,1);
                Orientation=zeros(NumObjects,1);




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        sumrVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),1),{@sumFunc});
                        sumcVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),2),{@sumFunc});
                        xbar=sumrVal(1)/double(RegionLengths(k));
                        ybar=sumcVal(1)/double(RegionLengths(k));
                        x=RegIndXY(startPoints(k):endPoints(k),1)-xbar;
                        y=-(RegIndXY(startPoints(k):endPoints(k),2)-ybar);
                        N=length(x);

                        uxx=gpucoder.reduce((x.^2),{@sumFunc});
                        uyy=gpucoder.reduce((y.^2),{@sumFunc});
                        uxy=gpucoder.reduce((x.*y),{@sumFunc});

                        uxx=uxx/N+1/12;
                        uyy=uyy/N+1/12;
                        uxy=uxy/N;


                        common=sqrt((uxx-uyy)^2+4*uxy^2);
                        MajorAxisLength(k)=2*sqrt(2)*sqrt(uxx+uyy+common);
                        MinorAxisLength(k)=2*sqrt(2)*sqrt(uxx+uyy-common);
                        Eccentricity(k)=2*sqrt((MajorAxisLength(k)/2)^2-...
                        (MinorAxisLength(k)/2)^2)/MajorAxisLength(k);


                        if(uyy>uxx)
                            num=uyy-uxx+sqrt((uyy-uxx)^2+4*uxy^2);
                            den=2*uxy;
                        else
                            num=2*uxy;
                            den=uxx-uyy+sqrt((uxx-uyy)^2+4*uxy^2);
                        end
                        if all(num(:)==0)&&all(den(:)==0)
                            Orientation(k)=0;
                        else
                            Orientation(k)=(180/pi)*atan(num/den);
                        end
                    end
                else
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        sumrVal=sum(RegIndXY(startPoints(k):endPoints(k),1));
                        sumcVal=sum(RegIndXY(startPoints(k):endPoints(k),2));
                        xbar=sumrVal/double(RegionLengths(k));
                        ybar=sumcVal/double(RegionLengths(k));
                        x=RegIndXY(startPoints(k):endPoints(k),1)-xbar;
                        y=-(RegIndXY(startPoints(k):endPoints(k),2)-ybar);
                        N=length(x);
                        uxx=sum(x.^2);
                        uyy=sum(y.^2);
                        uxy=sum(x.*y);

                        uxx=uxx/N+1/12;
                        uyy=uyy/N+1/12;
                        uxy=uxy/N;


                        common=sqrt((uxx-uyy)^2+4*uxy^2);
                        MajorAxisLength(k)=2*sqrt(2)*sqrt(uxx+uyy+common);
                        MinorAxisLength(k)=2*sqrt(2)*sqrt(uxx+uyy-common);
                        Eccentricity(k)=2*sqrt((MajorAxisLength(k)/2)^2-...
                        (MinorAxisLength(k)/2)^2)/MajorAxisLength(k);


                        if(uyy>uxx)
                            num=uyy-uxx+sqrt((uyy-uxx)^2+4*uxy^2);
                            den=2*uxy;
                        else
                            num=2*uxy;
                            den=uxx-uyy+sqrt((uxx-uyy)^2+4*uxy^2);
                        end
                        if(num==0)&&(den==0)
                            Orientation(k)=0;
                        else
                            Orientation(k)=(180/pi)*atan(num/den);
                        end

                    end
                end
                for k=1:NumObjects
                    stats(k).MajorAxisLength=MajorAxisLength(k);
                    stats(k).MinorAxisLength=MinorAxisLength(k);
                    stats(k).Eccentricity=Eccentricity(k);
                    stats(k).Orientation=Orientation(k);
                end

            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputePixelValuesGPU(BW,imageSize,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.PixelValues
                statsAlreadyComputed.PixelValues=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);



                [startPoints,~,RegIndXY]=...
                images.internal.coder.gpu.regionpropsGPUImpl.ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths);

                for k=1:NumObjects
                    PixelValues=zeros(RegionLengths(k),1,'like',BW);
                    for index=1:RegionLengths(k)
                        i=RegIndXY(startPoints(k)+index-1,1);
                        j=RegIndXY(startPoints(k)+index-1,2);
                        PixelValues(index)=BW(j,i);
                    end
                    stats(k).PixelValues=PixelValues;
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeWeightedCentroidGPU(BW,imageSize,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.WeightedCentroid
                statsAlreadyComputed.WeightedCentroid=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;


                [startPoints,endPoints,RegIndXY]=...
                images.internal.coder.gpu.regionpropsGPUImpl.ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths);

                numDims=numel(imageSize);

                if isreal(BW)
                    WeightedCentroid=coder.nullcopy(zeros(NumObjects,2));
                else
                    WeightedCentroid=coder.nullcopy(complex(zeros(NumObjects,2)));
                end




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        Intensity=BW(RegionIndices(startPoints(k):endPoints(k)));
                        sumIntensity=gpucoder.reduce(double(Intensity),{@sumFunc});
                        for n=1:numDims
                            M=gpucoder.reduce((RegIndXY(startPoints(k):endPoints(k),n).*...
                            double(Intensity(:))),{@sumFunc});
                            WeightedCentroid(k,n)=M(1)/sumIntensity(1);
                        end
                    end
                else
                    sumIntensity=zeros(NumObjects,1);
                    for k=1:NumObjects
                        for index=startPoints(k):endPoints(k)
                            sumIntensity(k)=sumIntensity(k)+double(BW(RegionIndices(index)));
                        end
                    end
                    M=zeros(NumObjects,numDims);
                    for k=1:NumObjects
                        for index=startPoints(k):endPoints(k)
                            for n=1:numDims
                                M(k,n)=M(k,n)+(RegIndXY(index,n)*double(BW(RegionIndices(index))));
                            end
                        end
                    end
                    for k=1:NumObjects
                        for n=1:numDims
                            WeightedCentroid(k,n)=M(k,n)/sumIntensity(k);
                        end
                    end
                end
                for k=1:NumObjects
                    stats(k).WeightedCentroid=WeightedCentroid(k,:);
                end

            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeExtentGPU(imageSize,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.Extent
                statsAlreadyComputed.Extent=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;


                [startPoints,endPoints,RegIndXY]=...
                images.internal.coder.gpu.regionpropsGPUImpl.ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths);

                Extent=coder.nullcopy(zeros(NumObjects,1));
                Area=coder.nullcopy(zeros(NumObjects,1));




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        Area(k)=double(RegionLengths(k));
                        minMaxrVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),2),{@minFunc,@maxFunc});
                        minMaxcVal=gpucoder.reduce(RegIndXY(startPoints(k):endPoints(k),1),{@minFunc,@maxFunc});
                        BoundingBox1=minMaxcVal(1)-0.5;
                        BoundingBox2=minMaxrVal(1)-0.5;
                        BoundingBox3=minMaxcVal(2)-BoundingBox1+0.5;
                        BoundingBox4=minMaxrVal(2)-BoundingBox2+0.5;
                        Extent(k)=Area(k)/(BoundingBox3*BoundingBox4);
                    end
                else
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        minrVal=coder.internal.inf;
                        maxrVal=-coder.internal.inf;
                        mincVal=coder.internal.inf;
                        maxcVal=-coder.internal.inf;
                        for i=startPoints(k):endPoints(k)
                            minrVal=min(minrVal,RegIndXY(i,2));
                            mincVal=min(mincVal,RegIndXY(i,1));
                            maxrVal=max(maxrVal,RegIndXY(i,2));
                            maxcVal=max(maxcVal,RegIndXY(i,1));
                        end
                        Area(k)=double(RegionLengths(k));
                        BoundingBox1=mincVal-0.5;
                        BoundingBox2=minrVal-0.5;
                        BoundingBox3=maxcVal-BoundingBox1+0.5;
                        BoundingBox4=maxrVal-BoundingBox2+0.5;
                        Extent(k)=Area(k)/(BoundingBox3*BoundingBox4);
                    end
                end
                for k=1:NumObjects
                    if(Area(k)==0)

                        stats(k).Extent=coder.internal.nan(1);
                    else
                        stats(k).Extent=Extent(k);
                    end
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputePixelListGPU(imageSize,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)






            if~statsAlreadyComputed.PixelList
                statsAlreadyComputed.PixelList=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);



                [startPoints,~,RegIndXY]=...
                images.internal.coder.gpu.regionpropsGPUImpl.ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths);

                for k=1:NumObjects
                    PixelList=zeros(RegionLengths(k),2);
                    for index=1:RegionLengths(k)
                        PixelList(index,1)=RegIndXY(startPoints(k)+index-1,1);
                        PixelList(index,2)=RegIndXY(startPoints(k)+index-1,2);
                    end
                    stats(k).PixelList=PixelList;
                end

            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeMeanIntensityGPU(BW,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.MeanIntensity
                statsAlreadyComputed.MeanIntensity=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;

                endPoints=cumsum(RegionLengths);
                startPoints=[1;endPoints(1:end-1)+1];


                MeanIntensity=zeros(NumObjects,1);




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        sumVal=gpucoder.reduce(double(BW(RegionIndices(startPoints(k):endPoints(k)))),{@sumFunc});
                        MeanIntensity(k)=sumVal/double(RegionLengths(k));
                    end

                else
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        for i=startPoints(k):endPoints(k)
                            MeanIntensity(k)=MeanIntensity(k)+double(BW(RegionIndices(i)))/double(RegionLengths(k));
                        end
                    end
                end
                for k=1:NumObjects
                    stats(k).MeanIntensity=MeanIntensity(k);
                end
            end
        end

        function[stats,statsAlreadyComputed]=...
            ComputeMinIntensityGPU(BW,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)



            if~statsAlreadyComputed.MinIntensity
                statsAlreadyComputed.MinIntensity=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;

                endPoints=cumsum(RegionLengths);
                startPoints=[1;endPoints(1:end-1)+1];


                MinIntensity=coder.nullcopy(zeros(NumObjects,1,'like',BW));




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        tmp=BW(RegionIndices(startPoints(k):endPoints(k)));
                        minVal=gpucoder.reduce(tmp,{@minFunc});
                        MinIntensity(k)=minVal;
                    end
                else
                    for k=1:NumObjects
                        tmp=BW(RegionIndices(startPoints(k):endPoints(k)));
                        minVal=min(tmp(:));
                        MinIntensity(k)=minVal;
                    end
                end

                for k=1:NumObjects
                    stats(k).MinIntensity=MinIntensity(k);
                end
            end
        end


        function[stats,statsAlreadyComputed]=...
            ComputeMaxIntensityGPU(BW,RegionIndices,RegionLengths,NumObjects,stats,statsAlreadyComputed)


            if~statsAlreadyComputed.MaxIntensity
                statsAlreadyComputed.MaxIntensity=true;


                coder.allowpcode('plain');

                coder.gpu.internal.kernelfunImpl(false);

                AveragePixelsPerRegion=length(RegionIndices)/NumObjects;

                endPoints=cumsum(RegionLengths);
                startPoints=[1;endPoints(1:end-1)+1];


                MaxIntensity=coder.nullcopy(zeros(NumObjects,1,'like',BW));




                if AveragePixelsPerRegion>...
                    images.internal.coder.gpu.regionpropsGPUImpl.thresholdValuePerRegion
                    coder.gpu.kernel;
                    for k=1:NumObjects
                        tmp=BW(RegionIndices(startPoints(k):endPoints(k)));
                        maxVal=gpucoder.reduce(tmp,{@maxFunc});
                        MaxIntensity(k)=maxVal;
                    end
                else
                    for k=1:NumObjects
                        tmp=BW(RegionIndices(startPoints(k):endPoints(k)));
                        maxVal=max(tmp(:));
                        MaxIntensity(k)=maxVal;
                    end
                end

                for k=1:NumObjects
                    stats(k).MaxIntensity=MaxIntensity(k);
                end
            end
        end

        function[startPoints,endPoints,RegIndXY]=...
            ComputeXYPixelListGPU(imageSize,RegionIndices,RegionLengths)





            endPoints=cumsum(RegionLengths);
            startPoints=[1;endPoints(1:end)+1];



            RegIndXY=coder.nullcopy(zeros(length(RegionIndices),2,'like',RegionIndices));
            for i=1:length(RegionIndices)
                [RegIndXY(i,2),RegIndXY(i,1)]=ind2sub(imageSize,RegionIndices(i));
            end
        end
    end
end



function c=minFunc(a,b)
    if isnan(a)&&isnan(b)
        c=a;
    elseif isnan(a)
        c=b;
    elseif isnan(b)
        c=a;
    else
        c=min(a,b);
    end
end


function c=maxFunc(a,b)
    if isnan(a)&&isnan(b)
        c=a;
    elseif isnan(a)
        c=b;
    elseif isnan(b)
        c=a;
    else
        c=max(a,b);
    end
end


function c=sumFunc(a,b)
    c=a+b;
end