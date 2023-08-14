function configsetObj=getConfigsetObj(ddFilespec,csnameOrID)



    ddConn=Simulink.dd.open(ddFilespec);
    if ischar(csnameOrID)
        fullName=['Configurations.',csnameOrID];
        configsetObj=ddConn.getEntryCached(fullName);
    else

        configsetObj=ddConn.getEntryCached(csnameOrID);
    end
end
