function out=execute(c,d,varargin)







    bList=findContextBlocks(rptgen_sl.appdata_sl);

    out='';
    if isempty(bList)
        c.status('No blocks found');
        return;
    end

    wList=c.makeWordList(bList,d);
    vList=c.makeVariableList(wList);

    if c.isVariableTable
        out=c.makeVariableTable(vList,d);
    end

    if c.isFunctionTable
        fList=c.makeFunctionList(wList,vList);
        out=createDocumentFragment(d,...
        out,...
        c.makeFunctionTable(fList,d));
    end