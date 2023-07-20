function hatchVertexData=calculateHatchVertexData(hObj,vertexData,hatchspacing,hatchlength,hatchangle)







    x=vertexData(1,:).';
    y=vertexData(2,:).';
    z=vertexData(3,:).';

    lineLength=hObj.calculateSegmentLength(x,y,z);

    if hObj.HatchSpacingMode_I=="auto"
        nHatches=floor(lineLength./hatchspacing)+1;
    else
        nHatches=numel(0:hatchspacing:1);
    end

    if nHatches<3
        hatchVertexData=[];
        return
    end




    nHatches=min(nHatches,10000);

    hatches=zeros(2,3,nHatches);


    [hatchStartingVertexData,bins]=hObj.calculateHatchStartingVertexData(vertexData,nHatches);
    prevVertexData=vertexData(:,bins);
    nextVertexData=vertexData(:,bins+1);


    hatchEndingVertexData=hObj.calculateHatchEndingVertexData(hatchStartingVertexData,prevVertexData,nextVertexData,hatchlength,hatchangle);


    hatches(1,:,:)=hatchStartingVertexData;
    hatches(2,:,:)=hatchEndingVertexData;


    hatchVertexData=reshape(permute(hatches,[2,1,3]),3,[]);
end

