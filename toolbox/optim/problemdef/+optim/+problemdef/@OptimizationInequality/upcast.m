function c=upcast(ineq)







    c=optim.problemdef.OptimizationConstraint(ineq.Expr1,...
    ineq.Relation,ineq.Expr2,ineq.Expr1.IndexNames);