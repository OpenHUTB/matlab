function dtBlks=getTopicBusObjectValue(modelName,dtBlks)







    baseVars=evalin('base','whos');
    baseVarNames={baseVars.name};


    hws=get_param(modelName,'modelworkspace');


    for idx=1:length(dtBlks)
        blk=dtBlks{idx};
        busName=blk.BlockTopicName;
        busValue='';


        if any(strcmp(baseVarNames,busName))
            busValue=evalin('base',busName);


        elseif hws.hasVariable(busName)
            busValue=hws.getVariable(busName);
        end

        blk.BlockTopicValue=busValue;
        dtBlks{idx}=blk;
    end

end
