function notAvailable=calculateMappingAvailable(dbIds,mapNotAvailableMask,modelName,appInstanceID,varargin)















    if~isempty(modelName)
        [~,modelName,~]=fileparts(modelName);
    end

    aFactory=starepository.repositorysignal.Factory;


    if isempty(mapNotAvailableMask)
        mapNotAvailableMask=false(1,5);
    end


    repoUtil=starepository.RepositoryUtility();

    for k=1:length(dbIds)
        dataformat=repoUtil.getMetaDataByName(dbIds(k),'dataformat');


        if any(strcmp(dataformat,{'structwithtime','structwithouttime'}))

            mapNotAvailableMask(2:end-1)=true;


            break;

        elseif any(strcmp(dataformat,{'dataarray'}))
            concreteExtractor=aFactory.getSupportedExtractor(dbIds(k));
            [sig,~]=concreteExtractor.extractValue(dbIds(k));

            if~isempty(modelName)

                inportNames=Simulink.iospecification.InportProperty.getInportNames(modelName);
                enableNames=Simulink.iospecification.InportProperty.getEnableNames(modelName);
                triggerNames=Simulink.iospecification.InportProperty.getTriggerNames(modelName);
                portNames=[inportNames',enableNames',triggerNames'];


                numPorts=length(portNames);


                dims=size(sig);







                if numPorts==dims(2)-1
                    mapNotAvailableMask(2:end)=true;


                    break;
                else
                    mapNotAvailableMask(4)=true;
                end
            else
                mapNotAvailableMask(4)=true;
            end










        elseif any(strcmp(dataformat,{'timeseries','busstructure','aobbusstructure','functioncall'}))
            mapNotAvailableMask(4)=true;


        elseif strcmpi(dataformat,'dataset')


            kidIds=repoUtil.getChildrenIds(dbIds(k));




            dsElNames=cell(1,length(kidIds));
            dsBlkPaths=cell(1,length(kidIds));


            for kChild=1:length(kidIds)


                dsElNames{kChild}=repoUtil.getVariableName(kidIds(kChild));


                blkPath=repoUtil.getMetaDataByName(kidIds(kChild),'BlockPath');





                if~isempty(blkPath)&&ischar(blkPath)
                    dsBlkPaths{kChild}=blkPath;
                end

            end





            if length(dsElNames)~=length(unique(dsElNames))





                mapNotAvailableMask(2:end)=true;
                break;
            end

            isIDXEmpty=cellfun(@isempty,dsBlkPaths);
            dsBlkPaths(isIDXEmpty)=[];





            if~isempty(dsBlkPaths)&&(length(dsBlkPaths)~=length(unique(dsBlkPaths)))

                mapNotAvailableMask(4)=true;
            end

        end

    end


    notAvailable.Index=mapNotAvailableMask(1);
    notAvailable.SignalName=mapNotAvailableMask(2);
    notAvailable.BlockName=mapNotAvailableMask(3);
    notAvailable.BlockPath=mapNotAvailableMask(4);
    notAvailable.Custom=mapNotAvailableMask(5);


    if isempty(varargin)

        fullChannel=sprintf('/sta%s/%s',appInstanceID,'SignalAuthoring/MappingModeDisable');
    else

        fullChannel=sprintf('%s%s/%s',varargin{1},appInstanceID,'SignalAuthoring/MappingModeDisable');
    end
    message.publish(fullChannel,notAvailable);
