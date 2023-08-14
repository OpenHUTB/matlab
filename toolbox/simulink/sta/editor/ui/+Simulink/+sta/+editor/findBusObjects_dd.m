function busObjectEntries=findBusObjects_dd(modelName)

    busObjectEntries=[];

    dd_name=get(get_param(modelName,'Handle'),'DataDictionary');

    if~isempty(dd_name)

        dictObj=Simulink.data.dictionary.open(dd_name);
        sectObj=getSection(dictObj,'Design Data');
        busObjectEntries=find(sectObj,'-value','-class','Simulink.Bus');

    end