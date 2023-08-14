function CompositeConstraints=verifyCompositeConstraintDependencies(CompositeConstraints,Constraints)
    for i=1:numel(CompositeConstraints)
        ids=CompositeConstraints{i}.getConstraintIDs();
        for j=1:numel(ids)

            if~Constraints.isKey(ids{j})
                DAStudio.error('Advisor:engine:CCPreRequisiteIDNotFound',...
                ids{j},class(CompositeConstraints{i}));
            end

            constraintObjForId=Constraints(ids{j});
            if(constraintObjForId.IsRootConstraint)
                CompositeConstraints{i}.addConstraintObject(constraintObjForId);
            else
                DAStudio.error('Advisor:engine:InvalidConstraintInComposite');
            end
        end
    end
end

