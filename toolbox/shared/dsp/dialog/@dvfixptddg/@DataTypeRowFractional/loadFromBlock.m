function loadFromBlock(this)







    mode=this.Block.([this.Prefix,'Mode']);
    untranslatedEntries=this.Block.getPropAllowedValues([this.Prefix,'Mode']);
    indexValue=find(strcmp(untranslatedEntries,mode),1);
    this.Mode=indexValue-1;










    this.WordLength=this.Block.([this.Prefix,'WordLength']);
