function c=upcast(equ)







    c=optim.problemdef.OptimizationConstraint(equ.Expr1,'==',...
    equ.Expr2,equ.Expr1.IndexNames);
