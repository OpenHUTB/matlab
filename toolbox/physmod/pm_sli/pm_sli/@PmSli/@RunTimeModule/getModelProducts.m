function products=getModelProducts(this,mdl)







    ;

    products=this.modelRegistry.getProductsUsed(mdl);

    if isempty(products)||~strcmp(class(products),'cell')

        [products]=this.determineModelProducts(mdl);
        this.storeModelProducts(mdl,products);

    end




