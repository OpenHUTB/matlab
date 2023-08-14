function c=getCurrentRpt(r,checkRptList)








    c=[];
    if~isa(r.Editor,'DAStudio.Explorer')
        return;
    end

    ime=DAStudio.imExplorer;
    ime.setHandle(r.Editor);
    currSelect=ime.getCurrentTreeNode;

    if isa(currSelect,'rptgen.rptcomponent')
        c=currSelect;
        cUp=c;

        while~isempty(cUp)&&isa(cUp,'rptgen.rptcomponent')
            c=cUp;
            cUp=up(c);
        end





    elseif isa(currSelect,'RptgenML.Root')&&nargin>1&&checkRptList
        cList=ime.getSelectedListNodes;
        if~isempty(cList)
            cList=cList(1);
            if isa(cList,'RptgenML.LibraryRpt')&&~isempty(cList.PathName)
                c=cList.FileName;
            end
        end
    end

    if isempty(c)
        cChild=r.down;
        while~isempty(cChild)
            if isa(cChild,'rptgen.coutline')
                c=cChild;
            end
            cChild=cChild.right;
        end
    end