
function text=removeWhitespaces(text)
    text=regexprep(text,'\r','');
    text=regexprep(text,'\n','');
    text=regexprep(text,' ','');
end