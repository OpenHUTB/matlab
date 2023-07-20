function treeChildren=getHierarchicalChildren(this)

    treeChildren(1:0)=matlab.internal.defaultObjectArray(1);
    coreChildren=this.coreObj.getHierarchicalChildren();

    for i=1:length(coreChildren)
        next=coreChildren{i};
        if next.isHierarchical()
            for k=1:length(next.proxyObj)
                proxyObj=next.proxyObj{k};
                if(proxyObj.uiParent==this)
                    treeChildren(end+1)=proxyObj;%#ok<AGROW>
                end
            end
        end
    end
end

