function newExpr=replaceID(oldExpr,oldID,newID)





    if isa(oldExpr,'string')
        oldExpr=oldExpr.char;
    end
    t=mtree(oldExpr);
    ids=t.mtfind('Kind','ID','String',oldID);
    charnos=sort(charno(ids));


    newExpr='';
    oldPos=1;
    for i=1:length(charnos)
        oldIDPos=charnos(i);
        assert(isequal(oldExpr(oldIDPos:oldIDPos+length(oldID)-1),oldID));
        newExpr=[newExpr,oldExpr(oldPos:oldIDPos-1),newID];%#ok
        oldPos=oldIDPos+length(oldID);
    end

    newExpr=[newExpr,oldExpr(oldPos:end)];
end
