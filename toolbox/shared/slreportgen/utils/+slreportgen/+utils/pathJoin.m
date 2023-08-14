function diagramPath=pathJoin(parent,name)














    name=string(name);
    name=regexprep(name,"\s"," ");

    parent=string(parent);
    parent=regexprep(parent,"\s"," ");

    if(isempty(parent)||(parent==""))

        diagramPath=name;

    elseif(isempty(name)||(name==""))

        diagramPath=parent;

    else

        name=replace(name,"/","//");
        diagramPath=parent+"/"+name;
    end
end
