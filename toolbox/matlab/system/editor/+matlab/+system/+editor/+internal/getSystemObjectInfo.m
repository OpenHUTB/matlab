function[isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem,...
    methodIsImplemented,iconMode]=getSystemObjectInfo(filePath,code)




    [isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem,mt]=matlab.system.editor.internal.isSystemObjectFile(filePath,code);

    if isConfirmedSystem
        [methodIsImplemented,iconMode]=matlab.system.editor.internal.DocumentAction.initialize(filePath,mt);
    else

        methodIsImplemented=logical.empty();
        iconMode=0;
    end
