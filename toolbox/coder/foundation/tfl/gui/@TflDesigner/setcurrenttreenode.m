function h=setcurrenttreenode(node)



    daRoot=DAStudio.Root;
    h='';
    me=daRoot.find('-isa','TflDesigner.explorer');
    if~isempty(me)&&~isempty(me.imme)&&~isempty(node)&&ishandle(node)
        me.getRoot.currenttreenode=node;
        me.imme.selectTreeViewNode(node);
        me.imme.selectListViewNode(node);
        me.updateactions;
        drawnow;
    end
