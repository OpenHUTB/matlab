function rangeData=convertFromCartesianToSphericalCoordinateImpl(xyzData)


%#codegen



    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    X=double(xyzData(:,:,1));
    Y=double(xyzData(:,:,2));
    Z=double(xyzData(:,:,3));

    range=coder.nullcopy(zeros(size(Z,1),size(Z,2),'like',X));
    pitch=coder.nullcopy(zeros(size(Z,1),size(Z,2),'like',X));
    yaw=coder.nullcopy(zeros(size(Z,1),size(Z,2),'like',X));

    coder.gpu.kernel;
    for rIter=1:size(Z,1)
        coder.gpu.kernel;
        for cIter=1:size(Z,2)
            range(rIter,cIter)=sqrt((X(rIter,cIter)*X(rIter,cIter))+...
            (Y(rIter,cIter)*Y(rIter,cIter))+(Z(rIter,cIter)*Z(rIter,cIter)));

            pitch(rIter,cIter)=asin(Z(rIter,cIter)/range(rIter,cIter));

            yaw(rIter,cIter)=atan2(X(rIter,cIter),Y(rIter,cIter));

            if yaw(rIter,cIter)<0
                yaw(rIter,cIter)=yaw(rIter,cIter)+2*pi;
            end
        end
    end


    rangeData=zeros(size(xyzData),'like',xyzData);
    rangeData(:,:,1)=cast(range,class(xyzData));
    rangeData(:,:,2)=cast(pitch,class(xyzData));
    rangeData(:,:,3)=cast(yaw,class(xyzData));
end

