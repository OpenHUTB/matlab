function out=needsParens(expr)














    out=true;

    mt=mtree(expr);
    if numel(mt.indices)<2
        return;
    end




    kinds1={'PRINT','EXPR'};


    kinds2={'INT','DOUBLE','CALL','PARENS','DOT','SUBSCR','CELL','LB','LC'};

    treekinds=kinds(mt.select(1:2));



    out=~(any(strcmp(treekinds{1},kinds1))&&...
    any(strcmp(treekinds{2},kinds2)));