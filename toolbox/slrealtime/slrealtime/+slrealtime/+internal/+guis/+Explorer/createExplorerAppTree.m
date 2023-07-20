function[node,codeDescriptor]=createExplorerAppTree(buildDir)






    try
        codeDescriptor=coder.internal.getCodeDescriptorInternal(buildDir,247362);
    catch ME
        if contains(ME.identifier,'ObsoleteSchema')
            error(message('slrealtime:toolstrip:invalidApplication'));
        end
    end

    node=locCreateAppTreeFromCodeDescriptor(codeDescriptor);
end

function node=locCreateAppTreeFromCodeDescriptor(codeDescriptor)









    hierarchy=codeDescriptor.getHierarchyForSLRT();


    [paths,idx]=sort({hierarchy.Path});
    hierarchy=hierarchy(idx);


    idx=~contains(paths,'/');
    top=hierarchy(idx);



    fig=uifigure('Visible','off');
    tree=uitree(fig);
    node=uitreenode(tree);
    node.Parent=[];
    delete(fig);
    delete(tree);
    node.Text=top.GraphicalName;
    node.Icon=slrealtime.internal.guis.Explorer.Icons.modelIcon;
    node.NodeData=struct('path',top.Path);

    paths(idx)=[];
    hierarchy(idx)=[];
    paths=strrep(paths,[top.Path,'/'],'');

    locGetChildNodes(hierarchy,node,paths);
end

function locGetChildNodes(hierarchy,node,paths)













    idx=~contains(paths,'/');
    dirChildren=hierarchy(idx);
    dirChildPaths=paths(idx);
    hierarchy(idx)=[];
    paths(idx)=[];

    for k=1:length(dirChildren)
        dirChild=dirChildren(k);
        dirChildPath=dirChildPaths(k);

        if strcmp(dirChild.Type,'SubSystem')
            childNode=uitreenode(node);
            childNode.Text=dirChild.GraphicalName;
            childNode.Icon=slrealtime.internal.guis.Explorer.Icons.subsystemIcon;
            childNode.NodeData=struct('path',dirChild.Path);
        elseif strcmp(dirChild.Type,'ModelReference')
            if dirChild.IsProtectedModel
                continue;
            end
            childNode=uitreenode(node);
            childNode.Text=[dirChild.GraphicalName,' (',dirChild.ReferencedModelName,')'];
            childNode.Icon=slrealtime.internal.guis.Explorer.Icons.modelrefIcon;
            childNode.NodeData=struct('path',dirChild.Path);
        end



        idx3=~cellfun(@isempty,regexp(paths,['^',dirChildPath{:},'/']));
        if any(idx3)
            subHierarchy=hierarchy(idx3);
            subPaths=paths(idx3);

            subPaths=regexprep(subPaths,['^',dirChildPath{:},'/'],'');

            locGetChildNodes(subHierarchy,childNode,subPaths);
        end
    end

end

