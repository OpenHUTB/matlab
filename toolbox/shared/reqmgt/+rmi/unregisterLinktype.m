function status=unregisterLinktype(linkTypeName)



    status=false;
    regLinkTypes=rmi.settings_mgr('get','regTargets');
    fileIdx=find(strcmp(linkTypeName,regLinkTypes),1);

    uddList=rmi.linktype_mgr('all');
    memIdx=[];
    for idx=1:length(uddList)
        if strcmp(linkTypeName,uddList(idx).Registration)
            memIdx=idx;
            break;
        end
    end

    if isempty(fileIdx)
        if isempty(memIdx)
            warning(message('Slvnv:rmi:unregisterLinktype:IgnoringUnregister',linkTypeName));
        else
            error(message('Slvnv:rmi:unregisterLinktype:CannotUnregister',linkTypeName));
        end
    else

        regLinkTypes(strcmp(linkTypeName,regLinkTypes))=[];
        rmi.settings_mgr('set','regTargets',regLinkTypes);


        if isempty(memIdx)






        else
            rmi.linktype_mgr('remove',uddList(memIdx))
            status=true;


            if rmi.isInstalled()
                rmi.menus_selection_links([]);
                rmiml.selectionLink([]);
            end
        end
    end
