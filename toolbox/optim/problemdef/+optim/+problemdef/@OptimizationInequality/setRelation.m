function ineq=setRelation(ineq,relation)







    if any(strcmp(relation,{'<=','>='}))
        ineq.Relation=relation;
    else
        error(message("optim_problemdef:OptimizationInequality:OnlyOneRelationPerArray"));
    end
