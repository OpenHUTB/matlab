function isAllowed=isFixedPointProposalAllowed(constraintSet)




    isAllowed=true;
    for i=1:numel(constraintSet)
        constraint=constraintSet{i};
        if~constraint.allowsFixedPointProposals
            isAllowed=false;
            break;
        end
    end
end