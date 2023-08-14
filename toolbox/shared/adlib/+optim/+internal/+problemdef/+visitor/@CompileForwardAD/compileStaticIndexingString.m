function[indexingStr,indexingParens]=compileStaticIndexingString(visitor,Op,addParens)








    visitor.Head=visitor.Head+1;
    childHead=visitor.ChildrenHead;


    [indexingStr,indexingParens]=...
    compileStaticIndexingString@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Op,addParens);
    isArgOrVar=false;
    isAllZero=false;
    singleLine=true;


    push(visitor,indexingStr,indexingParens,isArgOrVar,isAllZero,singleLine);



    visitor.ChildrenHead=childHead;

end
