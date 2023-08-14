function gradJac=SubsasgnAdjoint(inJac,indices,nElemRHS)









    numIndices=numel(indices);

    if numIndices==1

        gradJac=inJac(indices,:);
    else

        [uniqueIdx,rhsIdx]=unique(indices,'last');






        if nElemRHS==1
            if isscalar(uniqueIdx)

                gradJac=inJac(indices(1),:);
                return;
            else


                gradJac=sum(inJac(uniqueIdx,:),1);
                return;
            end
        end


        nUniqueIdx=numel(uniqueIdx);
        if nUniqueIdx==numIndices

            gradJac=inJac(uniqueIdx,:);
            return;
        end






        N=size(inJac,2);
        idx=repmat(rhsIdx,1,N);
        jdx=repmat(1:N,nUniqueIdx,1);
        val=inJac(uniqueIdx,:);
        gradJac=sparse(idx,jdx,val,nElemRHS,N);
    end



end
