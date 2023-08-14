function netCond=combineByOR(conds)




    narginchk(1,1);
    netCond=Simulink.variant.reducer.fullrange.combineByExpr(conds,'||');
end
