function element=findElementInJList(list,matchingCondition)



    import matlab.internal.project.util.*;

    index=convertJavaCollectionToCellArray(list,matchingCondition);
    elements=convertJavaCollectionToCellArray(list);
    elements=elements([index{:}]);
    if~isempty(elements)
        elements=elements{1};
    end
    element=elements;

end