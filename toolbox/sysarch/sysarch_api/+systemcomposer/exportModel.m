function[exportedSet,errorLog,changedSet]=exportModel(modelInfo,refModelInfo)

    if(nargin<2)
        obj=systemcomposer.internal.exportModelClass(modelInfo);
    else
        obj=systemcomposer.internal.exportModelClass(modelInfo,refModelInfo);
    end

    exportedSet=obj.exportedSet;
    changedSet=obj.changedSet;

    if(size(obj.exportErrorsLog)>0)
        warning(message('SystemArchitecture:Export:ExportErrorMessage'));
    end
    errorLog=obj.exportErrorsLog;
end
