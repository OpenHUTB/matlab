function[outLoc,outCol,outNormal,outIntensity,outRangeData]=...
    indexBasedSelection(inpLoc,inpCol,inpNormal,...
    inpIntensity,inpRangeData,selectedIndexArray)
%#codegen














    coder.gpu.kernelfun;
    coder.inline('always');
    coder.allowpcode('plain');


    isOrganized=ndims(inpLoc)==3;
    [sz1,sz2,~]=size(inpLoc);
    if isOrganized
        numPoints=sz1*sz2;
    else
        numPoints=sz1;
    end


    selectionMat=zeros(numPoints,1,'uint32');
    for i=1:length(selectedIndexArray)
        selectionMat(selectedIndexArray(i))=1;
    end
    selectedIdx=cumsum(selectionMat);




    outSize=uint32(0);
    for i=1:2
        outSize=selectedIdx(numPoints);
    end


    outLoc=coder.nullcopy(zeros(numPoints,3,'like',inpLoc));
    coder.gpu.kernel;
    for i=1:numPoints
        if selectionMat(i)
            outLoc(selectedIdx(i),1)=inpLoc(i);
            outLoc(selectedIdx(i),2)=inpLoc(i+numPoints);
            outLoc(selectedIdx(i),3)=inpLoc(i+2*numPoints);
        end
    end
    outLoc=outLoc(1:outSize,:);


    if~isempty(inpCol)
        outCol=coder.nullcopy(zeros(numPoints,3,'like',inpCol));
        coder.gpu.kernel;
        for i=1:numPoints
            if selectionMat(i)
                outCol(selectedIdx(i),1)=inpCol(i);
                outCol(selectedIdx(i),2)=inpCol(i+numPoints);
                outCol(selectedIdx(i),3)=inpCol(i+2*numPoints);
            end
        end
        outCol=outCol(1:outSize,:);
    else
        outCol=zeros(0,0,'like',inpCol);
    end


    if~isempty(inpNormal)
        outNormal=coder.nullcopy(zeros(numPoints,3,'like',inpNormal));
        coder.gpu.kernel;
        for i=1:numPoints
            if selectionMat(i)
                outNormal(selectedIdx(i),1)=inpNormal(i);
                outNormal(selectedIdx(i),2)=inpNormal(i+numPoints);
                outNormal(selectedIdx(i),3)=inpNormal(i+2*numPoints);
            end
        end
        outNormal=outNormal(1:outSize,:);
    else
        outNormal=zeros(0,0,'like',inpNormal);
    end


    if~isempty(inpIntensity)
        outIntensity=coder.nullcopy(zeros(numPoints,1,'like',inpIntensity));
        coder.gpu.kernel;
        for i=1:numPoints
            if selectionMat(i)
                outIntensity(selectedIdx(i),1)=inpIntensity(i);
            end
        end
        outIntensity=outIntensity(1:outSize);
    else
        outIntensity=zeros(0,0,'like',inpIntensity);
    end


    if~isempty(inpRangeData)
        outRangeData=coder.nullcopy(zeros(numPoints,3,'like',inpRangeData));
        coder.gpu.kernel;
        for i=1:numPoints
            if selectionMat(i)
                outRangeData(selectedIdx(i),1)=inpRangeData(i);
                outRangeData(selectedIdx(i),2)=inpRangeData(i+numPoints);
                outRangeData(selectedIdx(i),3)=inpRangeData(i+2*numPoints);
            end
        end
        outRangeData=outRangeData(1:outSize,:);
    else
        outRangeData=zeros(0,0,'like',inpRangeData);
    end
end
