function nameOfBusObjects=findBusObjects(modelName)




    nameOfBusObjects=Simulink.sta.editor.findBusObjects_ws();

    if~isempty(modelName)&&bdIsLoaded(modelName)


        mdlBusObjects=Simulink.sta.editor.findBusObjects_model_ws(modelName);
        nameOfBusObjects=[nameOfBusObjects,mdlBusObjects];


        busObjectEntries=Simulink.sta.editor.findBusObjects_dd(modelName);



        if~isempty(busObjectEntries)

            dd_BusObjs=cell(1,length(busObjectEntries));


            for k=1:length(busObjectEntries)
                dd_BusObjs{k}=busObjectEntries(k).Name;
            end

            nameOfBusObjects=[nameOfBusObjects,dd_BusObjs];
        end
    end
