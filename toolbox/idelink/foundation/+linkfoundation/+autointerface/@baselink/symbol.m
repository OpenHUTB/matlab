function symtab=symbol(h)

















    narginchk(1,1);
    linkfoundation.util.errorIfArray(h);

    symtab=h.mIdeModule.GetSymbolList;


