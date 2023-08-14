function[funStr,numParens,isArgOrVar]=visitNumericExpression(visitor,expression,addParens)





    [funStr,numParens,isArgOrVar]=compileNumericExpression(visitor,expression,addParens);
