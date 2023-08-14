function[file,line,col]=getLoc(fcnTypeInfo,node)




    file='';
    line=1;
    col=1;

    if~isempty(fcnTypeInfo)&&isfile(fcnTypeInfo.scriptPath)
        file=fcnTypeInfo.scriptPath;
    end

    if~isempty(node)
        line=node.lineno;
        col=node.charno;
    end

end
