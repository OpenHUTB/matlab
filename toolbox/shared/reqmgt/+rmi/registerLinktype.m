function status=registerLinktype(linkTypeName)



    status=false;
    regLinkTypes=rmi.settings_mgr('get','regTargets');
    fileIdx=find(strcmp(linkTypeName,regLinkTypes));

    uddList=rmi.linktype_mgr('all');
    memIdx=[];
    for idx=1:length(uddList)
        if strcmp(linkTypeName,uddList(idx).Registration)
            memIdx=idx;
            break;
        end
    end

    if isempty(fileIdx)&&isempty(memIdx)

        status=rmi.loadLinktype(linkTypeName);


        if(status)
            regLinkTypes{end+1}=linkTypeName;
            rmi.settings_mgr('set','regTargets',regLinkTypes);
        end


        if rmi.isInstalled()
            rmi.menus_selection_links([]);
            rmiml.selectionLink([]);
        end
    else
        if isempty(fileIdx)
            error(message('Slvnv:reqmgt:rmi:NameCollision',linkTypeName));
        else
            warning(message('Slvnv:reqmgt:rmi:AlreadyRegistered',linkTypeName));
        end
    end
