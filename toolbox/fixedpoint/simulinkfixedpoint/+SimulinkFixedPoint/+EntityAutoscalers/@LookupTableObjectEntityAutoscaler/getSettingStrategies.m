function pv=getSettingStrategies(ea,dataObjectWrapper,pathItem,~)




    index=[];
    if~strcmp(pathItem,'Table')
        index=ea.getIndexFromBreakpointPathitem(pathItem);
    end
    pv{1,1}={'LUTObjectStrategy',dataObjectWrapper,pathItem,index};
end