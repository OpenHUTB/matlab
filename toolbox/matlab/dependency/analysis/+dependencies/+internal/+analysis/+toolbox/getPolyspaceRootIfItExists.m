function rootOrEmpty=getPolyspaceRootIfItExists()





    if exist('polyspaceroot','file')~=6
        rootOrEmpty='';
        return;
    end
    try
        rootOrEmpty=polyspaceroot;
    catch
        rootOrEmpty='';
    end
end
