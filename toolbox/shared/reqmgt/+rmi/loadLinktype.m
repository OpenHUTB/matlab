function status=loadLinktype(name)




    status=false;
    try
        fullPath=which(name);
        if isempty(fullPath)

            linktypeDef=['linktypes.',name];
        else
            linktypeDef=name;
        end
        eval(['linkTypeObj = ',linktypeDef,'();']);
        rmi.linktype_mgr('add',linkTypeObj);
        status=true;
    catch Mex
        rmiut.warnNoBacktrace('Slvnv:reqmgt:loadLinktype:CannotRegister',name,Mex.message);
    end

end

