function categoryStr=compuMethodCategoryToString(category)





    switch category
    case Simulink.metamodel.types.CompuMethodCategory.Linear
        categoryStr='Linear';
    case Simulink.metamodel.types.CompuMethodCategory.Identical
        categoryStr='Identical';
    case Simulink.metamodel.types.CompuMethodCategory.TextTable
        categoryStr='TextTable';
    case Simulink.metamodel.types.CompuMethodCategory.RatFunc
        categoryStr='RatFunc';
    case Simulink.metamodel.types.CompuMethodCategory.LinearAndTextTable
        categoryStr='LinearAndTextTable';
    otherwise

        categoryStr='Unexpected';
    end
end

