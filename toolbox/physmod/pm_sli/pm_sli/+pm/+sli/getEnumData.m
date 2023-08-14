function[data,canonicalExpr]=getEnumData(expr)























    data=[];
    canonicalExpr=[];

    if ischar(expr)
        try
            evaledExpr=eval(expr);
        catch
            return;
        end
    else
        evaledExpr=expr;
    end

    enumClass=class(evaledExpr);
    [enumObjs,enumChars]=enumeration(enumClass);

    if isempty(enumObjs)||numel(evaledExpr)~=1

        return;
    end

    data.enumValMap=strcat([enumClass,'.'],enumChars);
    data.enumValues=int32(enumObjs);


    displayTextMethod='displayText';
    displayTextReturnType='containers.Map';

    enumStrings=enumChars;

    md=meta.class.fromName(enumClass);
    displayMethodIdx=strcmp({md.MethodList.Name},displayTextMethod);
    if nnz(displayMethodIdx)==1

        if~md.MethodList(displayMethodIdx).Static
            error(message('physmod:pm_sli:sl:InvalidMethodReturnType',...
            displayTextMethod,enumClass,displayTextReturnType));
        end

        displayMap=eval([enumClass,'.',displayTextMethod]);
        if~isa(displayMap,displayTextReturnType)
            error(message('physmod:pm_sli:sl:InvalidMethodReturnType',...
            displayTextMethod,enumClass,displayTextReturnType));
        end
        for i=1:numel(enumStrings)
            if displayMap.isKey(enumStrings{i})
                enumStrings{i}=displayMap(enumStrings{i});
            end
        end
    end
    data.enumStrings=enumStrings;


    canonicalExpr=data.enumValMap{find(evaledExpr==data.enumValues,1)};


    if ischar(expr)
        canonicalExpr=lDecanonicalExpr(expr,canonicalExpr,enumClass);
    end

end

function canonicalExpr=lDecanonicalExpr(expr,canonicalExpr,enumClass)
























    [~,enumChars]=enumeration(enumClass);

    expr=replace(expr,{'[',']'},'');
    if contains(expr,'.')
        dots=strfind(expr,'.');
        exprCls=expr(1:dots(end)-1);

        if strcmp(exprCls,enumClass)
            id=expr(dots(end)+1:end);
            id=eraseBetween(id,'(',')','Boundaries','inclusive');
            if nnz(strcmp(enumChars,id))==1
                canonicalExpr=[enumClass,'.',id];
            end
        end
    end

end


