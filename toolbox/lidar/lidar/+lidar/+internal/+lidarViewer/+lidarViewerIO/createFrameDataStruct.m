







function frameData=createFrameDataStruct(ptCld,scalar)
    frameData=struct();
    frameData.PointCloud=ptCld;
    if nargin==1
        scalar=[];
    end
    frameData.ScalarData=scalar;
end