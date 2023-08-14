function repoSpec=inputSpecificationToRepository(inSpec)







    repoSpec=sta.InputSpecification();



    repoSpec.DiagnosisMode=inSpec.MappingDiagnostic;
    repoSpec.MappingMode=inSpec.Mode;

    if~isempty(inSpec.LastModelUsed)
        repoSpec.DefaultModel=inSpec.LastModelUsed;
    else
        repoSpec.DefaultModel='';
    end


    if~isempty(inSpec.CustomSpecFile)
        repoSpec.CustomFile=inSpec.CustomSpecFile;
    end

    repoSpec.Verify=logical(inSpec.Verify);
    repoSpec.AllowPartial=logical(inSpec.AllowPartial);



    for kMap=1:length(inSpec.InputMap)


        repoMap=sta.InputMap();

        repoSpec.addInputMapByID(repoMap.ID);


        repoDest=sta.MapDestination();


        repoMap.DestID=repoDest.ID;
        if~isempty(inSpec.InputMap(kMap).DataSourceName)
            repoMap.InputName=inSpec.InputMap(kMap).DataSourceName;
        end


        switch(inSpec.InputMap(kMap).Status)
        case-1
            repoMap.Status='Unknown';
        case 0
            repoMap.Status='Error';
        case 1
            repoMap.Status='NoError';
        case 2
            repoMap.Status='Warning';
        end


        repoDest.BlockName=inSpec.InputMap(kMap).BlockName;
        repoDest.BlockPath=inSpec.InputMap(kMap).BlockPath;
        repoDest.SignalName=inSpec.InputMap(kMap).SignalName;
        repoDest.PortIndex=inSpec.InputMap(kMap).PortNumber;
        repoDest.SID=inSpec.InputMap(kMap).Destination.SSID;
        repoDest.Type=inSpec.InputMap(kMap).Type;


    end