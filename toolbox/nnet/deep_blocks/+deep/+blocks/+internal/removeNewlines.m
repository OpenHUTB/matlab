function formatted=removeNewlines(str)
    formatted=strrep(str,newline,""" + newline + """);
end