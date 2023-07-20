function checkConcat(~,~,con2cat)









    canCon=strcmp(getRelation(con2cat),'==');
    if~canCon
        throwAsCaller(MException(message(...
        'optim_problemdef:OptimizationEquality:CannotConcatWithInequality')));
    end
