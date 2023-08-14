function outputDDRVector=convert3DInputToDDRVectorFormatConv4(input3D,convThreadNum)


















































    outputDDRVector=cast(zeros(1,numel(input3D)),class(input3D));
    ind=1;

    for z=1:ceil(size(input3D,3)/convThreadNum)
        for k=1:size(input3D,1)
            for j=1:size(input3D,2)
                for i=1:convThreadNum
                    if ind>size(outputDDRVector,2)
                        break;
                    end
                    if i+(z-1)*convThreadNum>size(input3D,3)
                        continue;
                    end
                    outputDDRVector(ind)=input3D(k,j,i+(z-1)*convThreadNum);
                    ind=ind+1;
                end
            end
        end
    end
end

