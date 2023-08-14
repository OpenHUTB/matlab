function[inputDataParentName,signalID,fileName]=getSignalDataForMap(repo,dbIds,inputMap,Signals,mappingMode,kMap)
















    inputDataParentName='';

    idxArray=strfind(inputMap.DataSourceName,'(:');

    if~isempty(idxArray)
        dataName=inputMap.DataSourceName(1:idxArray-1);
    else
        dataName=inputMap.DataSourceName;
    end

    signalID=[];
    if isa(Signals.Data{1},'Simulink.SimulationData.Dataset')



        fileName=getMetaDataByName(repo,dbIds(1),'FileName');

        childIds=getChildrenIds(repo,dbIds(1));


        if strcmpi(mappingMode,'index')||strcmpi(mappingMode,'portorder')
            if(kMap<=length(childIds))
                signalID=childIds(kMap);
            else
                signalID=-1;
            end
            inputDataParentName=Signals.Names{1};
        else


            for kChild=1:length(childIds)


                if strcmp(dataName,getVariableName(repo,childIds(kChild)))
                    signalID=childIds(kChild);
                    inputDataParentName=Signals.Names{1};
                    break;
                end

            end
        end

    else
        idx=strcmp(dataName,Signals.Names);


        if any(idx)
            fileName=getMetaDataByName(repo,dbIds(idx),'FileName');
            signalID=dbIds(idx);
        else
            fileName='';
        end
    end

