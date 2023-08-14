function obj=subsasgn(obj,sub,expr)
















    try
        switch sub(1).type
        case '()'

            if isscalar(sub)


                deleting=isnumeric(expr)&&builtin('_isEmptySqrBrktLiteral',expr);

                if deleting

                    obj=createSubsasgnDelete(obj,sub);
                    return;
                else




                    if(isnumeric(obj)||isa(expr,'optim.problemdef.OptimizationExpression'))&&isequal(size(obj),[0,0])
                        obj=optim.problemdef.OptimizationExpression([0,0],{{},{}});
                    end


                    if~isa(expr,'optim.problemdef.OptimizationExpression')
                        expr=optim.problemdef.OptimizationNumeric(expr);
                    end


                    obj=createSubsasgn(obj,sub,expr);
                    return;
                end

            elseif strcmp(sub(2).type,'.')

                propertyName=sub(2).subs;


                iOnlyAllowPublicSettableProperties(obj,propertyName);

                if strcmpi(propertyName,'IndexNames')
                    error(message('shared_adlib:OptimizationExpression:CannotOverwritePartsOfIndexNamesArray'));
                else



                    dbSub=optim.internal.problemdef.indexing.convertStringToNumericIdx(sub,obj.Size,obj.IndexNames);

                    obj=builtin('subsasgn',obj,dbSub,expr);
                end

            else

                obj=builtin('subsasgn',obj,sub,expr);
            end

        case '.'


            iOnlyAllowPublicSettableProperties(obj,sub(1).subs);


            obj=builtin('subsasgn',obj,sub,expr);

        otherwise


            obj=builtin('subsasgn',obj,sub,expr);
        end
    catch E
        throwAsCaller(E);
    end
end

function iOnlyAllowPublicSettableProperties(obj,propertyName)

    if strcmpi(propertyName,'Variables')


        error(message('shared_adlib:OptimizationExpression:VariablesReadOnly'));
    else
        optim.internal.problemdef.checkPublicPropertyOrMethod(obj,...
        propertyName,optim.problemdef.OptimizationExpression.getPublicPropertiesAndSupportedHiddenMethods);
    end

end
