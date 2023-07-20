function con=subsasgn(con,sub,val)













    try
        switch sub(1).type
        case '()'

            if isscalar(sub)


                deleting=isnumeric(val)&&builtin('_isEmptySqrBrktLiteral',val);

                if deleting

                    con=subsasgnParensDeleting(con,sub);
                    return;
                else


                    con=subsasgnParens(con,sub,val);
                    return;
                end

            elseif strcmp(sub(2).type,'.')

                propertyName=sub(2).subs;


                iOnlyAllowPublicSettableProperties(con,propertyName);

                if strcmpi(propertyName,'IndexNames')
                    error(message('optim_problemdef:OptimizationConstraint:CannotOverwritePartsOfIndexNamesArray',con.className));
                else


                    dbSub=optim.internal.problemdef.indexing.convertStringToNumericIdx(sub,con.Size,con.IndexNames);

                    con=builtin('subsasgn',con,dbSub,val);
                end

            else

                con=builtin('subsasgn',con,sub,val);
            end

        case '.'


            iOnlyAllowPublicSettableProperties(con,sub(1).subs);


            con=builtin('subsasgn',con,sub,val);

        otherwise


            con=builtin('subsasgn',con,sub,val);
        end

    catch E
        throwAsCaller(E);
    end
end

function con=subsasgnParens(con,sub,val)




    if~isa(val,'optim.problemdef.OptimizationConstraint')
        error(message('MATLAB:invalidConversion','OptimizationConstraint',class(val)));
    end



    if isnumeric(con)&&isequal(size(con),[0,0])
        con=createConstraint(val,[0,0]);
    end



    if isempty(con.Relation)
        con=setRelation(con,val.Relation);
    elseif~strcmp(con.Relation,val.Relation)
        msgId="optim_problemdef:"+con.className+":OnlyOneRelationPerArray";
        error(message(msgId));
    end



    indexNames=con.IndexNames;
    con.Expr1.IndexNames=indexNames;
    con.Expr2.IndexNames=indexNames;


    try
        con.Expr1=createSubsasgn(con.Expr1,sub,val.Expr1);
        con.Expr2=createSubsasgn(con.Expr2,sub,val.Expr2);
    catch ME
        if strcmp(ME.identifier,'shared_adlib:HashMapFunctions:VariableNameClash')
            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            '','ug_no_duplicate_names','normal',true);
            ME=MException(message('shared_adlib:HashMapFunctions:VariableNameClash',...
            con.className,startTag,endTag));
        end
        throwAsCaller(ME);
    end



    con.Size=size(con.Expr1);


    con.IndexNames=con.Expr1.IndexNames;


    con.Variables=optim.internal.problemdef.HashMapFunctions.union(...
    getVariables(con.Expr1),getVariables(con.Expr2),con.className);

end

function con=subsasgnParensDeleting(con,sub)



    indexNames=con.IndexNames;
    con.Expr1.IndexNames=indexNames;
    con.Expr2.IndexNames=indexNames;



    con.Expr1=createSubsasgnDelete(con.Expr1,sub);
    con.Expr2=createSubsasgnDelete(con.Expr2,sub);



    con.Size=size(con.Expr1);


    con.IndexNames=con.Expr1.IndexNames;


    con.Variables=optim.internal.problemdef.HashMapFunctions.union(...
    getVariables(con.Expr1),getVariables(con.Expr2),con.className);
end

function iOnlyAllowPublicSettableProperties(obj,propertyName)

    if strcmpi(propertyName,'Variables')


        error(message('optim_problemdef:OptimizationConstraint:VariablesReadOnly',obj.className));
    else
        optim.internal.problemdef.checkPublicPropertyOrMethod(obj,propertyName,...
        optim.problemdef.OptimizationConstraint.getPublicPropertiesAndSupportedHiddenMethods);
    end

end

