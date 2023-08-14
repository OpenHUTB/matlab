function callWithNodePath(fHandle,node)





    if node.Type==dependencies.internal.graph.Type.TEST_HARNESS
        path=[node.Location{1},' (',node.Location{3},')'];
    elseif node.isFile()
        path=node.Location{1};
    else
        return;
    end

    fHandle(path);

end
