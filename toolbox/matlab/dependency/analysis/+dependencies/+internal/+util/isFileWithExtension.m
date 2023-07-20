function accept=isFileWithExtension(node,extensions)




    filter=dependencies.internal.graph.NodeFilter.fileExists(extensions);
    accept=filter.apply(node);

end

