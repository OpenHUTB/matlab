function[result,pS,pE]=filter_out_line_cont(ptStr)





    [result,pS,pE]=str_filter_out_line_cont(ptStr);

end


function[str,pS,pE]=str_filter_out_line_cont(str)








    [pS,pE]=regexp(str,'\.\.\.[^\n]*(\n|$)');
    for i=1:length(pS)
        str(pS(i):pE(i))=' ';
    end

end
