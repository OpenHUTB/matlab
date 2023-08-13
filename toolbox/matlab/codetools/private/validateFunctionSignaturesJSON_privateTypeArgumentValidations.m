function typeArgumentValidations=validateFunctionSignaturesJSON_privateTypeArgumentValidations()


    typeArgumentValidations={...
    @(p,idx,log)validateChoicesValidExpression(p,idx,log)...
    };

end

function[p,idx]=validateChoicesValidExpression(p,idx,log)
    if startsWith(p.token,"choices=")
        tree=mtree(p.token);
        if isempty(tree)||tree.select(1).kind=="ERR"
            log(p(idx),"matlabExpressionInvalid",p.token(9:end));
        end
    end
end
