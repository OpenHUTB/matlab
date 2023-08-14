function gradJac=SubsrefAdjoint(gradJac,inJac,indices)








    numIndices=numel(indices);

    if numIndices==1

        gradJac(indices,:)=inJac;
    else





        [uniqueIdx,~,idxName]=unique(indices);


        if isscalar(uniqueIdx)
            gradJac(uniqueIdx,:)=sum(inJac,1);
            return;
        end


        nUniqueIdx=numel(uniqueIdx);
        if~isequal(nUniqueIdx,numIndices)


            Mat=sparse(idxName,1:numIndices,ones(1,numIndices),nUniqueIdx,numIndices);
            gradJac(uniqueIdx,:)=Mat*inJac;
            return;
        end



        gradJac(indices,:)=inJac;
    end



end
