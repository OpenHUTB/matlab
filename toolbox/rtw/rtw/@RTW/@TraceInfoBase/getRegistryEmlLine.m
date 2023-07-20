function out=getRegistryEmlLine(h,tag)




    out=[];
    colons=strfind(tag,':');

    if length(colons)<2||colons(end)==length(tag)||colons(end-1)==1
        return
    end
    blockPath=tag(1:colons(end-1)-1);
    ssIdNum=tag(colons(end-1)+1:colons(end)-1);
    if~isempty(strfind(tag,'/'))
        sysIdx=find(arrayfun(@(x)strcmp(x.pathname,blockPath),h.SystemMap));
    else
        sysIdx=find(arrayfun(@(x)strcmp(x.sid,blockPath),h.SystemMap));
    end
    if isempty(sysIdx)
        return
    end

    systype=h.SystemMap(sysIdx).type;
    if~strcmpi(systype,'MATLAB Function')&&...
        ~strcmpi(systype,'Chart')
        return
    end
    lineNum=sscanf(tag(colons(end):end),':%d');
    if isempty(lineNum)
        return
    end

    first=h.SystemMap(sysIdx).location;
    if sysIdx==length(h.SystemMap)
        last=length(h.Registry);
    else
        last=h.SystemMap(sysIdx+1).location-1;
    end
    for k=first:last
        [ssIdNum2,aux2]=strtok(h.Registry(k).name,':');
        if isempty(aux2)||~strcmp(ssIdNum2,ssIdNum)
            continue
        end
        lineNum2=sscanf(aux2,':%d');

        if~isempty(lineNum2)&&lineNum2>=lineNum
            out=h.Registry(k);
            break
        end
    end