function c=getCurrentDoc(r,currSelect)














    c=[];
    if nargin<2
        if~isa(r.Editor,'DAStudio.Explorer')
            return;
        end
        currSelect=r.getCurrentTreeNode;
    end

    if isa(currSelect,'RptgenML.StylesheetRoot')


        c=currSelect;
        return;
    end


    while~(isempty(currSelect)...
        ||~ishandle(currSelect)...
        ||isa(currSelect,'RptgenML.Root')...
        ||isa(currSelect,'RptgenML.StylesheetRoot'))
        c=currSelect;
        currSelect=currSelect.up;
    end

