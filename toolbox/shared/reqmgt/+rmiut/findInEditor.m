function myPath=findInEditor(mName,useFullPath)

    if nargin<2
        useFullPath=false;
    end
    isSID=rmisl.isSidString(mName);

    openFiles=rmiut.RangeUtils.getOpenFilePaths();
    for i=1:length(openFiles)
        thisPath=char(openFiles{i});
        if isSID
            if contains(thisPath,mName)
                myPath=thisPath;
                return;
            end
        elseif useFullPath
            if strcmp(thisPath,mName)
                myPath=thisPath;
                return;
            end
        else
            [~,thisName]=fileparts(thisPath);
            if strcmp(thisName,mName)
                myPath=thisPath;
                return;
            end
        end
    end
    myPath='';
end
