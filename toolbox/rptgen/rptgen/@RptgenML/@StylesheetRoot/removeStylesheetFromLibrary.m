function ssOld=removeStylesheetFromLibrary(this,ssOld,regFile)




    if isempty(ssOld.JavaHandle)
        categorySelect=ssOld.up;

    else
        ssLib=this.StylesheetLibrary;
        if isempty(ssLib)
            ssOld=[];
        else
            if nargin<3
                regFile=ssOld.Registry;
            end
            ssOld=find(ssLib,...
            'id',ssOld.ID,...
            'registry',regFile);
        end
        categorySelect=[];
    end

    for i=1:length(ssOld)
        disconnect(ssOld(i));
    end

    if~isempty(categorySelect)
        r=RptgenML.Root;e=r.Editor;
        if~isempty(e)
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',r);
            ime=DAStudio.imExplorer(e);
            ime.selectListViewNode(categorySelect);
        end
    end
