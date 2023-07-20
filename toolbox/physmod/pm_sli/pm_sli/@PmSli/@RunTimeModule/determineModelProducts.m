function[products,pmBlocks,flags]=determineModelProducts(mdl,includeInactive)














    if nargin==1
        includeInactive=false;
    end

    products={};

    this=PmSli.RunTimeModule.getInstance;

    isExamining=this.isExaminingModel(mdl);
    this.setExaminingModel(mdl,true);

    getPmBlocksAndProducts=pmsl_private('pmsl_pmblocksproducts');
    [pmBlocks,flags,products]=getPmBlocksAndProducts(mdl,includeInactive);
    this.setExaminingModel(mdl,isExamining);






