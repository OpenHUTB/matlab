function[bins,binLocations]=pcbinImpl(inpPoints,numBins,inpLimits,binOutput)%#codegen

































    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');
    coder.inline('never')


    isOrganized=ndims(inpPoints)==3;
    if isOrganized
        numPoints=size(inpPoints,1)*size(inpPoints,2);
    else
        numPoints=size(inpPoints,1);
    end


    if size(inpLimits)==0
        tmpMat=inpPoints(1:numPoints);
        xLimits=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
        tmpMat=inpPoints(numPoints+1:numPoints*2);
        yLimits=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
        tmpMat=inpPoints(2*numPoints+1:numPoints*3);
        zLimits=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
    else
        xLimits=[inpLimits(1,1),inpLimits(1,2)];
        yLimits=[inpLimits(2,1),inpLimits(2,2)];
        zLimits=[inpLimits(3,1),inpLimits(3,2)];
    end


    limits=[xLimits;yLimits;zLimits];
    diffVal=(diff(limits,1,2)>=0);
    flag=~isequal(diffVal,true(3,1));
    coder.internal.errorIf(flag,'vision:pointcloud:limitsMustBeIncreasing','pcbin');


    xWidth=(xLimits(2)-xLimits(1))/numBins(1);
    yWidth=(yLimits(2)-yLimits(1))/numBins(2);
    zWidth=(zLimits(2)-zLimits(1))/numBins(3);
    width=[xWidth,yWidth,zWidth];


    xBinIndices=coder.nullcopy(zeros(numPoints,1));
    yBinIndices=coder.nullcopy(zeros(numPoints,1));
    zBinIndices=coder.nullcopy(zeros(numPoints,1));

    coder.gpu.kernel;
    for ptIter=1:numPoints
        xCoord=inpPoints(ptIter);
        yCoord=inpPoints(ptIter+numPoints);
        zCoord=inpPoints(ptIter+2*numPoints);


        if(isnan(xCoord)||isnan(yCoord)||isnan(zCoord))
            xBinIndices(ptIter)=0;
            yBinIndices(ptIter)=0;
            zBinIndices(ptIter)=0;


        elseif xCoord<xLimits(1)||xCoord>xLimits(2)||...
            yCoord<yLimits(1)||yCoord>yLimits(2)||...
            zCoord<zLimits(1)||zCoord>zLimits(2)
            xBinIndices(ptIter)=0;
            yBinIndices(ptIter)=0;
            zBinIndices(ptIter)=0;


        else
            xBinIndices(ptIter)=floor((xCoord-xLimits(1))/xWidth)+1;
            yBinIndices(ptIter)=floor((yCoord-yLimits(1))/yWidth)+1;
            zBinIndices(ptIter)=floor((zCoord-zLimits(1))/zWidth)+1;


            if xBinIndices(ptIter)>numBins(1)
                xBinIndices(ptIter)=numBins(1);

            elseif xWidth==0
                xBinIndices(ptIter)=numBins(1);

            elseif(isinf(xCoord))
                if xCoord>0
                    xBinIndices(ptIter)=numBins(1);
                else
                    xBinIndices(ptIter)=0;
                end
            end

            if yBinIndices(ptIter)>numBins(2)
                yBinIndices(ptIter)=numBins(2);

            elseif yWidth==0
                yBinIndices(ptIter)=numBins(2);

            elseif(isinf(yCoord))
                if yCoord>0
                    yBinIndices(ptIter)=numBins(2);
                else
                    yBinIndices(ptIter)=0;
                end
            end

            if zBinIndices(ptIter)>numBins(3)
                zBinIndices(ptIter)=numBins(3);

            elseif zWidth==0
                zBinIndices(ptIter)=numBins(3);

            elseif(isinf(zCoord))
                if zCoord>0
                    zBinIndices(ptIter)=numBins(3);
                else
                    zBinIndices(ptIter)=0;
                end
            end
        end
    end


    tempBinIndices=coder.nullcopy(zeros(numPoints,1));
    for ptIter=1:numPoints
        if~(isnan(inpPoints(ptIter))||isnan(inpPoints(ptIter+numPoints))||isnan(inpPoints(ptIter+2*numPoints)))&&xBinIndices(ptIter)~=0
            tempBinIndices(ptIter)=...
            ((zBinIndices(ptIter)-1)*numBins(1)*numBins(2))+...
            ((yBinIndices(ptIter)-1)*numBins(1))+xBinIndices(ptIter);
        else
            tempBinIndices(ptIter)=0;
        end
    end


    if binOutput==false

        tempBinLocations=coder.nullcopy(zeros(numPoints,6));
        for ptIter=1:numPoints
            if isnan(inpPoints(ptIter))||isnan(inpPoints(ptIter+numPoints))||isnan(inpPoints(ptIter+2*numPoints))||tempBinIndices(ptIter)==0
                tempBinLocations(ptIter,:)=NaN;
            else
                tempBinLocations(ptIter,1)=limits(1,1)+(xBinIndices(ptIter)-1)*width(1);



                if(xBinIndices(ptIter)==1&&isinf(width(1)))
                    tempBinLocations(ptIter,1)=limits(1,1);
                end
                tempBinLocations(ptIter,2)=limits(1,1)+(xBinIndices(ptIter))*width(1);



                tempBinLocations(ptIter,3)=limits(2,1)+(yBinIndices(ptIter)-1)*width(2);
                if(yBinIndices(ptIter)==1&&isinf(width(2)))
                    tempBinLocations(ptIter,3)=limits(2,1);
                end
                tempBinLocations(ptIter,4)=limits(2,1)+(yBinIndices(ptIter))*width(2);



                tempBinLocations(ptIter,5)=limits(3,1)+(zBinIndices(ptIter)-1)*width(3);
                if(zBinIndices(ptIter)==1&&isinf(width(3)))
                    tempBinLocations(ptIter,5)=limits(3,1);
                end
                tempBinLocations(ptIter,6)=limits(3,1)+(zBinIndices(ptIter))*width(3);
            end
        end


        for ptIter=1:numPoints
            if(isnan(inpPoints(ptIter))||isnan(inpPoints(ptIter+numPoints))||isnan(inpPoints(ptIter+2*numPoints))||tempBinIndices(ptIter)==0)
                tempBinIndices(ptIter)=NaN;
            end
        end


        if isOrganized
            bins=reshape(tempBinIndices,size(inpPoints,1),size(inpPoints,2));
            binLocations=reshape(tempBinLocations,size(inpPoints,1),size(inpPoints,2),6);
        else
            bins=tempBinIndices;
            binLocations=tempBinLocations;
        end

    else



        [indices,uniqBins,indexUniqValsEnd,countUniqVals]=getUniqueBinIndices(tempBinIndices,numPoints);


        bins=coder.nullcopy(cell(numBins(1),numBins(2),numBins(3)));



        lastUniquePosition=1;


        if isOrganized
            for ptr=1:countUniqVals
                if uniqBins(ptr)~=0
                    [pointRow,pointColumn]=...
                    ind2sub([size(inpPoints,1),size(inpPoints,2)],...
                    indices(lastUniquePosition:indexUniqValsEnd(ptr)));
                    bins{uniqBins(ptr)}=[pointRow,pointColumn];
                end

                lastUniquePosition=indexUniqValsEnd(ptr)+1;
            end

        else
            for ptr=1:countUniqVals
                if uniqBins(ptr)~=0
                    points=indices(lastUniquePosition:indexUniqValsEnd(ptr));
                    bins{uniqBins(ptr)}=points;
                end

                lastUniquePosition=indexUniqValsEnd(ptr)+1;
            end

        end


        binLocations=coder.nullcopy(cell(numBins(1),numBins(2),numBins(3)));
        if nargout>1
            for i=1:numBins(1)
                for j=1:numBins(2)
                    for k=1:numBins(3)
                        binLocations{i,j,k}=[limits(1,1)+(i-1)*width(1),limits(1,1)+(i)*width(1);...
                        limits(2,1)+(j-1)*width(2),limits(2,1)+(j)*width(2);...
                        limits(3,1)+(k-1)*width(3),limits(3,1)+(k)*width(3)];



                        if isinf(width(1))
                            if i==1
                                binLocations{i,j,k}(1,1)=limits(1,1);
                            end
                        end



                        if isinf(width(2))
                            if j==1
                                binLocations{i,j,k}(2,1)=limits(2,1);
                            end
                        end



                        if isinf(width(3))
                            if k==1
                                binLocations{i,j,k}(3,1)=limits(3,1);
                            end
                        end
                    end
                end
            end
        end
    end
end




function[indices,uniqBins,indexUniqValsEnd,countUniqVals]=getUniqueBinIndices(linearBinCoords,numPoints)
%#codegen

    [sortedBinCoords,indices]=gpucoder.sort(linearBinCoords);

    uniqBins=zeros(numPoints,1);
    indexUniqValsEnd=coder.nullcopy(zeros(numPoints,1));
    countUniqVals=1;



    uniqBins(countUniqVals)=sortedBinCoords(1);
    indexUniqValsEnd(countUniqVals)=1;
    for ptr=2:numPoints
        if sortedBinCoords(ptr)==uniqBins(countUniqVals)
            indexUniqValsEnd(countUniqVals)=ptr;
        else
            countUniqVals=countUniqVals+1;
            uniqBins(countUniqVals)=sortedBinCoords(ptr);
            indexUniqValsEnd(countUniqVals)=ptr;
        end
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