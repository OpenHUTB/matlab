function result=createJSLine(filePath)




    url=comparisons.internal.html.createURLFromPath(filePath);
    result=sprintf('<script type="text/javascript" src="%s"></script>\n',url);
end

