function[indexingStr,indexingParens]=visitStaticIndexingString(visitor,~,~)








    [indexingStr,indexingParens]=pop(visitor);


    visitor.Head=visitor.Head-2;

end
