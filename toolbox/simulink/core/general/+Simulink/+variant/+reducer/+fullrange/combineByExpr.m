function netCond=combineByExpr(conds,expr)






    narginchk(2,2);
    Simulink.variant.reducer.utils.assert(any(strcmp(expr,{'&&','||'})));
    netCond='';
    for i=1:numel(conds)
        if isempty(conds{i}),continue,end
        netCond=[netCond,'(',conds{i},') ',expr,' '];%#ok<AGROW>
    end
    if~isempty(netCond)
        netCond(end-3:end)=[];
        netCond=Simulink.variant.reducer.fullrange.FullRangeManager.simplifyVarCondExpr(netCond);
    end
    if isempty(netCond)

        netCond='true';
    end
end


