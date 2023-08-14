
function[xyzPoints,alignedFlippedImage]=visionKinectColorToSkeleton(depthDevice,...
    depthImage,colorImage,isDepthCentric,isVersionOne)
    if isDepthCentric
        xyzPoints=vision.internal.visionKinectDepthToSkeleton(depthDevice,depthImage);
        alignedFlippedImage=adjustColorToDepth(depthDevice,depthImage,colorImage);
    else
        if isVersionOne




            alignmentMap=imaq.internal.KinectColor2DepthMap(depthDevice,depthImage);
            newDepthImage=uint16(alignmentMap(:,:,3));
            xyzPoints=vision.internal.visionKinectDepthToSkeleton(depthDevice,newDepthImage);
        else
            xyzPoints=imaq.internal.KinectColor2Skeleton(depthDevice,depthImage);
        end

        alignedFlippedImage=fliplr(colorImage);
    end




    function alignedFlippedImage=adjustColorToDepth(depthDevice,depthImage,colorImage)


        alignmentMap=vision.internal.visionKinectDepthToColorMap(depthDevice,depthImage);

        X=alignmentMap(:,:,1);
        Y=alignmentMap(:,:,2);


        validXRange=(X>=1)&(X<=size(colorImage,2));
        validYRange=(Y>=1)&(Y<=size(colorImage,1));
        validIndex=find(validXRange&validYRange);

        newIndex=sub2ind(size(colorImage),Y(validIndex),X(validIndex));


        alignedFlippedImage=zeros(size(depthImage,1),size(depthImage,2),3,'like',colorImage);
        szImgC=size(colorImage,1)*size(colorImage,2);
        szImgD=size(depthImage,1)*size(depthImage,2);
        alignedFlippedImage(validIndex)=colorImage(newIndex);
        alignedFlippedImage(validIndex+szImgD)=colorImage(newIndex+szImgC);
        alignedFlippedImage(validIndex+szImgD*2)=colorImage(newIndex+szImgC*2);


        alignedFlippedImage=fliplr(alignedFlippedImage);
