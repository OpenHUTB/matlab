function[depths,items]=getObjAttributes(document,itemId)




    if rmi.mdlAdvState('doors')<0
        header=getString(message('Slvnv:reqmgt:linktype_rmi_doors:DOORSUnavailable'));
        depths=0;
        items={header};
        return;
    end


    if isempty(document)
        header=getString(message('Slvnv:reqmgt:linktype_rmi_doors:ERRORDOORSModuleNotSpecified'));
        depths=0;
        items={header};
        return;
    end

    targetModule=strtok(document);

    targetObject=rmidoors.getNumericStr(itemId,targetModule);
    if isempty(targetObject)
        header=getString(message('Slvnv:reqmgt:linktype_rmi_doors:ERRORDOORSObjectID'));
        depths=0;
        items={header};
        return;
    end



    userAttrPrefs=rmi.settings_mgr('get','reportSettings','detailsDoors');
    depths=[];
    items={};


    if any(strcmp(userAttrPrefs,'Object Heading'))
        depths=[depths;0];
        header=rmidoors.getObjAttribute(targetModule,targetObject,'Object Heading');
        if isempty(header)
            items=[items;{getString(message('Slvnv:reqmgt:linktype_rmi_doors:NoHeading'))}];
        else
            items=[items;{header}];
        end
    end

    if any(strcmp(userAttrPrefs,'Object Text'))
        body=rmidoors.getObjAttribute(targetModule,targetObject,'Object Text');
        if isempty(body)
            depths=[depths;1];
            items=[items;{getString(message('Slvnv:reqmgt:linktype_rmi_doors:NoText'))}];
        else
            parts=textscan(body,'%s','Delimiter','\n');
            depths=[depths;ones(size(parts{1}))];
            items=[items;strtrim(parts{1})];
        end
    end

    isAdd=strncmp(userAttrPrefs,'+',1);
    isSkip=strncmp(userAttrPrefs,'-',1);
    allAttrs=cell(0,2);
    takeAttrs=cell(0,2);
    if any(strcmp(userAttrPrefs,'$AllAttributes$'))
        takeAttrs=rmidoors.getObjAttribute(targetModule,targetObject,'all attributes');
        allAttrs=takeAttrs;
    elseif any(strcmp(userAttrPrefs,'$UserAttributes$'))
        takeAttrs=rmidoors.getObjAttribute(targetModule,targetObject,'user attributes');
    end

    if any(isSkip)&&~isempty(takeAttrs)
        attrsToSkip=userAttrPrefs(isSkip);
        for i=1:length(attrsToSkip)
            item=attrsToSkip{i};
            attr=item(2:end);
            skipIdx=strcmp(takeAttrs(:,1),attr);
            takeAttrs(skipIdx,:)=[];
        end
    end


    for i=size(takeAttrs,1):-1:1
        if strncmp(takeAttrs{i,1},'Table',length('Table'))
            takeAttrs(i,:)=[];
        end
    end


    if any(isAdd)
        if isempty(allAttrs)
            allAttrs=rmidoors.getObjAttribute(targetModule,targetObject,'all attributes');
        end
        attrsToAdd=userAttrPrefs(isAdd);
        for i=1:length(attrsToAdd)
            item=attrsToAdd{i};
            attr=item(2:end);
            isMatch=strcmp(allAttrs(:,1),attr);
            if any(isMatch)&&~any(strcmp(takeAttrs(:,1),attr))
                takeAttrs=[takeAttrs;allAttrs(isMatch,:)];%#ok<AGROW>
            end
        end
    else
        attrsToAdd={};
    end

    if any(strcmp(userAttrPrefs,'$NonEmpty$'))
        isEmpty=strcmp(strtrim(takeAttrs(:,2)),'');
        takeAttrs(isEmpty,:)=[];
    end

    if any(strcmp(attrsToAdd,'+Prefix'))
        takeAttrs=[{'Prefix',rmidoors.getModuleAttribute(targetModule,'Prefix')};takeAttrs];
    end
    if strcmp(attrsToAdd,'+ModuleName')
        takeAttrs=[{'ModuleName',rmidoors.getModuleAttribute(targetModule,'Name')};takeAttrs];
    end



    if~isempty(takeAttrs)

        takeAttrs(:,1)=strcat(takeAttrs(:,1),{': '});

        depths=[depths;0];
        items=[items;{takeAttrs}];
    end
end

