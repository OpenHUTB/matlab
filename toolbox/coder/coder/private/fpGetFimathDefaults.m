function[roundingMethod,overflowAction]=fpGetFimathDefaults(fimathExpr)
    fm=eval(fimathExpr);
    roundingMethod=fm.RoundingMethod;
    overflowAction=fm.OverflowAction;
end