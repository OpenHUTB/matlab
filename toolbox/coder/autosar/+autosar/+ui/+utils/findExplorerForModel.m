function arExplorer=findExplorerForModel(modelH)





    arExplorer=[];
    root=DAStudio.Root;
    arExplorerList=find(root,'-isa','AUTOSAR.Explorer');
    mdlObject=get_param(modelH,'object');
    for i=1:length(arExplorerList)
        if~isempty(arExplorerList(i).closeListener)
            if arExplorerList(i).closeListener.Source==mdlObject||(iscell(arExplorerList(i).closeListener.Source)&&arExplorerList(i).closeListener.Source{1}==mdlObject)
                arExplorer=arExplorerList(i);
                return;
            end
        end
    end
end
