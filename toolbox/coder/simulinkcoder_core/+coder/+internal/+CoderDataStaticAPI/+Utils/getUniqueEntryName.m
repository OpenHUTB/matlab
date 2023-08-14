function newName=getUniqueEntryName(dd,type,baseName)

    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    baseName=[baseName,'_copy'];
    newName=baseName;
    idx=1;
    while~isempty(hlp.findEntry(dd,type,newName))
        newName=sprintf('%s%d',baseName,idx);
        idx=idx+1;
    end
end