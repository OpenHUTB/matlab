function c=getCurrentComponent(r)




    c=[];

    if~isa(r.Editor,'DAStudio.Explorer')
        return;
    end

    ime=DAStudio.imExplorer;
    ime.setHandle(r.Editor);
    currSelect=ime.getCurrentTreeNode;

    if isa(currSelect,'rptgen.rptcomponent')
        c=currSelect;
    end
