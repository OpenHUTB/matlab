function attribMap=doorsAttribMap(srcModule)



    attribMap=containers.Map('KeyType','char','ValueType','char');






    srcModuleId=strtok(srcModule);
    [curM,curN]=rmidoors.getCurrentObj();

    if~strcmp(srcModuleId,curM)
        rmiut.warnNoBacktrace('Slvnv:slreq_import:NotCurrentDoorsModule',srcModuleId);
        beep;
        return;
    end
    if curN<0


        allIDs=rmidoors.getModuleAttribute(curM,'objectIDs');
        curN=allIDs(1);
    end












    usrAttribs=rmidoors.getObjAttribute(srcModuleId,curN,'user attributes');
    if~isempty(usrAttribs)
        addAttribs(usrAttribs(:,1),true);
    else
        usrAttribs=cell(0,1);
    end


    allAttribs=rmidoors.getObjAttribute(srcModuleId,curN,'all attributes');
    otherAttribs=setdiff(allAttribs(:,1),usrAttribs(:,1));
    addAttribs(otherAttribs,false);


    function addAttribs(attribs,isUsrAttrib)
        isTableAttrib=strncmp(attribs(:,1),'Table',length('Table'));
        isRtfAttrib=strncmp(attribs(:,1),'RTF ',length('RTF '));
        for i=1:length(attribs)
            if isTableAttrib(i)||isRtfAttrib(i)
                continue;
            end
            attrib=attribs{i};
            if isKey(attribMap,attrib)
                continue;
            end
            if any(strcmp(attrib,{'Block Deleted?','Block Name','Block Type'}))
                attribMap(attrib)='';
            elseif isUsrAttrib
                attribMap(attrib)=attrib;
            else
                attribMap(attrib)='';
            end
        end
    end

end
