function jointNames=getJointSortedProductNames(node)




    sortedNames=getSortedProductNames(node);
    jointNames=join(sortedNames," | ");
end
