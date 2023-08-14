function data_store_sid=getDataStoreSID(obj)



    sid=Simulink.ID.getSID(obj);
    block_type=get_param(sid,'BlockType');
    if(strcmp(block_type,'DataStoreRead')||strcmp(block_type,'DataStoreWrite'))
        dsname=get_param(sid,'DataStoreName');
        parent=get_param(sid,'Parent');
        while~isempty(parent)
            data_store_list=find_system(parent,'SearchDepth',1,...
            'LookUnderMasks','all',...
            'LookUnderReadProtectedSubsystems','on',...
            'BlockType','DataStoreMemory');
            for i=1:numel(data_store_list)
                data_store_name=get_param(data_store_list{i},'DataStoreName');
                if(strcmp(dsname,data_store_name))
                    obj=get_param(data_store_list{i},'Object');
                    data_store_sid=Simulink.ID.getSID(obj);
                    return;
                end
            end
            parent=get_param(parent,'Parent');
        end
    else
        m='Slci:slci:InvalidDataStoreType';
        DAStudio.error(m);
    end
    data_store_sid='';
end
