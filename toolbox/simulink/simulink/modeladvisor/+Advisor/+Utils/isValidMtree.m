function[bResult,errorDetails]=isValidMtree(T)









    bResult=true;
    errorDetails=[];

    if~T.mtfind('Kind','ERR').isempty
        bResult=false;
        errMsg=DAStudio.message('ModelAdvisor:styleguide:mtree_parse_error');
        where=extractBefore(T.mtfind('Kind','ERR').strings{1},':');
        errMsg=[errMsg,where,DAStudio.message('ModelAdvisor:styleguide:mtree_invalid_syntax')];
        errorDetails=MException('MATLAB:SyntaxError',errMsg);
    end
end
