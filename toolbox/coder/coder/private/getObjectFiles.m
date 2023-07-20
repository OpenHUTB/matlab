function modelModulesObj=getObjectFiles(allModules,toolchainInfo)



    if isempty(toolchainInfo)
        [sourceExtensions,objectExtensions]=locGetFileExtensions;
    else
        [sourceExtensions,objectExtensions]=...
        coder.make.internal.getFileExtensionsForToolchain(toolchainInfo);
    end
    modelModulesObj=allModules;
    for i=1:numel(sourceExtensions)
        sourceExtensionExpr=[strrep(sourceExtensions{i},'.','\.'),'$'];
        modelModulesObj=regexprep(modelModulesObj,sourceExtensionExpr,...
        objectExtensions{i});
    end
end


function[sourceExtensions,objectExtensions]=locGetFileExtensions
    if ispc
        objectExtension='.obj';
    else
        objectExtension='.o';
    end
    sourceExtensions={'.c','.cpp'};
    objectExtensions={objectExtension,objectExtension};
end
