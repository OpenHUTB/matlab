function varargout=subsref(conIn,sub)












    try
        switch sub(1).type
        case '()'
            [varargout{1:nargout}]=subsrefParens(conIn,sub);
        case '.'
            [varargout{1:nargout}]=subsrefDot(conIn,sub);
        otherwise
            [varargout{1:nargout}]=builtin('subsref',conIn,sub);
        end
    catch E
        throwAsCaller(E);
    end
end

function varargout=subsrefParens(conIn,sub)



    indexNames=conIn.IndexNames;
    conIn.Expr1.IndexNames=indexNames;
    conIn.Expr2.IndexNames=indexNames;


    expr1Out=createSubsref(conIn.Expr1,sub);
    expr2Out=createSubsref(conIn.Expr2,sub);


    conOut=createConstraint(conIn,expr1Out,conIn.Relation,...
    expr2Out,expr1Out.IndexNames);
    if isscalar(sub)
        [varargout{1:nargout}]=conOut;
    else

        [varargout{1:nargout}]=subsref(conOut,sub(2:end));
    end
end

function varargout=subsrefDot(conIn,sub)


    optim.internal.problemdef.checkPublicPropertyOrMethod(conIn,sub(1).subs,...
    optim.problemdef.OptimizationConstraint.getPublicPropertiesAndSupportedHiddenMethods);


    [varargout{1:nargout}]=builtin('subsref',conIn,sub);
end
