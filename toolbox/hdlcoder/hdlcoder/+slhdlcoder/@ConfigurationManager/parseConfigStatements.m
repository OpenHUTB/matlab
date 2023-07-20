function parseConfigStatements(this,hImplDatabase,configStmts,warnOnOverwrite)


    if nargin<4
        warnOnOverwrite=false;
    end

    for i=1:length(configStmts)

        configStmt=configStmts(i);

        pathStr=configStmt.Scope;


        [isValid,isGlobal,isHereOnly,isBlock,isCustomLibBlock,slpath]=...
        this.analyzePath(pathStr);


        if~isValid
            continue;
        end


        blockLibPath=configStmt.BlockType;
        impl=configStmt.Implementation;
        params=configStmt.ImplParams;
        [~,deprInfo]=hImplDatabase.getImplementationInfoForBlock(blockLibPath,false,impl,-1);
        if~isempty(deprInfo)&&strcmpi(impl,deprInfo.oldName)
            impl=deprInfo.newName;
        end

        if isCustomLibBlock&&strcmpi(impl,'blackbox')&&...
            ~strcmpi(blockLibPath,'built-in/ModelReference')
            blockLibPath='built-in/Subsystem';
            configStmt.BlockType=blockLibPath;
            isBlock=0;
        end


        defImpl=this.getDefaultImplementation(slpath);
        customSubsystem=false;
        if isempty(defImpl)...
            &&(isempty(impl)||strcmpi(impl,'Module')||strcmpi(impl,'default')||strcmpi(impl,'No HDL'))
            obj=get_param(slpath,'object');
            if isCustomLibBlock&&strcmpi(obj.blockType,'SubSystem')
                isBlock=0;
                customSubsystem=true;
            end
        end


        if~any(hImplDatabase.isRegistered(blockLibPath,impl))&&~customSubsystem
            error(message('hdlcoder:engine:unregistered',blockLibPath,impl));
        end

        if(isBlock)


            slblktype=hdlgetblocklibpath(slpath);
            nocr_slblktype=strrep(slblktype,newline,' ');
            nocr_configBlockType=strrep(configStmt.BlockType,newline,' ');
            if~strcmpi(nocr_slblktype,nocr_configBlockType)


                error(message('hdlcoder:engine:incorrectblocktype',configStmt.Scope,configStmt.BlockType,slblktype));
            end
        end

        if isGlobal

            if isBlock
                error(message('hdlcoder:engine:configerror'))
            end

            if~strcmp(slpath,this.ModelName)
                error(message('hdlcoder:engine:configerrorslpath'))
            end

            if~isHereOnly
                error(message('hdlcoder:engine:configerrorbadpath'));
            end

        else

            if isempty(slpath)
                warning(message('hdlcoder:engine:emptyPath'));
                continue;
            end

            if isBlock







                this.HereOnlyComponentTable.addImplementation(slpath,blockLibPath,impl,params,warnOnOverwrite);
            else

                if~isHereOnly

                    this.FrontEndStopTable.addImplementation(slpath,blockLibPath,impl,params,warnOnOverwrite);

                end
            end
        end
    end
end



