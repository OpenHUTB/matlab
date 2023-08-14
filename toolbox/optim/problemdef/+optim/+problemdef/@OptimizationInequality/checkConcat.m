function checkConcat(~,relation,con2cat)









    if strcmp(relation,'==')
        throwAsCaller(MException(message(...
        'optim_problemdef:OptimizationInequality:CannotConcatWithEquality')));
    end


    thisRelation=getRelation(con2cat);
    if~isempty(thisRelation)&&~strcmp(thisRelation,relation)
        throwAsCaller(MException(message(...
        'optim_problemdef:OptimizationConstraint:OnlyOneRelationPerArray')));
    end

