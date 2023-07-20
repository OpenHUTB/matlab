function shI=calculateSelectionHandleIndices(stripData,NumSHPerEdge)




    numEdges=numel(stripData)-1;
    eSH=nan(NumSHPerEdge,numEdges);
    for i=1:numEdges
        sdStart=stripData(i);
        sdEnd=stripData(i+1);
        numVerts=sdEnd-sdStart;
        entireSHIndices=(sdStart:sdEnd-1)';
        if(numVerts>NumSHPerEdge)
            eSH(1:NumSHPerEdge,i)=entireSHIndices(round(linspace(1,double(numVerts),NumSHPerEdge)));
        else
            eSH(1:numVerts,i)=entireSHIndices;
        end
    end


    shI=eSH(:);
    shI(isnan(shI))=[];

end
