function selectNode(this,node,allowFiringOfCallbacks)










    if~isa(node,'iatbrowser.BrowserTreeNode')
        error(message('imaq:imaqtool:invalidNode','iatbrowser.BrowserTreeNode'));
    end



    pathComponents{1}=node.JavaPeer;
    currentNode=node.Parent;
    while~isempty(currentNode)
        pathComponents{end+1}=currentNode.JavaPeer;%#ok<AGROW>
        currentNode=currentNode.Parent;
    end


    javaRootNode=pathComponents{end};

    treePath=javaObjectEDT('javax.swing.tree.TreePath',javaRootNode);


    for ii=(length(pathComponents)-1):-1:1
        treePath=treePath.pathByAddingChild(pathComponents{ii});
    end




    this.javaPeer.setReselectingNode(true);
    this.javaTreePeer.setSelectionPath([]);

    this.javaPeer.setSelectionPath(treePath,allowFiringOfCallbacks);

