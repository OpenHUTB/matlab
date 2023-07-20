function names=getLibraryNames(hObj,context)











    narginchk(1,2);

    names=fieldnames(hObj.Entries);

    if nargin==2
        entries=hObj.getLibraryEntry(names);
        contexts=get(entries,{'Context'});
        matchContext=strcmp(contexts,context);
        names=names(matchContext);
    end

end
