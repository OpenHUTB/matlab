function[funStr,numParens,isArgOrVar]=visitNumericExpression(visitor,~,~)







    [funStr,numParens,isArgOrVar]=pop(visitor);


    visitor.Head=visitor.Head-2;
