function RTWName=getDataStoreReadOrWriteRTWName(obj)




    sid=Simulink.ID.getSID(obj);
    block_type=get_param(sid,'BlockType');
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    if(strcmp(block_type,'DataStoreMemory'))
        dsname=get_param(sid,'DataStoreName');
        parent=get_param(sid,'Parent');
        while~isempty(parent)


            data_store_read_or_write_list=find_system(...
            parent,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Regexp','on',...
            'LookUnderMasks','all',...
            'LookUnderReadProtectedSubsystems','on',...
            'BlockType','DataStoreRead|DataStoreWrite');
            for i=1:numel(data_store_read_or_write_list)
                data_store_name=get_param(data_store_read_or_write_list{i},'DataStoreName');
                if(strcmp(dsname,data_store_name))
                    obj=get_param(data_store_read_or_write_list{i},'Object');
                    RTWName=getRTWName(obj);
                    return;
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
