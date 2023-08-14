function out=currentFolder(hDOORS)

    rmidoors.invoke(hDOORS,'dmiUtilCurrentFolder_()');
    out=hDOORS.Result;
end
