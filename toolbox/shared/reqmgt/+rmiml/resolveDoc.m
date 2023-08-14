function[resolvedPath,isSid]=resolveDoc(doc,refPath)




    isSid=false;

    if rmiut.isCompletePath(doc)&&exist(doc,'file')==2
        resolvedPath=doc;
        return;
    end

    if rmisl.isSidString(doc,true)
        resolvedPath=doc;
        isSid=true;
        return;
    end


    resolvedPath=rmiut.cmdToPath(doc);
    if~isempty(resolvedPath)
        return;
    end




    [mDir,mName]=fileparts(doc);
    if isempty(mDir)
        resolvedPath=rmiut.findInEditor(mName);
    end


    if isempty(resolvedPath)

        resolvedPath=rmi.locateFile(doc,refPath);
    end

end
