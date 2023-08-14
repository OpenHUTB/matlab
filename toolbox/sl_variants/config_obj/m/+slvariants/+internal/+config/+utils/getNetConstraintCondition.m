function netCondition=getNetConstraintCondition(vcd)



    conditions={vcd.Constraints.Condition};
    enclosedConditions=cellfun(@(cond)['(',cond,')'],conditions,...
    'UniformOutput',false);
    netCondition=strjoin(enclosedConditions,' && ');
end
