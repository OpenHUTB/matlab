
function result=styleguide_na_0003_algo(expression)
    result=true;
    expr=regexprep(expression,'\s*','');

    if isempty(expr)
        result=true;
        return;
    end

    if contains(expr,'&')&&contains(expr,'|')
        result=false;
        return;
    end

    T=mtree(expr);
    if iskind(T.root.Arg,'PARENS')
        if numel(expr)>1
            expr=expr(2:end-1);
        end
    end





    u_digit='(u\d+\(\d+\)|u\d+|\d+|(\d+\.\d+))';
    relation_ops='(>|<|==|>=|<=|~=)';
    logic_ops='(\&|\|)';
    uru_ops=strcat(u_digit,relation_ops,u_digit);
    primary_expr=['(',u_digit,'|\(',uru_ops,'\))'];

    if~contains(expr,{'|','&'})&&(numel(regexp(expr,relation_ops))==1)
        result=true;
        return;
    end


    p1=['^(',primary_expr,logic_ops,primary_expr,')$'];
    p2=['^',u_digit,'(',logic_ops,u_digit,')*$'];
    p3=['^\(~?',u_digit,'\)$'];
    p4=['^~(',u_digit,')$'];

    patterns={p1,p2,p3,p4};


    if all(cellfun(@isempty,regexp(expr,patterns,'match')))
        result=false;
    end

end

