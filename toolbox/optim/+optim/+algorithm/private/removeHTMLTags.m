function str=removeHTMLTags(str)











    str=regexprep(str,'</?(\w+).*?>','');

end
