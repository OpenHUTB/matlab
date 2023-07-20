function htmlTag=convertNameToHtmlTag(name)



    htmlTag=lower(name);
    htmlTag=strrep(htmlTag,':','_');
end