function out=getLinks2SourceFiles(obj)
    srcs=obj.getFileNames();
    out=cell(size(srcs));
    for i=1:length(srcs)
        out{i}=obj.getLinkToFile(srcs{i});
    end
end
