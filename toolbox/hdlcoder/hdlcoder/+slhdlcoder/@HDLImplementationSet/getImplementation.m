function implObj=getImplementation(this,blockLibPath,configMgr)









    implObj=[];

    implInfo=this.getImplInfoForBlockLibPath(blockLibPath);
    if~isempty(implInfo)



        if~isempty(implInfo.Instance)
            implObj=implInfo.Instance;
            return;
        end


        archName=implInfo.ArchitectureName;
        if isempty(archName)
            error(message('hdlcoder:engine:noimplementation',blockLibPath));
        end

        params=implInfo.Parameters;

        if(strcmpi(archName,'default')&&~isempty(configMgr))
            setToUse=configMgr.DefaultTable.getImplementationSet(configMgr.ModelName);
        else
            setToUse=this;
        end

        implClassName=setToUse.getImplementationClassName(blockLibPath,configMgr.ImplDB);

        if isempty(implClassName)
            if strcmpi(archName,'Module')||strcmpi(archName,'default')||strcmpi(archName,'No HDL')
                libName=strtok(blockLibPath,'/');
                if~bdIsLoaded(libName)
                    load_system(libName)
                end

                blkType=get_param(blockLibPath,'BlockType');
                if strcmpi(blkType,'SubSystem')
                    return;
                end
            end
            error(message('hdlcoder:engine:unknownArch',archName,blockLibPath));
        end

        implObj=getImplementationInstance(implClassName,params);

        implInfo.Instance=implObj;
        this.setImplInfoForBlockLibPath(blockLibPath,implInfo);
    end
end

function implObj=getImplementationInstance(implClassName,params)


    implObj=feval(implClassName,params{1});
    implObj.setImplParams(params(2:end));
end


