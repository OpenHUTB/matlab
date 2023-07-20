function bestConstraint=getClosestSolution(constraintValues,constraintValuesMustBeLessThan)
















    NaNValues=isnan(constraintValues);
    if~all(sum(NaNValues,2))
        allConstraints=FunctionApproximation.internal.localNormCalculator([constraintValues;constraintValuesMustBeLessThan]);
        allConstraints(NaNValues)=Inf;
        for c=1:size(constraintValues,2)
            allConstraints(allConstraints(1:end-1,c)<=allConstraints(end,c),c)=allConstraints(end,c);
        end
        distance=ones(size(allConstraints,1)-1,1);
        for i=1:(size(allConstraints,1)-1)
            distance(i)=norm((allConstraints(i,:)-allConstraints(end,:)),2);
        end
        bestConstraint=find(distance==min(distance));
        if~(size(bestConstraint,1)==1)
            searchColumn=1;
            while~(size(bestConstraint,1)==1)&&searchColumn<=size(constraintValues,2)&&size(constraintValues,2)~=1
                bestConstraint=bestConstraint(constraintValues(bestConstraint,searchColumn)==min(constraintValues(bestConstraint,searchColumn)));
                searchColumn=searchColumn+1;
            end
            if~(size(bestConstraint,1)==1)
                bestConstraint=bestConstraint(1);
            end
        end
    else
        bestConstraint=[];
    end
end
