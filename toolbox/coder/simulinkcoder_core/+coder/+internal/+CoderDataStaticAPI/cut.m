function cut(sourceDD,type,names)
















    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cdict=hlp.openDD(sourceDD);
    scList=[];
    for i=1:length(names)
        scList=[scList,cdict.findEntry(type,names{i})];%#ok<AGROW>
    end
    if isempty(scList)

        coderdictionary.data.api.clearClipboard();
        return;
    end
    coderdictionary.data.api.cut(scList);
end