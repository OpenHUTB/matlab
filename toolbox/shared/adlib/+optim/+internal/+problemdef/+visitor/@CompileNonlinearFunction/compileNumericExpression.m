function[funStr,numParens,isArgOrVar]=compileNumericExpression(visitor,expression,addParens)






    head=visitor.Head;


    acceptVisitor(expression,visitor);


    [funStr,numParens,isArgOrVar]=getArgumentName(visitor,addParens);


    visitor.Head=head;
