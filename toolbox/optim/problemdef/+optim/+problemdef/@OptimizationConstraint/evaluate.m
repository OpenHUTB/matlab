function evaluate(con,varargin)








    [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
    'doc','optim_evaluate_error','normal',true);

    throwAsCaller(MException(message('optim_problemdef:OptimizationConstraint:InvalidEvaluate',con.className,startTag,endTag)));

end
