function dtExpr=getStringDTExprFromDTName(dtName)





    dtNameStr=string(dtName);

    dtExpr=[];

    if strcmp(dtNameStr,"string")

        dtExpr=dtNameStr.char;
    else

        expr="^str[1-9][0-9]*$";
        match=regexp(dtNameStr,expr,'match');
        if~isempty(match)&&strcmp(match,dtNameStr)

            maxLengthStr=dtNameStr.extractAfter("str");
            dtExpr="stringtype("+maxLengthStr+")";
            dtExpr=dtExpr.char;
        end
    end

end