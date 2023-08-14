function repoSpec=writeMappingToRepository(repo,inputSpecID,aInputSpec,dbIds,Signals,varargin)











    eng=sdi.Repository(true);

    customMapFile=aInputSpec.CustomSpecFile;

    if isempty(customMapFile)
        customMapFile='';
    end

    if length(varargin)>0
        scenario_sessionID=varargin{1};
    else
        scenario_sessionID=[];
    end


    repoSpec=eng.safeTransaction(@lCreateInputSpec,inputSpecID,...
    aInputSpec.Mode,aInputSpec.LastModelUsed,...
    customMapFile,aInputSpec.Verify,...
    aInputSpec.AllowPartial,aInputSpec.InputString,scenario_sessionID);





    mapIds=repoSpec.getInputMapIDs();


    for kMap=1:length(mapIds)
        repoSpec.removeInputMapByID(mapIds(kMap));
    end

    nInputMap=length(aInputSpec.InputMap);


    for k=1:nInputMap

        inputDataName=aInputSpec.InputMap(k).DataSourceName;

        inMapInputString=aInputSpec.InputMap(k).InputString;

        [inputDataParentName,signalID,fileName]=getSignalDataForMap(...
        repo,dbIds,aInputSpec.InputMap(k),Signals,aInputSpec.Mode,k);



        if isempty(aInputSpec.InputMap(k).DataSourceName)&&~ischar(aInputSpec.InputMap(k).DataSourceName)
            inputDataName='[ ]';
            inMapInputString='[ ]';
            fileName='';
        end



        repoInputMap=eng.safeTransaction(@lCreateInputMap,aInputSpec.InputMap(k),...
        inputDataName,signalID,repoSpec,inputDataParentName,inMapInputString);

    end




    function repoSpec=lCreateInputSpec(inputSpecID,mappingMode,modelName,...
        customFileName,compile,allowPartial,inputString,scenario_sessionID)


        if isempty(inputSpecID)
            repoSpec=sta.InputSpecification();
        else

            repoSpec=sta.InputSpecification(inputSpecID);
        end
        repoSpec.MappingMode=mappingMode;
        repoSpec.DefaultModel=modelName;
        repoSpec.CustomFile=customFileName;
        repoSpec.Verify=compile;
        repoSpec.AllowPartial=allowPartial;
        repoSpec.InputString=inputString;

        if~isempty(scenario_sessionID)
            repoSpec.ScenarioID=scenario_sessionID;
        end

        function repoInputMap=lCreateInputMap(inputMap,inputDataName,signalID,repoSpec,inputDataParentName,inputString)


            repoMapDestination=sta.MapDestination();
            repoInputMap=sta.InputMap();


            repoMapDestination.BlockName=inputMap.BlockName;
            repoMapDestination.BlockPath=inputMap.BlockPath;
            if~isempty(inputMap.SignalName)
                repoMapDestination.SignalName=inputMap.SignalName;
            else
                repoMapDestination.SignalName='';
            end
            if~isempty(inputMap.PortNumber)
                repoMapDestination.PortIndex=inputMap.PortNumber;
            else

                repoMapDestination.PortIndex=-1;
            end
            repoMapDestination.SID=inputMap.Destination.SSID;
            repoMapDestination.Type=inputMap.Type;



            repoInputMap.DestID=repoMapDestination.ID;


            if~isempty(signalID)
                repoInputMap.SignalID=signalID;
            end

            switch(inputMap.Status)
            case 0
                repoStatus='Error';
            case 1
                repoStatus='NoError';
            case 2
                repoStatus='Warning';
            case-1
                repoStatus='Unknown';
            end

            repoInputMap.Status=repoStatus;

            if strcmp(inputDataName,'[ ]')
                repoInputMap.InputName='';
            else
                repoInputMap.InputName=inputDataName;
            end

            repoInputMap.InputParentName=inputDataParentName;
            repoInputMap.InputString=inputString;

            repoSpec.addInputMapByID(repoInputMap.ID);