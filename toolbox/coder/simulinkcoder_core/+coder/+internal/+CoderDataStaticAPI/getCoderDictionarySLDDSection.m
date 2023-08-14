function out=getCoderDictionarySLDDSection(dictionaryName)









    out=[];
    if isempty(dictionaryName)
        return;
    end
    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cdict=hlp.openDD(dictionaryName);
    if cdict.owner.isEmpty()
        return;
    end
    if dig.isProductInstalled('Embedded Coder')

        out=coder.Dictionary(dictionaryName);
    else
        out=[];
    end
end