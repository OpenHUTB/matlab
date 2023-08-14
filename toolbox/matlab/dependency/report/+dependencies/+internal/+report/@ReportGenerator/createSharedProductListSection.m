function section=createSharedProductListSection(this,docType)





    title=getResource("SharedProductListTitle");
    sharedProductNames=arrayfun(...
    @getSortedProductNames,...
    this.SharedProductNodes,...
    "UniformOutput",false);
    sharedProductNames=[sharedProductNames{:}];
    section=createListSection(3,title,sharedProductNames,docType);
    section=applyMargin(section,docType);
end
