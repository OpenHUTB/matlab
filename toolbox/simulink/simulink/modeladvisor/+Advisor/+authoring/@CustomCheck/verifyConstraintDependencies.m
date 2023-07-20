



function Constraints=verifyConstraintDependencies(Constraints)
    constraintIDs=Constraints.keys;
    adjacencyMatrix=zeros(length(constraintIDs),length(constraintIDs));

    IDIndexMap=containers.Map(constraintIDs,1:length(constraintIDs));


    for n=1:length(constraintIDs)
        constraint=Constraints(constraintIDs{n});


        if~isempty(constraint.getPreRequisiteConstraintIDs)
            dependentConstIDs=constraint.getPreRequisiteConstraintIDs;
            for ni=1:length(dependentConstIDs)



                if~Constraints.isKey(dependentConstIDs{ni})
                    DAStudio.error('Advisor:engine:CCPreRequisiteIDNotFound',...
                    dependentConstIDs{ni},class(constraint));
                end


                adjacencyMatrix(n,IDIndexMap(dependentConstIDs{ni}))=1;
            end
        end
    end


    origAdjacencyMatrix=adjacencyMatrix;
    for n=1:length(constraintIDs)
        adjacencyMatrix=adjacencyMatrix*origAdjacencyMatrix;

        if adjacencyMatrix==zeros(size(adjacencyMatrix))
            break;
        end

        if any(diag(adjacencyMatrix))
            DAStudio.error('Advisor:engine:CCDependencyCycle');
        end
    end



    for n=1:size(origAdjacencyMatrix,2)
        constraint=Constraints(constraintIDs{n});
        if~any(origAdjacencyMatrix(:,n))









            constraint.IsRootConstraint=true;
        else
            constraint.IsRootConstraint=false;
        end
        Constraints(constraintIDs{n})=constraint;
    end
end