function[dataStoreNames,handles]=getDataStoreHandlesByName(obj,listOfDataStoreNames)



    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>






    try %#ok
        handles=[];
        dataStoreNames={};
        sid=Simulink.ID.getSID(obj);
        processed={};
        parent=get_param(sid,'Parent');
        while(~isempty(parent)||...
            (numel(processed)==numel(listOfDataStoreNames)))
            obj=get_param(parent,'Object');
            block_list=obj.getCompiledBlockList();
            for i=1:numel(block_list)
                if strcmpi(get_param(block_list(i),'BlockType'),'DataStoreMemory')
                    data_store_name=get_param(block_list(i),'DataStoreName');


                    if(~any(strcmp(processed,data_store_name))...
                        &&any(strcmp(listOfDataStoreNames,data_store_name)))
                        dataStoreNames{end+1}=data_store_name;%#ok
                        handles(end+1)=block_list(i);%#ok
                        processed{end+1}=data_store_name;%#ok 
                    end
                end
            end
            parent=get_param(parent,'Parent');
        end
    end
end
