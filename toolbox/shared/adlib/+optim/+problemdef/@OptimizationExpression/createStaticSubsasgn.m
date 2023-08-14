function eout=createStaticSubsasgn(elhs,index,erhs,PtiesVisitor)














    deleting=isnumeric(erhs)&&isequal(size(erhs),[0,0]);
    if deleting



        error('shared_adlib:static:SizeChangeDetected','The size of the LHS must not change');
    end



    if isnumeric(elhs)&&~isa(elhs,'optim.problemdef.OptimizationExpression')&&isequal(size(elhs),[0,0])
        elhs=optim.problemdef.OptimizationExpression([0,0],{{},{}});
    end


    try
        if~isa(erhs,'optim.problemdef.OptimizationExpression')
            erhs=optim.problemdef.OptimizationNumeric(erhs);
        end
    catch E
        throwAsCaller(E)
    end


    Op=optim.internal.problemdef.operator.StaticSubsasgn(elhs,index,PtiesVisitor);
    eout=createStaticAssignment(elhs,erhs,Op,PtiesVisitor);


