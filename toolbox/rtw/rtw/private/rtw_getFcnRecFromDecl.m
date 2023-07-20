function out=rtw_getFcnRecFromDecl(fcnDeclString)





    out.Name='';
    out.Params='';
    out.Returns='';
    left=strfind(fcnDeclString,'(');
    right=strfind(fcnDeclString,')');
    if length(left)==1&&left>2&&length(right)==1&&right>left+1
        returns=fcnDeclString(1:left-1);
        params=fcnDeclString(left+1:right-1);
        returns=strtrim(returns);
        last_space=strfind(returns,' ');
        fname=returns(last_space(end)+1:end);

        if fname(1)=='*'||fname(1)=='&'
            fname=fname(2:end);
            returns=returns(1:last_space(end)+1);
        else
            returns=returns(1:last_space(end)-1);
        end
        out.Name=strtrim(fname);
        out.Params=strtrim(params);
        out.Returns=strtrim(returns);
    end
