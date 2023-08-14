function varargout=subsref(obj,sub)














    try
        switch sub(1).type
        case '()'


            exprOut=createSubsref(obj,sub);
            if isscalar(sub)
                [varargout{1:nargout}]=exprOut;
            else
                [varargout{1:nargout}]=subsref(exprOut,sub(2:end));
            end

        case '.'


            optim.internal.problemdef.checkPublicPropertyOrMethod(obj,...
            sub(1).subs,optim.problemdef.OptimizationExpression.getPublicPropertiesAndSupportedHiddenMethods);

            [varargout{1:nargout}]=builtin('subsref',obj,sub);

        otherwise

            [varargout{1:nargout}]=builtin('subsref',obj,sub);
        end

    catch E
        throwAsCaller(E);
    end
end
