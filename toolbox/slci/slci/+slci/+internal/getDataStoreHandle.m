function handle=getDataStoreHandle(obj)



    handle=-1;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        sid=Simulink.ID.getSID(obj);
        block_type=get_param(sid,'BlockType');
        if(strcmp(block_type,'DataStoreRead')||strcmp(block_type,'DataStoreWrite'))
            dsname=get_param(sid,'DataStoreName');
            parent=get_param(sid,'Parent');
            while~isempty(parent)
                if~strcmpi(get_param(parent,'type'),'block_diagram')
                    dsname=Simulink.mapDataStoreName(parent,dsname);
                end
                obj=get_param(parent,'Object');
                block_list=obj.getCompiledBlockList();
                block_handle_idx=...
                arrayfun(@(x)strcmpi(get_param(x,'BlockType'),'DataStoreMemory')...
                &&strcmpi(get_param(x,'DataStoreName'),dsname),block_list);
                block_handle=block_list(block_handle_idx);

                for i=1:numel(block_handle)
                    handle=block_handle(i);
                    blk_obj=get_param(handle,'object');
                    if(~blk_obj.isSynthesized)
                        return;
                    end



                end
                parent=get_param(parent,'Parent');
            end
        else
            m='Slci:slci:InvalidDataStoreType';
            DAStudio.error(m);
        end
    end
end
