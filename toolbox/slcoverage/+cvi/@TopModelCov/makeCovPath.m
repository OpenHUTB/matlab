function covPath=makeCovPath(blockPath)



    model=bdroot(blockPath);
    covPath=getfullname(blockPath);
    covPath=covPath(numel(get_param(model,'name'))+2:end);
end
