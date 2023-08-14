function h=setcurrentlistnode(node)




    daRoot=DAStudio.Root;
    h='';
    me=daRoot.find('-isa','TflDesigner.explorer');
    if~isempty(me)&&~isempty(me.imme)
        me.imme.selectListViewNode(node);
        me.updateactions;
    end
