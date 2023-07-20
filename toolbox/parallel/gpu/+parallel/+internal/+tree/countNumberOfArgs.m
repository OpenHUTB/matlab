function nargs=countNumberOfArgs(node)




    nargs=0;
    current=parallel.internal.tree.firstArgNode(node);

    while~isnull(current)
        nargs=nargs+1;
        current=parallel.internal.tree.nextArgNode(current);
    end

end
