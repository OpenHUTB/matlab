function newTestPointNames=uniquifyTestPointNames(sys,includeIOPorts)













    if nargin==1
        includeIOPorts=false;
    end





    portMap=containers.Map('KeyType','double','ValueType','logical');



    testPointPortHandles={};

    testPointNames={};




    allLines=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','FollowLinks','on','LookUnderMasks','all','Type','Line');




    [refMdls,~]=find_mdlrefs(sys,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
    for ii=1:numel(refMdls)-1


        allLines=vertcat(allLines,find_system(refMdls{ii},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','FollowLinks','on','LookUnderMasks','all','Type','Line'));%#ok<AGROW>
    end

    numLines=numel(allLines);


    for ii=1:numLines

        line=allLines(ii);


        srcPort=get_param(line,'SrcPortHandle');

        if~isKey(portMap,srcPort)

            portBlock=get_param(srcPort,'Parent');


            if strcmpi(get_param(srcPort,'TestPoint'),'on')&&strcmpi(get_param(portBlock,'Commented'),'off')
                portMap(srcPort)=true;


                lineName=get_param(line,'Name');
                if isempty(lineName)

                    lineName='TestPoint';
                    set_param(srcPort,'Name',lineName);
                end

                testPointPortHandles{end+1}=srcPort;%#ok<AGROW>

                testPointNames{end+1}=lineName;%#ok<AGROW>
            else
                portMap(srcPort)=false;
            end
        end
    end


    if includeIOPorts

        testPoints=true(1,numel(testPointNames));

        inports=find_system(sys,'SearchDepth',1,'BlockType','Inport');
        inportNames=reshape(get_param(inports,'Name'),1,numel(inports));
        inportHandles=reshape(get_param(inports,'Handle'),1,numel(inports));


        testPointNames=horzcat(testPointNames,inportNames);
        testPointPortHandles=horzcat(testPointPortHandles,inportHandles);
        testPoints=horzcat(testPoints,false(1,numel(inports)));

        outports=find_system(sys,'SearchDepth',1,'BlockType','Outport');
        outportNames=reshape(get_param(outports,'Name'),1,numel(outports));
        outportHandles=reshape(get_param(outports,'Handle'),1,numel(outports));


        testPointNames=horzcat(testPointNames,outportNames);
        testPointPortHandles=horzcat(testPointPortHandles,outportHandles);
        testPoints=horzcat(testPoints,false(1,numel(outports)));

        [newTestPointNames,modified]=matlab.lang.makeUniqueStrings(testPointNames,testPoints);
        numTestPoints=numel(testPointNames);

        for ii=1:numTestPoints
            if modified(ii)
                set_param(testPointPortHandles{ii},'Name',newTestPointNames{ii});
            end
        end

        newTestPointNames=setdiff(newTestPointNames,union(inportNames,outportNames));
    else

        [newTestPointNames,modified]=matlab.lang.makeUniqueStrings(testPointNames);
        numTestPoints=numel(testPointNames);

        for ii=1:numTestPoints
            if modified(ii)
                set_param(testPointPortHandles{ii},'Name',newTestPointNames{ii});
            end
        end
    end

end
