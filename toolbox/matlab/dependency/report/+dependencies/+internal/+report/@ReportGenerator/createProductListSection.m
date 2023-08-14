function section=createProductListSection(this,docType)




    title=getResource("ProductListTitle");
    names=arrayfun(@getSortedProductNames,this.ProductNodes);
    section=createListSection(2,title,names,docType);
end
