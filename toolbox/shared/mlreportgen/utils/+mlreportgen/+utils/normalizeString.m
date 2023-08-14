function normStr=normalizeString(input)









    if ischar(input)||isstring(input)
        normStr=strtrim(input);
        normStr=regexprep(normStr,"\s"," ");
    else

        error(message("mlreportgen:report:error:normlizeStringinvalidInput",class(input)));
    end

end

