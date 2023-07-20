function output3D=convertDDRVectorFormatConv4To3DOutput(inputDDRVector,...
    convThreadNum,output3DSize)













































    outputVector=cast(zeros(1,length(inputDDRVector)),class(inputDDRVector));
    ind=1;



    if output3DSize(3)<convThreadNum
        sZ=output3DSize(3);
    else
        sZ=convThreadNum;
    end

    sY=output3DSize(1);
    sX=output3DSize(2);
    totalMemoryBlockSize=prod([sY,sX,sZ]);
    totalXYBlockSize=prod([sY,sX]);


    numZs=ceil(output3DSize(3)/sZ);
    for i=1:numZs



        delZ=min(output3DSize(3)-sZ*(i-1),sZ);
        for j=1:delZ
            for k=1:totalXYBlockSize



                posInMemoryBlock=(k-1)*delZ+j;

                outputVector(ind)=inputDDRVector(posInMemoryBlock+(i-1)*totalMemoryBlockSize);
                ind=ind+1;
            end
        end
    end


    output3DSizeNew=[output3DSize(2),output3DSize(1),output3DSize(3)];
    output3Dtemp=reshape(outputVector,output3DSizeNew);
    output3D=zeros(output3DSize(1),output3DSize(2),output3DSize(3));
    for i=1:size(output3Dtemp,3)
        output3D(:,:,i)=output3Dtemp(:,:,i)';
    end

end

