function oldCS=replaceConfigSet(mdl,newCS)

    pause(0.1);

    try
        loadFlag=false;
        skip=false;
        if bdIsLoaded(mdl)
            loadFlag=true;
        else
            load_system(mdl);
        end

        oldCS=getActiveConfigSet(mdl);
        if isa(oldCS,'Simulink.ConfigSetRef')
            if strcmp(oldCS.SourceResolved,'on')
                oldVarName=oldCS.WSVarName;
            end
        end

        if isa(newCS,'Simulink.ConfigSetRef')
            if strcmp(newCS.SourceResolved,'on')
                newVarName=newCS.WSVarName;
            end
        end

        if exist('oldVarName','var')&&exist('newVarName','var')
            if strcmp(oldVarName,newVarName)
                skip=true;
            end
        end

        if~skip
            name=newCS.Name;
            attachConfigSet(mdl,newCS,true);
            setActiveConfigSet(mdl,newCS.Name);
            detachConfigSet(mdl,oldCS.Name);
            if strcmp(name,oldCS.Name)
                newCS.Name=name;
            end
        end


        if~loadFlag
            w=warning('off','Simulink:Commands:UpgradeToSLXMessage');
            restore_warning=onCleanup(@()warning(w));
            close_system(mdl,1);
            delete(restore_warning);
        end

    catch e
        close_system(mdl,0);
        throw(e)
    end
