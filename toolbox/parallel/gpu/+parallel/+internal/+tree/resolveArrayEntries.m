function[firstElem,secondElem]=resolveArrayEntries(node)





































    emptyNodes=mtfind(Tree(node),'Kind','ROW','Arg.Null',true);

    if~isempty(emptyNodes)

        error(message('MATLAB:randi:invalidLimits'));
    end

    firstElem=node;
    if isnull(firstElem)
        secondElem=node;
        return;
    end

    firstElemKind=kind(firstElem);







    if~any(strcmp(firstElemKind,{'LB','ROW','PARENS'}))
        secondElem=parallel.internal.tree.nextArgNode(firstElem);
        return
    end

    secondElem=null(firstElem);


    while(strcmp(firstElemKind,'LB')||strcmp(firstElemKind,'ROW')...
        ||strcmp(firstElemKind,'PARENS'))
        firstElem=Arg(firstElem);
        firstElemKind=kind(firstElem);

        if isnull(secondElem)
            secondElem=Next(firstElem);
        end

    end

end

