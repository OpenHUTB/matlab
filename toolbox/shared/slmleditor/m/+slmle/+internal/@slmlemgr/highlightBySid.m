function highlightBySid(obj,sids,studio)




    if~iscell(sids)
        sids={sids};
    end


    map=containers.Map;
    for i=1:length(sids)
        sid=sids{i};
        arr=strsplit(sid,':');
        last=arr{end};
        range=strsplit(last,'-');
        if length(range)==2
            key=strjoin(arr(1:end-1),':');
            val=[str2double(range{1}),str2double(range{2})];
            if map.isKey(key)
                v=map(key);
                v{end+1}=val;
                map(key)=v;
            else
                map(key)={val};
            end
        end
    end

    keys=map.keys;
    for i=1:length(keys)
        sid=keys{i};


        h=Simulink.ID.getHandle(sid);
        if isa(h,'Stateflow.State')
            continue;
        end

        name=Simulink.ID.getFullName(sid);
        objectId=obj.getObjectId(name);

        if obj.MLFBEditorMap.isKey(objectId)
            ranges=map(sid);
            arr=obj.MLFBEditorMap(objectId);
            for j=1:length(arr)
                ed=arr{j};
                if isvalid(ed.studio)&&ed.studio==studio
                    ed.highlightMultiRanges(ranges);
                end
            end
        end
    end
