function nodes=getselectedlistnodes


    daRoot=DAStudio.Root;
    nodes='';
    me=daRoot.find('-isa','TflDesigner.explorer');

    if~isempty(me)&&~isempty(me.imme)
        nodes=me.imme.getSelectedListNodes;
    end
