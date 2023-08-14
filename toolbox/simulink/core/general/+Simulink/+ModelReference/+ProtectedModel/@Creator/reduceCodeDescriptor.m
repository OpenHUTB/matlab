function reduceCodeDescriptor(obj)




    buildDirs=obj.getBuildDirectories(false);

    for i=1:length(buildDirs)
        codeDesc=coder.getCodeDescriptor(buildDirs{i},247362);
        model=codeDesc.getMF0FullModelForEdit;
        model.BlockHierarchyMap.destroy();
        model.BlockHierarchyMap=coder.descriptor.BlockHierarchyMap.empty;
    end
end


