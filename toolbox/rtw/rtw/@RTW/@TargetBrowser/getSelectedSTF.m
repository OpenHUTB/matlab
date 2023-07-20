function getSelectedSTF(h)































    hParentSrc=get(h,'ParentSrc');



    tlcfiles=get(h,'tlcfiles');



    filesIdx=[];



    storedTargetName=get_param(hParentSrc,'SystemTargetFile');
    storedDescription=get_param(getComponent(hParentSrc,'Code Generation'),'Description');
    for i=1:length(tlcfiles)
        targetName=tlcfiles(i).shortName;
        description=tlcfiles(i).description;
        if strcmp(storedTargetName,targetName)&&...
            (strcmp(storedDescription,'')||strcmp(storedDescription,description))
            filesIdx=i;
            break;
        end
    end




    listIdx=[];



    if~isempty(filesIdx)
        tmp_listIdx=-1;
        for i=1:length(tlcfiles)
            if~tlcfiles(i).isObsolete
                tmp_listIdx=tmp_listIdx+1;
                if(i==filesIdx)
                    listIdx=tmp_listIdx;
                    break;
                end
            end
        end
    end


    if~isempty(listIdx)&&listIdx>-1

        set(h,'tlcfiles_selected',filesIdx);
        set(h,'tlclist_selected',listIdx);
    elseif~isempty(filesIdx)

        set(h,'tlcfiles_selected',filesIdx);
        set(h,'tlclist_selected',-1);
    else

        set(h,'tlcfiles_selected',-1);
        set(h,'tlclist_selected',-1);
    end
