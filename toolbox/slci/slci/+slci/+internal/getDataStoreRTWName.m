function RTWName=getDataStoreRTWName(obj)


    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        sid=Simulink.ID.getSID(obj);
        block_type=get_param(sid,'BlockType');
        if(strcmp(block_type,'DataStoreRead')||strcmp(block_type,'DataStoreWrite'))
            dsname=get_param(sid,'DataStoreName');
            parent=get_param(sid,'Parent');
            while~isempty(parent)
                obj=get_param(parent,'Object');
                block_list=obj.getCompiledBlockList();
                for i=1:numel(block_list)
                    if strcmpi(get_param(block_list(i),'BlockType'),'DataStoreMemory')
                        data_store_name=get_param(block_list(i),'DataStoreName');
                        if(strcmp(dsname,data_store_name))
                            obj=get_param(block_list(i),'Object');
                            RTWName=getRTWName(obj);
                            return;
                        end
                    end
                end
                parent=get_param(parent,'Parent');
            end
        else
            m='Slci:slci:InvalidDataStoreType';
            DAStudio.error(m);
        end
        RTWName='';
    end
end
