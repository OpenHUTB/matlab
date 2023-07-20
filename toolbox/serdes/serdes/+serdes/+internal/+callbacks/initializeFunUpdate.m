




function initializeFunUpdate(block)
    if isstring(block)
        block=char(block);
    end

    constants=serdes.internal.callbacks.InitConstants;

    txOrRxBlockName=extractAfter(block,[bdroot(block),'/']);
    if contains(txOrRxBlockName,'/')
        txOrRxBlockName=extractBefore(txOrRxBlockName,'/');
    end
    mainSubSystem=[bdroot(block),'/',txOrRxBlockName];
    mlFcnName=[mainSubSystem,'/Init/Initialize Function/MATLAB Function'];
    mlFcnHandle=get_param(mlFcnName,'Handle');
    initFcnName=[mainSubSystem,'/Init/Initialize Function'];
    emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);
    inport=find_system(mainSubSystem,'SearchDepth',1,'BlockType','Inport');
    outport=find_system(mainSubSystem,'SearchDepth',1,'BlockType','Outport');

    rootSystem=bdroot(mainSubSystem);
    mws=get_param(rootSystem,'ModelWorkspace');
    tree=mws.getVariable([extractAfter(mainSubSystem,[rootSystem,'/']),'Tree']);

    if strcmp(tree.Direction,tree.RxDirectionFlag)
        direction='Rx';
        oppositeDirection='Tx';
    else
        direction='Tx';
        oppositeDirection='Rx';
    end

    [isExternalInit,isCommentOutStep]=serdes.internal.callbacks.getRefreshInitOptions(block,direction,oppositeDirection);

    [nameHandleStruct,CDRInfo]=findAllBlocks(inport,outport,constants);

    [functionBody,stepCall,customAMIParameters,lostAMIParameters,inOutOutMap,addToFunctionArgs,addToReturnArgs,suppressFunSignatureWarning]=...
    generateFunBodyStep(nameHandleStruct,CDRInfo,tree,mws,constants,direction);
    signatureLine=generateFunSignature(addToReturnArgs,addToFunctionArgs,constants,suppressFunSignatureWarning);
    savedUserCode=generateCustomUserCode(emChart,customAMIParameters,lostAMIParameters,direction);
    if strcmp(savedUserCode,"")
        return
    end
    impulseOutLine=generateImpulseOut(constants);

    if isCommentOutStep
        stepCall=commentStep(stepCall);
    end

    fcnCode=strjoin([signatureLine,functionBody,savedUserCode,stepCall,impulseOutLine],'\n');

    emChart.Script=fcnCode;

    serdes.utilities.externalinit.setupExternalInit(rootSystem,direction,~isExternalInit);

    setupMATLABFunInOut(emChart,mlFcnHandle,initFcnName,inOutOutMap,constants)

    set_param(initFcnName,'ZoomFactor','FitSystem');


    editor=GLUE2.Util.findAllEditors(mainSubSystem);
    if~isempty(editor)
        editor.closeNotificationByMsgID('serdes:callbacks:RefreshInitRequired');
    end


    serdes.internal.callbacks.maskApply(block);
end

function[nameHandleStruct,CDRInfo]=findAllBlocks(inport,outport,constants)
    nameHandleStruct=[];
    atOutport=false;
    hop=1;
    CDRInfo.numberOfCDR=0;
    CDRInfo.hopOfLastCDR=0;
    if isempty(inport)||isempty(outport)
        error(message('serdes:callbacks:OneInOneOutRequiredForInit'));
    end
    currentPort=inport{1};
    outportHandle=get_param(outport{1},'Handle');
    while~atOutport
        targetPortConnectivity=findFirstPort(currentPort,true);
        nextBlockHandle='';
        [nextBlockHandle,nameHandleStruct,hop,CDRInfo]=...
        findNextBlockHandle(nextBlockHandle,targetPortConnectivity.DstBlock,nameHandleStruct,hop,CDRInfo,outportHandle,constants);
        if nextBlockHandle~=outportHandle
            currentPort=nextBlockHandle;
        else
            atOutport=true;
        end
    end



end


function[nextBlockHandle,nameHandleStruct,hop,CDRInfo]=findNextBlockHandle(nextBlockHandle,dstBlock,nameHandleStruct,hop,CDRInfo,outportHandle,constants)

    numberOfDst=size(dstBlock,2);
    for connectIdx=1:numberOfDst
        libraryType=serdes.internal.callbacks.getLibraryBlockType(dstBlock(connectIdx));
        if~isempty(libraryType)&&strcmp(libraryType,'CDR')
            [nameHandleStruct,hop,CDRInfo]=addHop(nameHandleStruct,hop,dstBlock(connectIdx),CDRInfo);
        end
    end

    for connectIdx=1:numberOfDst
        libraryType=serdes.internal.callbacks.getLibraryBlockType(dstBlock(connectIdx));
        if~isempty(libraryType)&&~strcmp(libraryType,'CDR')&&any(contains(constants.stDatapathBlocks,libraryType))
            nextBlockHandle=dstBlock(connectIdx);
            [nameHandleStruct,hop,CDRInfo]=addHop(nameHandleStruct,hop,nextBlockHandle,CDRInfo);
        elseif isempty(libraryType)&&outportHandle==dstBlock(connectIdx)
            nextBlockHandle=dstBlock(connectIdx);
        end
    end

    if isempty(nextBlockHandle)
        error(message('serdes:callbacks:InportToOutportNotConnected'));
    end
end


