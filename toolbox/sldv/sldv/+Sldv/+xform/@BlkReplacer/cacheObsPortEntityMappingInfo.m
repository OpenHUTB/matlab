function cacheObsPortEntityMappingInfo(obj)
















    obj.ObsPortEntityMappingInfo=containers.Map('KeyType','char','ValueType','any');


    obsModelHs=Simulink.observer.internal.getObserverModelsForBD(obj.MdlInfo.ModelH);

    for obsMdlNo=1:numel(obsModelHs)
        obsPortHs=...
        Simulink.observer.internal.getObserverPortsInsideObserverModel(obsModelHs(obsMdlNo));

        for obsPortNo=1:numel(obsPortHs)

            obsEntityInfo.type=...
            Simulink.observer.internal.getObservedEntityType(obsPortHs(obsPortNo));




            obsEntityInfo.obsPortBlkH=obsPortHs(obsPortNo);





            obsEntityFullSpec=Simulink.observer.internal.getObservedEntity(obsPortHs(obsPortNo));
            obsEntitySplitSpec=string(split(obsEntityFullSpec,'|'));






            if(obsEntitySplitSpec(1)=="SFS")
                obsEntityInfo.portIDOrSSId=str2double(obsEntitySplitSpec(end));
                obsEntityInfo.activityType=convertStringsToChars(obsEntitySplitSpec(end-1));
                obsEntitySplitSpec(end-1)=[];
            else
                obsEntityInfo.portIDOrSSId=str2double(obsEntitySplitSpec(end));
                obsEntityInfo.activityType="";
            end
            obsEntitySplitSpec(1)=[];
            obsEntitySplitSpec(end)=[];









            obsEntityInfo.blockFullName=[];
            obj.addObsPortEntityMapping(obsEntityInfo,obsEntitySplitSpec);









            obsEntitySID=obsEntitySplitSpec(end);
            if(1<length(obsEntitySplitSpec)&&...
                ~strcmp(get_param(obsEntitySID,'BlockType'),'ModelReference'))






                obsEntityInfo.blockFullName=extractAfter(getfullname(obsEntitySID),'/');




                obsEntitySplitSpec(end)=[];
                obj.addObsPortEntityMapping(obsEntityInfo,obsEntitySplitSpec);
            end
        end
    end

end

