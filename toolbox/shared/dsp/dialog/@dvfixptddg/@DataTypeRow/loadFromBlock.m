function loadFromBlock(h)






    mode=h.Block.([h.Prefix,'Mode']);
    untranslatedEntries=h.Block.getPropAllowedValues([h.Prefix,'Mode']);
    indexValue=find(strcmp(untranslatedEntries,mode),1);
    h.Mode=indexValue-1;

    h.WordLength=h.Block.([h.Prefix,'WordLength']);
    h.FracLength=h.Block.([h.Prefix,'FracLength']);