function[struct,hop,CDRInfo]=addHop(struct,hop,dstBlock,CDRInfo)
    nextBlockName=get_param(dstBlock,'Name');
    blockLibraryName=serdes.internal.callbacks.getLibraryBlockType(dstBlock);

    blockInport=find_system(dstBlock,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','Inport');
    blockOutport=find_system(dstBlock,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','Outport');

    if strcmp(blockLibraryName,'CDR')&&isempty(blockOutport)

        cdrSO=find_system(dstBlock,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on',...
        'BlockType','MATLABSystem',...
        'System','serdes.CDR');

        blocksInOrder={};
        blocksInOrderOther={cdrSO(1)};
    else
        [blocksInOrder,blocksInOrderOther]=walkTheLine(blockInport,blockOutport);
    end

    soCount=length(blocksInOrder);

    soOtherContentCount=sum(~cellfun(@isempty,blocksInOrderOther),2);
    soOtherCount=length(blocksInOrderOther);

    if soCount+soOtherContentCount>1
        nameIncrement=1;
    else
        nameIncrement=[];
    end



    for soIdx=1:soOtherCount





        currentOtherSO=blocksInOrderOther{soIdx};
        if~isempty(currentOtherSO)
            numCurrentSO=length(currentOtherSO);
            for otherSOIdx=1:numCurrentSO



                if~isempty(struct)
                    previouslyAdded=any(ismember([struct.soHandle],currentOtherSO(otherSOIdx)));
                else
                    previouslyAdded=false;
                end
                commentStatus=get_param(currentOtherSO(otherSOIdx),'Commented');
                if~strcmp(commentStatus,'on')&&~strcmp(commentStatus,'through')&&~previouslyAdded
                    nextBlockSOName=get_param(currentOtherSO(otherSOIdx),'Name');
                    struct(hop).blockName=nextBlockName;
                    struct(hop).blockHandle=dstBlock;
                    struct(hop).blockLibrary=blockLibraryName;
                    struct(hop).soName=nextBlockSOName;
                    struct(hop).soHandle=currentOtherSO(otherSOIdx);
                    struct(hop).initName=[nextBlockName,num2str(nameIncrement)];
                    struct(hop).hasOutput=false;
                    nameIncrement=nameIncrement+1;

                    [found,~]=findPAMReferences(dstBlock);
                    if found.PAM4||found.PAMN
                        CDRInfo.numberOfCDR=CDRInfo.numberOfCDR+1;
                        CDRInfo.hopOfLastCDR=hop;
                    end
                    hop=hop+1;
                end
            end
        end

        if soIdx<=soCount

            currentSO=blocksInOrder{soIdx};
            commentStatus=get_param(currentSO,'Commented');
            blockType=get_param(currentSO,'BlockType');
            nextBlockSOName=get_param(currentSO,'Name');

            struct(hop).blockName=nextBlockName;
            struct(hop).blockHandle=dstBlock;
            struct(hop).blockLibrary=blockLibraryName;
            struct(hop).soName=nextBlockSOName;
            struct(hop).initName=[nextBlockName,num2str(nameIncrement)];
            struct(hop).hasOutput=true;

            if~isempty(currentSO)&&~strcmp(commentStatus,'on')&&~strcmp(commentStatus,'through')&&strcmp(blockType,'MATLABSystem')

                struct(hop).soHandle=currentSO;

                [found,~]=findPAMReferences(dstBlock);
                if found.PAM4||found.PAMN
                    CDRInfo.numberOfCDR=CDRInfo.numberOfCDR+1;
                    CDRInfo.hopOfLastCDR=hop;
                end
            elseif strcmp(commentStatus,'on')

                struct(hop).soHandle=[];
                questdlg(message('serdes:callbacks:SkipCommented',nextBlockSOName,nextBlockName).getString,'Warning','OK','OK');
            elseif strcmp(commentStatus,'through')

                struct(hop).soHandle=[];
                questdlg(message('serdes:callbacks:SkipCommentedThrough',nextBlockSOName,nextBlockName).getString,'Warning','OK','OK');
            else

                struct(hop).soHandle=[];
                questdlg(message('serdes:callbacks:SkipNonSO',nextBlockSOName,nextBlockName).getString,'Warning','OK','OK');
            end

            hop=hop+1;
            nameIncrement=nameIncrement+1;
        end
    end


    if soOtherCount==0&&soCount==0
        struct(hop).blockName=nextBlockName;
        struct(hop).blockHandle=dstBlock;
        struct(hop).blockLibrary=blockLibraryName;
        struct(hop).soName=[];
        struct(hop).soHandle=[];
        struct(hop).initName=[];
        struct(hop).hasOutput=true;
        hop=hop+1;
    end
end

function setupMATLABFunInOut(funHandle,mlFcnHandle,initFcnName,inOutOutMap,constants)




    inputs=funHandle.Inputs;
    functionOutputs=funHandle.Outputs;
    for inputIdx=length(inputs):-1:1
        input=inputs(inputIdx);
        if~strcmp(input.name,'ImpulseIn')
            input.Scope='Parameter';
        end
    end

    sizeFunctionOutputs=size(functionOutputs,1);


    existingDataStoreWrites=find_system(initFcnName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DataStoreWrite');
    sizeExistingDataStoreWrites=size(existingDataStoreWrites,1);
    if sizeFunctionOutputs==0
        error(message('serdes:callbacks:InitFunRequiresImpulseOut'));
    else

        foundImpulse=false;
        for dataStoreIdx=1:sizeExistingDataStoreWrites
            if~endsWith(existingDataStoreWrites(dataStoreIdx),'ImpulseOut')
                delete_block(existingDataStoreWrites(dataStoreIdx));
            else
                impulse=existingDataStoreWrites(dataStoreIdx);

                previousDataStoreHandle=get_param(impulse,'Handle');
                previousPosition=get_param(previousDataStoreHandle{1},'Position');
                foundImpulse=true;
            end
        end



        delete_line(find_system(initFcnName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','Type','line','Connected','off'));

        if~foundImpulse
            mapValue={'DataStoreName','ImpulseMatrix'};
            newFeedPath=[initFcnName,'/','ImpulseOut'];
            newFeedHandle=add_block(constants.mlDataStoreWriteBlock,newFeedPath,'MakeNameUnique','on');
            set_param(newFeedHandle,mapValue{:});

            blockPortHandles=get_param(mlFcnHandle,'PortHandles');
            feedPortHandles=get_param(newFeedHandle,'PortHandles');
            blockPort=blockPortHandles.Outport;
            feedPorts=feedPortHandles.Inport;
            blockPortPosition=get_param(blockPort(1),'Position');
            previousPosition=[blockPortPosition,blockPortPosition];
            deltaX=60;
            deltaY=-15;
            deltaWidth=80;
            deltaHeight=30;
            newPosition=[previousPosition(1)+deltaX,...
            previousPosition(2)+deltaY,...
            previousPosition(3)+deltaX+deltaWidth,...
            previousPosition(4)+deltaY+deltaHeight];
            set_param(newFeedHandle,'Position',newPosition);

            matchingPortHandle=blockPort(1);

            feedPort=feedPorts(1);

            add_line(initFcnName,matchingPortHandle,feedPort,'autorouting','on');
            previousPosition=newPosition;
        end

        for outputIdx=1:length(functionOutputs)
            output=functionOutputs(outputIdx);
            if~strcmp(output.name,'ImpulseOut')
                if inOutOutMap.isKey(output.name)
                    mapValue=inOutOutMap(output.name);

                    newFeedPath=[initFcnName,'/',output.name];
                    newFeedHandle=add_block(constants.mlDataStoreWriteBlock,newFeedPath,'MakeNameUnique','on');
                    set_param(newFeedHandle,mapValue{:});

                    heightOfPreviousFeed=(previousPosition(4)-previousPosition(2));
                    deltaY=heightOfPreviousFeed+20;
                    deltaWidth=0;
                    deltaHeight=0;
                    newPosition=[previousPosition(1),...
                    previousPosition(2)+deltaY,...
                    previousPosition(3)+deltaWidth,...
                    previousPosition(4)+deltaY+deltaHeight];
                    set_param(newFeedHandle,'Position',newPosition);

                    blockPortHandles=get_param(mlFcnHandle,'PortHandles');
                    feedPortHandles=get_param(newFeedHandle,'PortHandles');

                    blockPort=blockPortHandles.Outport;
                    feedPorts=feedPortHandles.Inport;

                    indxOfMatchingPort=output.Port;

                    if indxOfMatchingPort>1
                        matchingPortHandle=blockPort(indxOfMatchingPort);

                        feedPort=feedPorts(1);

                        add_line(initFcnName,matchingPortHandle,feedPort,'autorouting','on');
                    end
                    previousPosition=newPosition;
                end
            end
        end
    end
end


function[functionBody,stepCall,customAMIParameters,lostAMIParameters,inOutOutMap,addToFunctionArgs,addToReturnArgs,suppressFunSignatureWarning]=...
    generateFunBodyStep(nameHandleStruct,CDRInfo,tree,mws,constants,direction)
    inOutOutMap=containers.Map;
    customAMIParameters=containers.Map;
    disconnectedAMIParameters=containers.Map;
    connectedAMIParameters=containers.Map;
    lostAMIParameters=containers.Map;
    addToFunctionArgs=string.empty;
    addToReturnArgs=string.empty;
    suppressFunSignatureWarning=[false,false,false];
    addedPAMAssignments=false;
    addPAMReturns=false;
    isRx=strcmp(direction,'Rx');

    modulationMWS=mws.getVariable(constants.modulationParamName);
    modulation=modulationMWS.Value;
    [isPAM,isLegacyPAM]=checkPAM(tree,modulation);

    functionBody="% IMPULSEEQUALIZATION Impulse response processing of SerDes system blocks.";
    functionBody(end+1)="%   impulseEqualization is an automatically generated function which";
    functionBody(end+1)="%   processes impulse responses using SerDes system blocks.";
    functionBody(end+1)="%   It parallels the tasks of the IBIS AMI_Init function.";
    functionBody(end+1)="%% Impulse response formatting";
    functionBody(end+1)="% Size "+constants.impulseOutVar+" by setting it equal to "+constants.impulseInVar;
    functionBody(end+1)=constants.impulseOutVar+" = "+constants.impulseInVar+";";

    functionBody(end+1)="% Reshape "+constants.impulseInVar+" vector into a 2D matrix using RowSize and Aggressors called "+constants.impulseLocalVar;
    functionBody(end+1)=constants.impulseLocalVar+" = zeros(RowSize,Aggressors+1);";

    functionBody(end+1)="AggressorPosition = 1;";
    functionBody(end+1)="for RowPosition = 1:RowSize:RowSize*(Aggressors+1)";
    functionBody(end+1)="    "+constants.impulseLocalVar+"(:,AggressorPosition) = ImpulseIn(RowPosition:RowSize-1+RowPosition)';";
    functionBody(end+1)="    AggressorPosition = AggressorPosition+1;";
    functionBody(end+1)="end";

    stepCall="";
    nameHandleStructSize=size(nameHandleStruct,2);
    for blockIdx=1:nameHandleStructSize
        if~isempty(nameHandleStruct(blockIdx).soHandle)
            functionBody(end+1)="%% Instantiate and setup system objects";
            stepCall="%% Impulse response processing via system objects";
            break;
        end
    end

    for blockIdx=1:nameHandleStructSize
        addPAMAssignments=false;
        foundAMIInOutOnOutputParamMap=containers.Map('KeyType','double','ValueType','char');
        foundAMIOutOnOutputParamMap=containers.Map('KeyType','double','ValueType','char');
        blockName=nameHandleStruct(blockIdx).blockName;
        blockLibrary=nameHandleStruct(blockIdx).blockLibrary;
        blockHandle=nameHandleStruct(blockIdx).blockHandle;
        soHandle=nameHandleStruct(blockIdx).soHandle;
        hasOutput=nameHandleStruct(blockIdx).hasOutput;

        if~isempty(blockLibrary)
            isSerDesLibrary=any(contains(constants.stDatapathBlocks,blockLibrary));
            if~isSerDesLibrary
                questdlg(message('serdes:callbacks:NonSerDesToolboxBlock').getString,'Warning','OK','OK');
            end
        end
        if~isempty(soHandle)
            blockClass=Simulink.Mask.get(soHandle).Type;
            serdesBlockObj=eval(blockClass);
            soMaskObj=Simulink.Mask.get(soHandle);
            isNoSO=false;
        else
            blockClass="No system object";
            serdesBlockObj=[];
            soMaskObj=[];
            isNoSO=true;
        end
        libMaskObj=Simulink.Mask.get(blockHandle);
        if~isempty(libMaskObj)
            libMaskNames={libMaskObj.Parameters.Name};
            libMaskValues={libMaskObj.Parameters.Value};
        end
        if~isempty(soMaskObj)
            soMaskNames={soMaskObj.Parameters.Name};
            soMaskValues={soMaskObj.Parameters.Value};
        end

        [parameterStruct,signalStruct]=tree.simulinkStructs(blockName);
        if~isempty(parameterStruct)&&~isempty(fields(parameterStruct))
            blockParameterName=blockName+"Parameter";
            parameterPrevAdded=any(strcmp(addToFunctionArgs,blockParameterName));
            if isempty(parameterPrevAdded)||~parameterPrevAdded
                addToFunctionArgs(end+1)=blockParameterName;%#ok<*AGROW>
            end
        else
            blockParameterName=[];
        end
        isSatAmp=~isempty(blockParameterName)&&strcmp(blockClass,"serdes.SaturatingAmplifier");
        if~isNoSO
            initName=nameHandleStruct(blockIdx).initName+"Init";
            functionBody(end+1)="% Create instance of "+blockClass+" for "+blockName;



            try
                waveTypeOptions=set(serdesBlockObj,'WaveType');
                doWave=isprop(serdesBlockObj,constants.waveTypeParam)&&any(strcmp(waveTypeOptions(:),'Impulse'));
            catch
                doWave=false;
            end
            functionBody(end+1)=initName+" = "+blockClass+";";
            if doWave
                functionBody(end)=initName+" = "+blockClass+"('"+constants.waveTypeParam+"', 'Impulse');";
            end

            haveParams=constants.waveTypeParam;
            haveParams(end+1)="BlockName";
            haveParams(end+1)="SimulateUsing";
            haveParams(end+1)="SavedName";


            globalParameters={constants.modulationParamName,constants.sampleIntervalParamName,constants.symbolTimeParamName};
            globalPositions=cellfun(@(x)find(strcmp(soMaskNames,x),1),globalParameters,'UniformOutput',false);
            globalHas=cellfun(@(x)~isempty(x),globalPositions);
            suppressFunSignatureWarning=suppressFunSignatureWarning|globalHas;



            printSetupSimulationComment=false;
            for globalParameterIdx=1:size(globalParameters,2)
                if~isempty(globalPositions{globalParameterIdx})
                    missingGlobalParameter(blockName,globalParameters{globalParameterIdx},globalPositions{globalParameterIdx},soMaskObj);

                    blockParam=soMaskNames{globalPositions{globalParameterIdx}};
                    if blockParam~=haveParams
                        if~printSetupSimulationComment
                            functionBody(end+1)="% Setup simulation parameters";
                            printSetupSimulationComment=true;
                        end


                        functionBody(end+1)=initName+"."+blockParam+" = "+soMaskObj.Parameters(globalPositions{globalParameterIdx}).Value+";";
                        haveParams(end+1)=blockParam;
                    end
                end
            end


            params=fields(parameterStruct);

            [inputPortNames,~]=serdes.internal.callbacks.getPortNames(soHandle);
            if~isempty(params)
                functionBody(end+1)="% Setup "+blockName+" In and InOut AMI parameters";
                for paramNum=1:length(params)
                    param=params{paramNum};
                    isTaps=strcmp(param,'TapWeights');
                    if~isTaps
                        [isNew,usage,~]=getAMIParameter(tree,blockName,param);
                    else
                        [isNew,usage,~]=getAMITapsParameter(tree,blockName);
                    end


                    if strcmp(usage,"In")

                        portAndOn=findPortsAndOn(soMaskNames,soMaskValues);
                        paramAsAValueInSOMask=strcmp(soMaskValues,blockParameterName+"."+param);


                        if any(paramAsAValueInSOMask)&&~portAndOn(find(paramAsAValueInSOMask)-1)
                            soMaskName=soMaskNames{paramAsAValueInSOMask};
                            if isNew
                                connectAMIParam(...
                                blockParameterName+"."+param,...
                                initName+"."+soMaskName,...
                                initName+"."+soMaskName+" = "+blockParameterName+"."+param+";"...
                                );
                            else
                                functionBody(end+1)=initName+"."+soMaskName+" = "+blockParameterName+"."+param+";";
                            end
                            haveParams(end+1)=string(soMaskName);
                        else
                            [foundAMI,~]=scanPortsForAMI(soHandle,usage,isTaps,[],param);

                            if foundAMI.InOnIn

                                reservedParameterName=inputPortNames{foundAMI.InOnInConnectIdx};

                                if isNew
                                    connectAMIParam(...
                                    blockParameterName+"."+param,...
                                    initName+"."+reservedParameterName,...
                                    initName+"."+reservedParameterName+" = "+blockParameterName+"."+param+";"...
                                    );
                                else
                                    functionBody(end+1)=initName+"."+reservedParameterName+" = "+blockParameterName+"."+param+";";
                                end
                                haveParams(end+1)=string(reservedParameterName);
                            else


                                disconnectAMIParam(...
                                blockParameterName+"."+param,...
                                blockParameterName+"."+param,...
                                blockParameterName+"."+param+";"...
                                );
                                if~isNew
                                    lostAMIParameters(blockParameterName+"."+param)="";
                                end
                            end
                        end
                    elseif strcmp(usage,"InOut")
                        portAndOn=findPortsAndOn(soMaskNames,soMaskValues);
                        paramAsAValueInSOMask=strcmp(soMaskValues,blockParameterName+"."+param);
                        [foundAMI,foundAMIInOutOnOutputParamMap]=scanPortsForAMI(soHandle,usage,isTaps,foundAMIInOutOnOutputParamMap,param);
                        if any(paramAsAValueInSOMask)&&~portAndOn(find(paramAsAValueInSOMask)-1)
                            soMaskName=soMaskNames{paramAsAValueInSOMask};
                            connectAMIParam(...
                            blockParameterName+"."+param,...
                            initName+"."+soMaskName,...
                            initName+"."+soMaskName+" = "+blockParameterName+"."+param+";"...
                            );
                            haveParams(end+1)=string(soMaskName);
                            foundAMI.InOutOnIn=true;
                        elseif foundAMI.InOutOnIn


                            reservedParameterName=inputPortNames{foundAMI.InOutOnInConnectIdx};

                            if isNew
                                connectAMIParam(...
                                blockParameterName+"."+param,...
                                initName+"."+reservedParameterName,...
                                initName+"."+reservedParameterName+" = "+blockParameterName+"."+param+";"...
                                );
                            else
                                functionBody(end+1)=initName+"."+reservedParameterName+" = "+blockParameterName+"."+param+";";
                            end
                            haveParams(end+1)=string(reservedParameterName);
                        end

                        if~foundAMI.InOutOnIn&&~foundAMI.InOutOnOut
                            disconnectAMIParam(...
                            string(blockName)+param,...
                            string(blockName)+param,...
                            string(blockName)+param+" = "+blockParameterName+"."+param+";"...
                            );
                            if~isNew
                                lostAMIParameters(string(blockName)+param)="";
                            end


                        elseif~foundAMI.InOutOnIn&&foundAMI.InOutOnOut
                            disconnectAMIParam(...
                            blockParameterName+"."+param,...
                            blockParameterName+"."+param,...
                            blockParameterName+"."+param+";"...
                            );
                            if~isNew
                                lostAMIParameters(blockParameterName+"."+param)="";
                            end


                        elseif foundAMI.InOutOnIn&&~foundAMI.InOutOnOut
                            disconnectAMIParam(...
                            string(blockName)+param,...
                            string(blockName)+param,...
                            string(blockName)+param+" = "+blockParameterName+"."+param+";"...
                            );
                            if~isNew
                                lostAMIParameters(string(blockName)+param)="";
                            end
                        end
                    end
                end
            end




            printSetupBlockComment=false;

            for maskParamIdx=1:length(libMaskValues)
                blockParam=libMaskNames{maskParamIdx};
                if blockParam~=haveParams
                    if~endsWith(lower(blockParam),'port')&&...
                        ~endsWith(blockParam,'AMI')&&...
                        strcmp(libMaskObj.Parameters(maskParamIdx).Type,'promote')
                        value=libMaskValues{maskParamIdx};
                        if isa(libMaskObj.Parameters(maskParamIdx).DialogControl,'Simulink.dialog.parameter.CheckBox')
                            value=convertToLogic(value);
                        else
                            value=determineValue(value,blockHandle);
                        end
                        if~printSetupBlockComment
                            functionBody(end+1)="% Setup "+blockName+" block properties";
                            printSetupBlockComment=true;
                        end
                        functionBody(end+1)=printValue(initName,blockParam,value);
                        haveParams(end+1)=blockParam;
                    end
                end
            end

            for maskParamIdx=1:length(soMaskNames)
                blockParam=soMaskNames{maskParamIdx};
                if blockParam~=haveParams
                    if~strcmp(soMaskObj.Parameters(maskParamIdx).Type,'checkbox')









                        addParameter=true;
                        if strcmp(blockParam,'TapWeights')

                            TapWeightsPortIdx=strcmp(soMaskNames,'TapWeightsPort');
                            if any(TapWeightsPortIdx)
                                TapWeightsPortValue=soMaskValues{TapWeightsPortIdx};

                                addParameter=strcmp(TapWeightsPortValue,'off');
                            end
                        end
                        if addParameter
                            value=determineValue(soMaskValues{maskParamIdx},blockHandle);
                            if~printSetupBlockComment
                                functionBody(end+1)="% Setup "+blockName+" block properties";
                                printSetupBlockComment=true;
                            end
                            functionBody(end+1)=printValue(initName,blockParam,value);
                        end
                        haveParams(end+1)=blockParam;
                    else
                        if~endsWith(lower(blockParam),'port')
                            value=convertToLogic(soMaskValues{maskParamIdx});
                            if~printSetupBlockComment
                                functionBody(end+1)="% Setup "+blockName+" block properties";
                                printSetupBlockComment=true;
                            end
                            functionBody(end+1)=initName+"."+blockParam+" = "+value+";";
                        end
                    end
                end
            end




            if~isSatAmp
                signals=fieldnames(signalStruct);
                for nameIdx=1:length(signals)
                    field=string(signals{nameIdx});
                    signalName=blockName+field;
                    isTaps=strcmp(field,'TapWeights');


                    if~isTaps
                        [isNew,usage,currentValue]=getAMIParameter(tree,blockName,field);
                    else
                        [isNew,usage,currentValue]=getAMITapsParameter(tree,blockName);
                    end


                    if strcmp(usage,"Out")
                        [foundAMI,foundAMIOutOnOutputParamMap]=scanPortsForAMI(soHandle,usage,isTaps,foundAMIOutOnOutputParamMap,field);


                        if~foundAMI.OutOnOut
                            disconnectAMIParam(...
                            signalName,...
                            signalName,...
                            signalName+"="+currentValue+";"...
                            );
                            if~isNew
                                lostAMIParameters(signalName)="";
                            end
                        end
                    end
                    if~inOutOutMap.isKey(char(signalName))
                        addToReturnArgs(end+1)=signalName;
                        blockSignal=blockName+"Signal";
                        blockSignalField=blockName+"Signal."+field;
                        inOutOutMap(char(signalName))={...
                        'DataStoreName',char(blockSignal),...
                        'DataStoreElements',char(blockSignalField)};
                    end
                end

                [~,outputPortNames]=serdes.internal.callbacks.getPortNames(soHandle);
                outputNamesLC=lower(outputPortNames);
                stepCall(end+1)="% Return impulse response and any Out or InOut AMI parameters for "+blockClass+" instance";

                if~hasOutput
                    outputStartIndex=1;
                    stepCall(end+1)="[";
                else
                    outputStartIndex=2;
                    stepCall(end+1)="["+constants.impulseLocalVar+", ";
                end
                if isRx&&isPAM

                    [found,pamReturnVars,pamCode]=findPAM(blockHandle,soHandle,isLegacyPAM);
                end
                for outIndex=outputStartIndex:length(outputNamesLC)
                    if foundAMIInOutOnOutputParamMap.isKey(outIndex)
                        stepCall(end)=stepCall(end)+blockName+foundAMIInOutOnOutputParamMap(outIndex)+", ";
                        connectAMIParam(...
                        string([blockName,foundAMIInOutOnOutputParamMap(outIndex)]),...
                        string([blockName,foundAMIInOutOnOutputParamMap(outIndex)]),...
                        "",...
false...
                        );


                        if isRx&&isPAM&&found.generatedPAMCode&&pamReturnVars.isKey(outIndex)
                            pamCode=strrep(pamCode,pamReturnVars(outIndex),append(blockName,foundAMIInOutOnOutputParamMap(outIndex)));
                            addPAMAssignments=true;
                        end
                    elseif foundAMIOutOnOutputParamMap.isKey(outIndex)
                        stepCall(end)=stepCall(end)+blockName+foundAMIOutOnOutputParamMap(outIndex)+", ";
                        connectAMIParam(...
                        string([blockName,foundAMIOutOnOutputParamMap(outIndex)]),...
                        string([blockName,foundAMIOutOnOutputParamMap(outIndex)]),...
                        "",...
false...
                        );


                        if isRx&&isPAM&&found.generatedPAMCode&&pamReturnVars.isKey(outIndex)
                            pamCode=strrep(pamCode,pamReturnVars(outIndex),append(blockName,foundAMIOutOnOutputParamMap(outIndex)));
                            addPAMAssignments=true;
                        end
                    elseif isRx&&isPAM&&found.generatedPAMCode&&pamReturnVars.isKey(outIndex)&&any(blockIdx==CDRInfo.hopOfLastCDR)
                        stepCall(end)=stepCall(end)+pamReturnVars(outIndex)+", ";
                        addPAMAssignments=true;
                    else
                        stepCall(end)=stepCall(end)+"~, ";
                        if isRx&&isPAM&&found.generatedPAMCode&&pamReturnVars.isKey(outIndex)&&any(blockIdx~=CDRInfo.hopOfLastCDR)
                            h=warndlg(message('serdes:callbacks:ExcludingPAMThresholds',blockName).getString,...
                            message('serdes:callbacks:ExcludingPAMThresholdsTitle').getString);
                            uiwait(h);
                        end
                    end
                end

                stepCall(end)=strip(stepCall(end),'right',' ');
                stepCall(end)=strip(stepCall(end),'right',',');
                stepCall(end)=stepCall(end)+"] = "+initName+"("+constants.impulseLocalVar+");";

                if isRx&&addPAMAssignments
                    stepCall(end+1)=pamCode;
                    addPAMReturns=true;
                    addedPAMAssignments=true;
                end
            elseif isSatAmp
                stepCall(end+1)="% Direct Impulse response processing by "+blockClass+" is not recommended.";
                stepCall(end+1)="% "+constants.impulseLocalVar+" = "+initName+"("+constants.impulseLocalVar+");";
            else
                stepCall(end+1)="% Return impulse response for "+blockClass+" instance";
                stepCall(end+1)=constants.impulseLocalVar+" = "+initName+"("+constants.impulseLocalVar+");";
            end
        elseif isNoSO


            params=fields(parameterStruct);
            if~isempty(params)
                for paramNum=1:length(params)
                    param=params{paramNum};
                    if~strcmp(param,'TapWeights')
                        [~,usage,~]=getAMIParameter(tree,blockName,param);
                    else
                        [~,usage,~]=getAMITapsParameter(tree,blockName);
                    end


                    if strcmp(usage,"In")
                        customAMIParameters(blockParameterName+"."+param)=blockParameterName+"."+param+";";
                    elseif strcmp(usage,"InOut")
                        customAMIParameters(string(blockName)+param)=string(blockName)+param+" = "+blockParameterName+"."+param+";";
                    end
                end
            end


            if~isempty(signalStruct)&&~isempty(fields(signalStruct))&&~isSatAmp
                signals=fieldnames(signalStruct);
                for nameIdx=1:length(signals)
                    field=string(signals{nameIdx});
                    signalName=blockName+field;


                    if~strcmp(field,'TapWeights')
                        [~,usage,currentValue]=getAMIParameter(tree,blockName,field);
                    else
                        [~,usage,currentValue]=getAMITapsParameter(tree,blockName);
                    end


                    if strcmp(usage,"Out")
                        customAMIParameters(signalName)=signalName+"="+currentValue+";";
                    end
                    addToReturnArgs(end+1)=signalName;
                    blockSignal=blockName+"Signal";
                    blockSignalField=blockName+"Signal."+field;
                    inOutOutMap(char(signalName))={'DataStoreName',...
                    char(blockSignal),...
                    'DataStoreElements',...
                    char(blockSignalField)};
                end
            end
        end
    end

    if isRx&&isPAM&&isLegacyPAM&&~addedPAMAssignments




        functionBody(end+1)="% Setup default PAM4 thresholds"+newline+...
        "PAM4_UpperThreshold = 0.333;"+newline+...
        "PAM4_CenterThreshold = 0;"+newline+"PAM4_LowerThreshold = -0.333;";
        addPAMReturns=true;
    elseif isRx&&isPAM&&~isLegacyPAM&&~addedPAMAssignments

        vSwing=1;
        vLevel=vSwing/(modulation-1);
        symbolLevels=-vSwing/2:vLevel:vSwing/2;
        vThresholds=symbolLevels(1:modulation-1)+vLevel/2;
        vThresholds=round(vThresholds,3);
        vThresholdsPadded=[vThresholds,zeros(1,31-(modulation-1))];
        vThresholdsString="[";
        ThresholdsPaddedLength=length(vThresholdsPadded);
        for idx=1:ThresholdsPaddedLength
            vThresholdsString=vThresholdsString+vThresholdsPadded(idx);
            if idx~=ThresholdsPaddedLength
                vThresholdsString=vThresholdsString+"; ";
            else
                vThresholdsString=vThresholdsString+"];";
            end
        end
        functionBody(end+1)="% Setup default PAM thresholds"+newline+...
        "PAM_Thresholds = "+vThresholdsString;
        addPAMReturns=true;
    end

    if isRx&&isPAM&&isLegacyPAM&&addPAMReturns
        addToReturnArgs(end+1)="PAM4_UpperThreshold";
        inOutOutMap('PAM4_UpperThreshold')={'DataStoreName',"PAM4_UpperThreshold"};
        addToReturnArgs(end+1)="PAM4_CenterThreshold";
        inOutOutMap('PAM4_CenterThreshold')={'DataStoreName',"PAM4_CenterThreshold"};
        addToReturnArgs(end+1)="PAM4_LowerThreshold";
        inOutOutMap('PAM4_LowerThreshold')={'DataStoreName',"PAM4_LowerThreshold"};
    elseif isRx&&isPAM&&~isLegacyPAM&&addPAMReturns
        addToReturnArgs(end+1)="PAM_Thresholds";
        inOutOutMap('PAM_Thresholds')={'DataStoreName',"PAM_Thresholds"};
    end



    reservedParameters=tree.getReservedParameters;
    for paraIdx=1:length(reservedParameters)
        reservedParameter=reservedParameters{paraIdx};
        if reservedParameter.IncludeInInit&&~reservedParameter.Hidden
            reservedParameterName=reservedParameter.NodeName;
            if isa(reservedParameter.Usage,"serdes.internal.ibisami.ami.usage.In")
                customAMIParameters(reservedParameterName)=reservedParameterName+";";
                addToFunctionArgs(end+1)=reservedParameterName;
            elseif isa(reservedParameter.Usage,"serdes.internal.ibisami.ami.usage.Out")
                customAMIParameters(reservedParameterName)=reservedParameterName+"="+reservedParameter.CurrentValue+";";
                addToReturnArgs(end+1)=reservedParameterName;
                inOutOutMap(reservedParameterName)={'DataStoreName',reservedParameterName};
            end
        end
    end

    function connectAMIParam(amiParameter,key,code,varargin)

        if nargin==4
            addToCustom=varargin{1};
        else
            addToCustom=true;
        end

        if disconnectedAMIParameters.isKey(amiParameter)
            customAMIParameters.remove(disconnectedAMIParameters(amiParameter));
            disconnectedAMIParameters.remove(amiParameter);
        end

        if addToCustom
            customAMIParameters(key)=code;
        end

        connectedAMIParameters(amiParameter)=key;






    end

    function disconnectAMIParam(amiParameter,key,code)

        if~connectedAMIParameters.isKey(amiParameter)
            if disconnectedAMIParameters.isKey(amiParameter)
                customAMIParameters.remove(disconnectedAMIParameters(amiParameter));
                disconnectedAMIParameters.remove(amiParameter);
            end
            customAMIParameters(key)=code;
            disconnectedAMIParameters(amiParameter)=key;
        end






    end
end


function missingGlobalParameter(blockName,globalName,paramPosition,soMaskObj)
    paramValue=soMaskObj.Parameters(paramPosition).Value;
    if~strcmp(globalName,paramValue)
        promptValue=soMaskObj.Parameters(paramPosition).Prompt;
        dialogMessage=message('serdes:callbacks:GlobalParameterNotUsed',promptValue,blockName,globalName).getString;
        userChoice=questdlg(dialogMessage,'Warning','Overwrite','Ignore','Ignore');
        switch userChoice
        case 'Overwrite'

            soMaskObj.Parameters(paramPosition).Value=globalName;
        end
    end
end

function[foundAMI,mapAMI]=scanPortsForAMI(soHandle,usage,isTaps,mapAMI,field)
    foundAMI.InOnIn=0;
    foundAMI.InOnInConnectIdx=0;
    foundAMI.InOutOnIn=0;
    foundAMI.InOutOnInConnectIdx=0;
    foundAMI.InOutOnOut=0;
    foundAMI.OutOnOut=0;
    currentPortConnectivity=get_param(soHandle,'PortConnectivity');
    sizeOfPorts=size(currentPortConnectivity,1);
    if sizeOfPorts>2
        numberOutputPorts=0;
        type1Count=0;
        for connectIdx=1:sizeOfPorts

            if currentPortConnectivity(connectIdx).Type=='1'
                type1Count=type1Count+1;
            end
            if type1Count==2
                numberOutputPorts=numberOutputPorts+1;
            end

            blockType='';
            if(strcmp(usage,"In")||strcmp(usage,"InOut"))&&type1Count==1
                portAtIdx=currentPortConnectivity(connectIdx).SrcBlock;
                if portAtIdx==-1
                    blockType='';
                else
                    blockType=get_param(portAtIdx,'BlockType');
                end
            elseif(strcmp(usage,"Out")||strcmp(usage,"InOut"))&&type1Count==2
                portAtIdx=currentPortConnectivity(connectIdx).DstBlock;
                blockType=get_param(portAtIdx,'BlockType');
            end

            if~isempty(blockType)

                sizeBlockType=size(blockType,1);

                for connection=1:sizeBlockType
                    if sizeBlockType~=1
                        currentBlockType=blockType{connection};
                        currentPortAtIdx=portAtIdx(connection);
                    else
                        currentBlockType=blockType;
                        currentPortAtIdx=portAtIdx;
                    end
                    if strcmp(currentBlockType,'Constant')
                        blockValue=get_param(currentPortAtIdx,'Value');
                        if(isTaps&&startsWith(extractAfter(blockValue,'.'),field))||strcmp(extractAfter(blockValue,'.'),field)
                            foundAMI.InOnIn=1;
                            foundAMI.InOnInConnectIdx=connectIdx;
                            break
                        end
                    elseif strcmp(currentBlockType,'DataStoreRead')
                        blockValue=get_param(currentPortAtIdx,'DataStoreElements');

                        if(isTaps&&startsWith(extractAfter(blockValue,'.'),field))||strcmp(extractAfter(blockValue,'.'),field)
                            foundAMI.InOutOnIn=1;
                            foundAMI.InOutOnInConnectIdx=connectIdx;
                        end
                    elseif strcmp(currentBlockType,'DataStoreWrite')
                        blockValue=get_param(currentPortAtIdx,'DataStoreElements');

                        if(isTaps&&startsWith(extractAfter(blockValue,'.'),field))||strcmp(extractAfter(blockValue,'.'),field)
                            if strcmp(usage,"InOut")
                                foundAMI.InOutOnOut=1;
                            else
                                foundAMI.OutOnOut=1;
                            end
                            mapAMI(numberOutputPorts)=field;
                            break
                        end
                    end
                end

                if foundAMI.InOnIn||foundAMI.InOutOnOut||foundAMI.OutOnOut
                    break
                end
            end
        end
    end
end

function code=generateFunSignature(addToReturnArgs,addToFunctionArgs,constants,suppressFunSignatureWarning)
    code="% NOTE: The contents of this function will be regenerated when the 'Refresh Init' button"+newline+...
    "%   is pressed, with the exception of the custom user code area.  The custom user code area"+newline+...
    "%   will have a reference added for any unreferenced added AMI parameter."+newline;
    code=code+"function ["+constants.impulseOutVar;
    for retIdx=1:length(addToReturnArgs)
        returnArg=addToReturnArgs{retIdx};
        code=code+", "+returnArg;
    end
    code=code+"] = impulseEqualization(";
    code=code+constants.impulseInVar+", "+constants.rowSizeParamName+", "+constants.aggressorsParamName+", "+...
    constants.modulationParamName+", "+constants.sampleIntervalParamName+", "+constants.symbolTimeParamName;
    amiParameters=true;
    if size(addToFunctionArgs)>0
        code=code+", "+strjoin(addToFunctionArgs,", ");
    else
        amiParameters=false;
    end
    code=code+")";


    if~all(suppressFunSignatureWarning)
        if~amiParameters&&~suppressFunSignatureWarning(3)


            code=code+" %#ok<INUSD>";
        elseif(~amiParameters&&~all(suppressFunSignatureWarning(1:2)))||amiParameters



            code=code+" %#ok<INUSL>";
        end
    end
end

function code=generateCustomUserCode(funHandle,customAMIParameters,lostAMIParameters,direction)

    oldInitCode=funHandle.Script;

    if strcmp(direction,'Tx')
        fileName='txInit.m';
    else
        fileName='rxInit.m';
    end
    if isfile(fileName)
        oldInitCode=fileread(fileName);
    end

    CustomAreaStartText="%% BEGIN: Custom user code area (retained when 'Refresh Init' button is pressed)";
    CustomAreaEndText="% END: Custom user code area (retained when 'Refresh Init' button is pressed)";
    emptyMLFuncCode="function ImpulseOut = impulseEqualization(ImpulseIn, RowSize, Aggressors, Modulation, SampleInterval, SymbolTime)"...
    +newline+"% TEMPLATE: add impulse equalization code here"+newline+"ImpulseOut = ImpulseIn;"+newline;
    addedCodeFlag=" % User added AMI parameter from SerDes IBIS-AMI Manager";
    lostAMIFlag=" % Disconnected default AMI parameter";
    if strcmp(oldInitCode,emptyMLFuncCode)
        code=CustomAreaStartText+newline+newline+CustomAreaEndText;
    else
        startSave=strfind(oldInitCode,CustomAreaStartText);
        endSave=strfind(oldInitCode,CustomAreaEndText);
        if~isempty(startSave)&&~isempty(endSave)&&endSave>startSave
            customCode=oldInitCode(startSave+strlength(CustomAreaStartText)+1:endSave-2);
            customCodeSplit=split(customCode,newline);
            customAMIParametersCode="";
            amiKeys=customAMIParameters.keys;
            amiValues=customAMIParameters.values;
            amiLength=customAMIParameters.length;



            if amiLength~=0
                userPermissionToCommentOutCode=0;
                askedUserPermissionToCommentOutCode=0;
                for keyIdx=1:amiLength

                    searchString=amiKeys{keyIdx}+"([ =;]|$|\n)";
                    searchResults=regexp(customCodeSplit,searchString);
                    if lostAMIParameters.isKey(amiKeys{keyIdx})
                        flag=lostAMIFlag;
                    else
                        flag=addedCodeFlag;
                    end
                    if all(cellfun('isempty',searchResults),1)
                        customAMIParametersCode=addAMIParameterToCode(customAMIParametersCode,customAMIParameters,amiKeys,keyIdx,flag);
                    else
                        addParam=1;
                        for searchIndex=1:size(searchResults,1)
                            if~isempty(searchResults{searchIndex})
                                wholeLine=strtrim(customCodeSplit{searchIndex});
                                isAComment=startsWith(wholeLine,'%');
                                matchesCode=startsWith(wholeLine,amiValues{keyIdx});
                                lineEndsWithAddedCodeFlag=endsWith(wholeLine,flag);



                                if~isAComment&&~matchesCode&&lineEndsWithAddedCodeFlag

                                    if~askedUserPermissionToCommentOutCode
                                        userPermissionToCommentOutCode=commentOutCodeDialog;
                                        askedUserPermissionToCommentOutCode=1;
                                    end
                                    if userPermissionToCommentOutCode
                                        customCodeSplit{searchIndex}=['% ',customCodeSplit{searchIndex}];
                                    end

                                elseif~isAComment&&matchesCode
                                    addParam=0;
                                    break
                                end
                            end
                        end
                        if addParam
                            customAMIParametersCode=addAMIParameterToCode(customAMIParametersCode,customAMIParameters,amiKeys,keyIdx,flag);
                        end
                    end
                end
            end
            if strcmp(customAMIParametersCode,"")
                code=CustomAreaStartText+newline+customCodeToString(customCodeSplit)+newline+CustomAreaEndText;
            elseif strcmp(strtrim(customCode),"")
                code=CustomAreaStartText+newline+customAMIParametersCode+newline+CustomAreaEndText;
            else
                code=CustomAreaStartText+newline+customAMIParametersCode+newline+customCodeToString(customCodeSplit)+newline+CustomAreaEndText;
            end
        else
            if isempty(startSave)
                missingComment=CustomAreaStartText;
            elseif isempty(endSave)
                missingComment=CustomAreaEndText;
            end
            userChoice=questdlg(message('serdes:callbacks:CannotFindCustomUserArea',missingComment).getString,...
            'Error','Regenerate code','Cancel','Cancel');
            switch userChoice
            case 'Regenerate code'
                customAMIParametersCode="";
                amiKeys=customAMIParameters.keys;
                amiLength=customAMIParameters.length;

                if amiLength~=0
                    for keyIdx=1:amiLength
                        if strcmp(customAMIParametersCode,"")
                            customAMIParametersCode=customAMIParameters(amiKeys{keyIdx})+addedCodeFlag;
                        else
                            customAMIParametersCode=customAMIParametersCode+newline+...
                            customAMIParameters(amiKeys{keyIdx})+addedCodeFlag;
                        end
                    end
                end
                code=CustomAreaStartText+newline+customAMIParametersCode+newline+newline+CustomAreaEndText;
            case 'Cancel'
                code="";
            end
        end
    end


    if~strcmp(code,"")
        code=newline+code+newline;
    end
end

function code=generateImpulseOut(constants)

    code="%% Impulse response reformating";
    code(end+1)="% Reshape "+constants.impulseLocalVar+" matrix into a vector using RowSize and Aggressors";
    code(end+1)=constants.impulseOutVar+"(1:RowSize*(Aggressors+1)) = "+constants.impulseLocalVar+";";
    code(end+1)="end";
end


function value=determineValue(value,blockHandle)
    try
        value=eval(value);
    catch ME %#ok<NASGU>
        try
            value=slResolve(value,bdroot(blockHandle));
        catch ME2 %#ok<NASGU>
            value=char("'"+string(value)+"'");
        end
    end
end

function logic=convertToLogic(onOff)
    if strcmp(onOff,'on')
        logic='true';
    else
        logic='false';
    end
end

function code=customCodeToString(customCodeCellArray)
    code="";
    for customCodeIndex=1:size(customCodeCellArray,1)
        code=code+customCodeCellArray(customCodeIndex);
        if customCodeIndex~=size(customCodeCellArray,1)
            code=code+newline;
        end
    end
end

function code=addAMIParameterToCode(customAMIParametersCode,customAMIParameters,amiKeys,keyIdx,userAddedAMIText)
    if strcmp(customAMIParametersCode,"")
        code=customAMIParameters(amiKeys{keyIdx})+userAddedAMIText;
    else
        code=customAMIParametersCode+newline+...
        customAMIParameters(amiKeys{keyIdx})+userAddedAMIText;
    end
end

function proceed=commentOutCodeDialog
    userChoice=questdlg(message('serdes:callbacks:CommentOutCustomCode').getString,'Warning','Yes','No','No');
    switch userChoice
    case 'Yes'
        proceed=true;
    case 'No'
        proceed=false;
    end
end

function portAndOn=findPortsAndOn(soMaskNames,soMaskValues)
    soMaskValuesOn=strcmp(soMaskValues,"on");
    portsInSOMask=endsWith(soMaskNames,"Port");
    portAndOn=soMaskValuesOn&portsInSOMask;
end

function[isNew,usage,currentValue]=getAMIParameter(tree,blockName,param)
    AMIParam=tree.getParameterFromBlock(blockName,param);
    isNew=AMIParam.New;
    usage=AMIParam.Usage.Name;
    currentValue=AMIParam.CurrentValueDisplay;
end

function[isNew,usage,currentValue]=getAMITapsParameter(tree,blockName)
    tapNode=tree.getTapNode(blockName);
    isNew=tapNode.New;
    usage=tree.getTapsUsageOfBlock(blockName);
    currentValue=mat2str(tree.getTapWeightsFromBlock(blockName));
end

function code=printValue(initName,blockParam,value)
    if ischar(value)
        code=initName+"."+blockParam+" = "+value+";";
    else
        code=initName+"."+blockParam+" = "+mat2str(value)+";";
    end
end

function[found,pamReturnVars,pamCode]=findPAM(blockHandle,soHandle,isLegacyPAM)

    constants=serdes.internal.callbacks.InitConstants;

    pamOutName='';
    pamCode="";

    pamReturnVars=containers.Map('KeyType','double','ValueType','char');

    [found,pamHookUps]=findPAMReferences(blockHandle);
    found.generatedPAMCode=true;
    if found.PAM4&&found.PAMN



        if isLegacyPAM

            if all(pamHookUps.isKey(constants.pamNSignals))
                pamHookUps.remove(constants.pamNSignals);
                found.PAMN=false;
            end
        else

            pam4KeysFound=pamHookUps.isKey(constants.pam4Signals);
            if any(pam4KeysFound)
                pamHookUps.remove(constants.pam4Signals(pam4KeysFound));
                found.PAM4=false;
            end
        end
    elseif found.PAM4&&~found.PAMN&&~isLegacyPAM
        h=warndlg(message('serdes:callbacks:MismatchPAMThresholds',...
        get_param(blockHandle,'Name'),'PAM4_UpperThreshold, PAM4_CenterThreshold, PAM4_LowerThreshold','PAM_Thresholds').getString,...
        message('serdes:callbacks:MismatchPAMThresholdsTitle').getString);
        uiwait(h);
        found.generatedPAMCode=false;
        return
    elseif~found.PAM4&&found.PAMN&&isLegacyPAM
        h=warndlg(message('serdes:callbacks:MismatchPAMThresholds',...
        get_param(blockHandle,'Name'),'PAM_Thresholds','PAM4_UpperThreshold, PAM4_CenterThreshold, PAM4_LowerThreshold').getString,...
        message('serdes:callbacks:MismatchPAMThresholdsTitle').getString);
        uiwait(h);
        found.generatedPAMCode=false;
        return
    end

    if found.PAM4&&pamHookUps.length~=3
        h=warndlg(message('serdes:callbacks:PartialPAMThresholds').getString,...
        message('serdes:callbacks:PartialPAMThresholdsTitle').getString);
        found.generatedPAMCode=false;
        uiwait(h);
        return
    end







    keys=pamHookUps.keys;
    for pamIdx=1:pamHookUps.length
        currentBlock=pamHookUps(keys{pamIdx});
        atSO=false;
        blockHops=0;

        foundBusSelector=false;
        foundConstant=false;
        foundGain=false;

        while~atSO
            currentPortConnectivity=get_param(currentBlock,'PortConnectivity');
            sizeCurrentPortConnectivity=size(currentPortConnectivity,1);
            nextBlockHandle='';

            if sizeCurrentPortConnectivity==1
                nextBlockHandle=currentPortConnectivity.SrcBlock;
                nextBlockOutport=currentPortConnectivity.SrcPort+1;
            else
                type1Count=0;
                inputPortCount=0;
                for portIdx=1:sizeCurrentPortConnectivity
                    if currentPortConnectivity(portIdx).Type=='1'&&type1Count<1
                        nextBlockHandle=currentPortConnectivity(portIdx).SrcBlock;
                        nextBlockOutport=currentPortConnectivity(portIdx).SrcPort+1;
                        type1Count=type1Count+1;
                        inputPortCount=inputPortCount+1;
                    elseif currentPortConnectivity(portIdx).Type=='1'&&type1Count==1
                        type1Count=type1Count+1;
                    elseif type1Count==1
                        inputPortCount=inputPortCount+1;
                    end
                    if type1Count==2
                        break
                    end
                end
                if inputPortCount>1
                    h=warndlg(message('serdes:callbacks:UnusualPAMThresholds').getString,...
                    message('serdes:callbacks:UnusualPAMThresholdsTitle').getString);
                    uiwait(h);
                    found.generatedPAMCode=false;
                    return
                end
            end
            if isempty(nextBlockHandle)||nextBlockHandle<0
                h=warndlg(message('serdes:callbacks:NotAllPAMThresholdsConnected').getString,...
                message('serdes:callbacks:NotAllPAMThresholdsConnectedTitle').getString);
                uiwait(h);
                found.generatedPAMCode=false;
                return
            elseif nextBlockHandle~=soHandle

                blockType=get_param(nextBlockHandle,'BlockType');
                if strcmp(blockType,'BusSelector')
                    outputSignal=get_param(nextBlockHandle,'OutputSignals');
                    outputSignal=split(outputSignal,",");
                    if length(outputSignal)>1
                        outputSignal=outputSignal{nextBlockOutport};
                    end
                    foundBusSelector=true;
                elseif strcmp(blockType,'Constant')
                    value=get_param(nextBlockHandle,'Value');
                    foundConstant=true;
                    break
                elseif strcmp(blockType,'Gain')
                    gain=get_param(nextBlockHandle,'Gain');
                    foundGain=true;
                elseif strcmp(blockType,'MATLABSystem')
                    found.generatedPAMCode=false;
                    return
                else
                    h=warndlg(message('serdes:callbacks:UnusualPAMThresholds').getString,...
                    message('serdes:callbacks:UnusualPAMThresholdsTitle').getString);
                    uiwait(h);
                    found.generatedPAMCode=false;
                    return
                end
                currentBlock=nextBlockHandle;
                blockHops=blockHops+1;
            else

                pamOutPosition=nextBlockOutport;
                [~,outputPortNames]=...
                serdes.internal.callbacks.getPortNames(nextBlockHandle);
                pamOutName=outputPortNames{pamOutPosition};

                pamReturnVars(nextBlockOutport)=pamOutName;
                atSO=true;
            end

            if blockHops>3
                h=warndlg(message('serdes:callbacks:UnusualPAMThresholds').getString,...
                message('serdes:callbacks:UnusualPAMThresholdsTitle').getString);
                uiwait(h);
                found.generatedPAMCode=false;
                return
            end
        end

        if blockHops==0&&foundConstant
            pamCode=append(pamCode,keys{pamIdx}+" = "+value+";"+newline);
        elseif blockHops==0
            pamCode=append(pamCode,keys{pamIdx}+" = "+pamOutName+";"+newline);
        elseif blockHops==1&&foundBusSelector
            pamCode=append(pamCode,keys{pamIdx}+" = "+pamOutName+"."+outputSignal+";"+newline);
        elseif blockHops==2&&foundGain&&foundBusSelector
            pamCode=append(pamCode,keys{pamIdx}+" = "+gain+"*"+pamOutName+"."+outputSignal+";"+newline);
        end
    end

    if endsWith(pamCode,newline)
        pamCode=strtrim(pamCode);
    end
end

function[found,pamHookUps]=findPAMReferences(blockHandle)

    constants=serdes.internal.callbacks.InitConstants;

    found.PAM4=false;
    found.PAMN=false;

    pamHookUps=containers.Map;



    foundBlocks=find_system(getfullname(blockHandle),...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'SearchDepth',2,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'BlockType','DataStoreWrite');

    if~isempty(foundBlocks)
        sizeFoundBlocks=size(foundBlocks,1);
        for blockIdx=1:sizeFoundBlocks
            foundSignal=get_param(foundBlocks{blockIdx},'DataStoreName');
            matchPAM4=strcmp(foundSignal,constants.pam4Signals);
            matchPAMN=strcmp(foundSignal,constants.pamNSignals);
            if any(matchPAM4)
                found.PAM4=true;
                pamHookUps(constants.pam4Signals{matchPAM4})=foundBlocks{blockIdx};
            elseif matchPAMN
                found.PAMN=true;
                pamHookUps(constants.pamNSignals{:})=foundBlocks{blockIdx};
            end
        end
    end
end













function[blocksInOrder,blocksInOrderOther]=walkTheLine(startingBlock,endingBlock)

    isEnd=false;
    blockHandle=endingBlock;
    blocksInOrder={};
    blocksInOrderOther={};
    while~isEnd
        [blockHandle,isEnd]=nextBlock(blockHandle,false,startingBlock);
        if~isEnd



            if any([blocksInOrder{:}]==blockHandle)
                blocksInOrder={};
                blocksInOrderOther={};
                parentBlockName=get_param(blockHandle,'Parent');
                h=warndlg(message('serdes:callbacks:LoopDetectedMessage',parentBlockName).getString,...
                message('serdes:callbacks:LoopDetectedTitle').getString);
                uiwait(h);
                return
            else
                blocksInOrder{end+1}=blockHandle;
            end
        end
    end
    blocksInOrder=flip(blocksInOrder);

    numblocksInOrder=length(blocksInOrder);
    if numblocksInOrder>0
        for blocksInOrderIdx=0:numblocksInOrder
            if blocksInOrderIdx==0
                blockHandle=startingBlock;
            else
                blockHandle=blocksInOrder{blocksInOrderIdx};
            end
            [nextBlockHandle,isEnd]=nextBlock(blockHandle,true,endingBlock);
            if~isEnd&&~isempty(nextBlockHandle)
                blocksInOrderOther{end+1}=setdiff(nextBlockHandle,blocksInOrder{blocksInOrderIdx+1});
            elseif isEnd&&~isempty(nextBlockHandle)
                blocksInOrderOther{end+1}=nextBlockHandle;
            elseif isempty(nextBlockHandle)
                blocksInOrderOther{end+1}={};
            end
        end
    end
end










function[nextBlockHandle,isEnd]=nextBlock(blockHandle,forward,endPoint)
    isEnd=false;
    nextBlockHandle=[];
    targetPortConnectivity=findFirstPort(blockHandle,forward);
    if forward
        connections=targetPortConnectivity.DstBlock;
    else
        connections=targetPortConnectivity.SrcBlock;
    end

    numOutportConnections=size(connections,2);
    for connectionIdx=1:numOutportConnections
        currentConnection=connections(connectionIdx);
        blockType=get_param(currentConnection,'BlockType');
        if strcmp(blockType,'MATLABSystem')
            nextBlockHandle=[nextBlockHandle,currentConnection];
        end
        if currentConnection==endPoint
            isEnd=true;
        end
    end

    if~forward&&isempty(nextBlockHandle)&&numOutportConnections==1
        nextBlockHandle=connections;
    end
end






function targetPortConnectivity=findFirstPort(blockHandle,forward)
    blockPortConnectivity=get_param(blockHandle,'PortConnectivity');

    if~isempty(blockPortConnectivity)
        types={blockPortConnectivity.Type};
    else
        return
    end

    type1=find(contains(types,'1'));
    if forward
        if length(type1)>1
            targetPort=type1(2);
        elseif~isempty(blockPortConnectivity(type1(1)).DstBlock)
            targetPort=type1(1);
        end
    else
        targetPort=type1(1);
    end
    targetPortConnectivity=blockPortConnectivity(targetPort);
end

function stepCall=commentStep(stepCall)
    if strcmp(stepCall,"")
        return
    end
    numSteps=length(stepCall);
    for lineIdx=1:numSteps
        line=stepCall(lineIdx);
        if~startsWith(line,'%')
            stepCall(lineIdx)="% "+line;
        end
    end
end

function[isPAM,isLegacyPAM]=checkPAM(tree,modulation)
    isLegacyPAM=false;

    isPAM=modulation>2;


    modulationParameter=tree.getReservedParameter("Modulation");
    if~isempty(modulationParameter)
        if isa(modulationParameter.Format,"serdes.internal.ibisami.ami.format.List")
            isPAM=true;
        end

        isLegacyPAM=true;
        return
    end
    modulationLevelsParameter=tree.getReservedParameter("Modulation_Levels");
    if~isempty(modulationLevelsParameter)&&isa(modulationLevelsParameter.Format,"serdes.internal.ibisami.ami.format.List")
        isPAM=true;
    end
end