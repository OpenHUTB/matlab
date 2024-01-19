function updateBoundSignals(this,addedSignals,removedSignals,updateOnly,inModelLoad,isSF)

    if(nargin<4)
        updateOnly=false;
    end

    if(nargin<5)
        inModelLoad=false;
    end

    if(nargin<6)
        isSF=false;
    end

    webWindow=this.WebWindow;

    if~isempty(addedSignals)

        if updateOnly
            actionFcn='updateSignal';

            if~this.VisualLaunched
                return;
            end
        else
            actionFcn='addSignal';
        end
        addSignalMsg=addSignals(this,addedSignals,actionFcn,inModelLoad,isSF);
        if(this.VisualOpen||webWindow.isvalid)&&~isempty(addSignalMsg)

            message.publish('/logicanalyzer',addSignalMsg);
        end
    end

    if~isempty(removedSignals)
        removeSignalMsg.action=['removeSignal',this.ClientID];
        numSignals=length(removedSignals);
        sigs=struct('id',cell(1,numSignals));
        for i=1:numSignals
            sig=removedSignals(i);
            this.removeSignal(sig.UUID);
            sigs(i).id=sig.UUID;
        end
        removeSignalMsg.params.signals=sigs;
        if(this.VisualOpen||webWindow.isvalid)
            message.publish('/logicanalyzer',removeSignalMsg);
        end
    end


    function sigSerialized=isSigSerialized(sig,serializedUUIDs)
        sigUUID=sig.UUID;
        sigSerialized=any(strcmpi(sigUUID,serializedUUIDs));
        function[isBoolean,isFloatingPoint,isComplex,wordLength,isEnumeration,enumInfo,isMultirate,busElementNames]=getDefaultSignalValues()
            isBoolean=false;
            isFloatingPoint=false;
            isComplex=0;
            wordLength=0;
            isEnumeration=false;
            enumInfo={};
            isMultirate=false;
            busElementNames={};


            function addSignalMsg=addSignals(this,addedSignals,actionFcn,inModelLoad,isSF)
                clientId=this.ClientID;
                hBlock=str2double(clientId);
                hModel=bdroot(hBlock);
                modelName=get_param(hModel,'Name');

                skipWorkAtCompile=~this.VisualLaunched&&strcmpi(get_param(modelName,'SimulationStatus'),'initializing');
                isMdlRefNormalModeCopy=uiservices.onOffToLogical(...
                get_param(hModel,'ModelReferenceMultiInstanceNormalModeCopy'));

                if isMdlRefNormalModeCopy

                    addSignalMsg=[];
                    return;
                end
                addSignalMsg.action=[actionFcn,clientId];
                numSignals=length(addedSignals);
                initStructValues=cell(1,numSignals);
                sigs=struct('id',initStructValues,'name',initStructValues,...
                'isBoolean',initStructValues);

                hasTrace=false;
                signalOrdering='';
                if inModelLoad
                    hasTrace=~isempty(get_param(hModel,'LogicAnalyzerGraphicalSettings'));
                    signalOrdering=this.RawSignalOrdering;
                end
                serializedSigs=this.SerializedInstrumentedSignals;
                serializedUUIDs={};
                if~isempty(serializedSigs)
                    serializedUUIDs=cell(1,serializedSigs.Count);
                    for idx=1:serializedSigs.Count
                        serializedUUIDs{idx}=serializedSigs.getUUID(idx);
                    end
                end
                if~isSF&&numSignals>1
                    portHs=arrayfun(@(x)x.PortHandle,addedSignals);
                    if all(portHs~=-1)
                        sigPos=cell2mat(get(portHs,'position'));

                        [~,sigIndexes]=sortrows(sigPos);
                    else
                        sigIndexes=1:numSignals;
                    end
                else
                    sigIndexes=1:numSignals;
                end
                isMdlRef=~strcmpi(get_param(hModel,'ModelReferenceTargetType'),'none');
                mdlRefBlockPath=[];
                if isMdlRef
                    mdlRefBlockPath=get_param(hModel,'ModelReferenceNormalModeVisibilityBlockPath');
                end

                if isempty(mdlRefBlockPath)
                    mdlRefBlockPath=Simulink.BlockPath();
                end

                displayBusElementNames=false;
                laGraphicalSettings=get_param(modelName,'LogicAnalyzerGraphicalSettings');
                if~isempty(laGraphicalSettings)
                    if~isempty(regexp(laGraphicalSettings,'displayBusElementNames','once'))
                        displayBusElementNames=true;
                    end
                end
                updateSFsigsOnce=true;
                for i=1:numSignals
                    sig=addedSignals(sigIndexes(i));

                    isSerialized=false;
                    if~isempty(serializedUUIDs)
                        isSerialized=isSigSerialized(sig,serializedUUIDs);
                    end
                    blockPath=sig.BlockPath_;
                    if isempty(blockPath)
                        continue;
                    end
                    if~iscell(blockPath)
                        blockPath={blockPath};
                    end
                    isUpdate=strcmp(actionFcn,'updateSignal');
                    if isUpdate
                        isSF=sig.isSF;
                        if isSF
                            if updateSFsigsOnce
                                addedSignals=UpdateSFsigsInAddedSignals(modelName,addedSignals);
                                updateSFsigsOnce=false;
                            end
                            sig=addedSignals(i).SFSig;
                        end
                    end

                    if isSF
                        [sfsig,blkh,isInvalid]=getvalidSFSig(sig);
                        if isInvalid
                            continue;
                        end
                        [name,shortName]=getFullyQualifiedSFSignalName(sfsig,sig);
                        signalWidth=1;
                        isCommented=strcmp(get_param(blkh,'Commented'),'on');
                        if skipWorkAtCompile
                            [isBoolean,isFloatingPoint,isComplex,wordLength,isEnumeration,enumInfo,isMultirate,busElementNames]=getDefaultSignalValues();
                        else
                            [isBoolean,isFloatingPoint,isComplex,wordLength,isEnumeration,enumInfo,isMultirate,busElementNames]=computeSFDataType(sfsig,sig);
                            if isUpdate&&isEnumeration&&~isCommented
                                enumInfo{1}=this.GetEnumInfo(sig.CachedBlockHandle_,sig.SID_,str2double(sig.DomainParams_.SSID),sig.DomainParams_.Activity);
                            end
                        end
                        signalDims=[1,1];
                        portHandle=-1;
                        busType='';
                        outputPortIdx=sig.OutputPortIndex_;
                    else
                        portHandle=sig.PortHandle;
                        [name,shortName]=getFullyQualifiedSignalName(sig);

                        if skipWorkAtCompile
                            [isBoolean,isFloatingPoint,isComplex,wordLength,isEnumeration,enumInfo,isMultirate,busElementNames]=getDefaultSignalValues();
                            signalWidth=1;
                            signalDims=[1,1];
                        else
                            if~any(strcmpi(get_param(modelName,'StrictBusMsg'),{'None','warning'}))
                                busType=get_param(portHandle,'CompiledBusType');
                            end
                            signalWidth=computePortWidth(portHandle,modelName,busType);
                            [isBoolean,isFloatingPoint,isComplex,wordLength,isEnumeration,enumInfo,isMultirate,busElementNames]=computeDataType(sig,modelName,busType,displayBusElementNames);
                            if~iscell(busElementNames)
                                busElementNames=cellstr(busElementNames);
                            end
                            signalDims=get_param(portHandle,'CompiledPortDimensions');
                        end
                        blkh=get_param(portHandle,'ParentHandle');
                        isCommented=strcmp(get_param(blkh,'Commented'),'on');
                        outputPortIdx=sig.OutputPortIndex;
                    end

                    if isempty(name)
                        continue;
                    end
                    name=strrep(name,sprintf('\n'),' ');
                    shortName=strrep(shortName,sprintf('\n'),' ');

                    uuid=sig.UUID;
                    this.addSignal(uuid,blockPath,mdlRefBlockPath.convertToCell(),name,shortName,outputPortIdx,portHandle,isBoolean,isFloatingPoint,isComplex,signalWidth,signalDims,wordLength,isMultirate,blkh,jsonencode(enumInfo),double(isEnumeration),double(isCommented),isSerialized,hasTrace,busElementNames,isSF);

                    sigs(i).id=uuid;
                    sigs(i).name=name;
                    sigs(i).shortName=shortName;
                    sigs(i).isBoolean=double(isBoolean);
                    sigs(i).isFloatingPoint=double(isFloatingPoint);
                    sigs(i).isComplex=double(isComplex);
                    sigs(i).isEnumeration=double(isEnumeration);
                    sigs(i).enumerations=enumInfo;
                    sigs(i).signalWidth=signalWidth;
                    sigs(i).signalDims=signalDims;
                    sigs(i).wordLength=wordLength;
                    sigs(i).isMultirate=double(isMultirate);
                    sigs(i).isCommented=double(isCommented);
                    sigs(i).busElementNames=busElementNames;
                    sigs(i).isSerialized=isSerialized;
                    sigs(i).isSF=isSF;
                end

                sigs=sigs(~cellfun(@isempty,{sigs.id}));

                if inModelLoad&&~isempty(signalOrdering)

                    this.RawSignalOrdering=signalOrdering;
                end
                addSignalMsg.params.signals=sigs;


                function iSig=getInstrumentedSignal(this,uuid)
                    [~,iSigs]=Simulink.scopes.LAScope.getInstrumentedSignals(this.ModelName);
                    iSig=iSigs(cell2mat(arrayfun(@(x)strcmp(x.UUID,uuid),iSigs,'UniformOutput',false)));


                    function sigWidth=computePortWidth(portHandle,modelName,busType)

                        portWidth=get_param(portHandle,'CompiledPortWidth');

                        if strcmpi(busType,'NON_VIRTUAL_BUS')&&strcmpi(get_param(modelName,'SimulationStatus'),'initializing')
                            busDataTypeName=get_param(portHandle,'CompiledPortDataType');
                            sigWidth=computeNonVirtualBusWidth(modelName,busDataTypeName,portWidth);
                        elseif strcmpi(busType,'VIRTUAL_BUS')&&strcmpi(get_param(modelName,'SimulationStatus'),'initializing')
                            sigWidth=computeVirtualBusWidth(modelName,portHandle);
                        else
                            sigWidth=portWidth;

                        end


                        function busWidth=computeVirtualBusWidth(modelName,portHandle)
                            busStruct=get_param(portHandle,'CompiledBusStruct');
                            busWidth=0;
                            if isfield(busStruct,'signals')
                                for idx=1:length(busStruct.signals)
                                    leaf=busStruct.signals(idx);
                                    isLeafABus=~isempty(leaf.signals);
                                    leafObj=get_param(leaf.src,'Object');
                                    leafOutport=leafObj.PortHandles.Outport(leaf.srcPort+1);
                                    if~isLeafABus
                                        busWidth=busWidth+get_param(leafOutport,'CompiledPortWidth');
                                    elseif isLeafABus&&~isempty(leaf.busObjectName)

                                        busWidth=busWidth+computeNonVirtualBusWidth(modelName,leaf.busObjectName,1);
                                    else

                                        busWidth=busWidth+computeVirtualBusWidth(modelName,leafOutport);
                                    end
                                end
                            end

                            function[isBoolean,isFloatingPoint,isComplex,wordLength,isEnumeration,enumInfo,isMultirate,busElementNames]=computeDataType(signal,modelName,busType,displayBusElementNames)

                                portHandle=signal.PortHandle;
                                portWidth=get_param(portHandle,'CompiledPortWidth');
                                isVirtualBus=strcmpi(busType,'VIRTUAL_BUS');
                                isNonVirtualBus=strcmpi(busType,'NON_VIRTUAL_BUS');
                                isBoolean=zeros(1,0);
                                isFloatingPoint=zeros(1,0);
                                isComplex=zeros(1,0);
                                wordLength=zeros(1,0);
                                isEnumeration=zeros(1,0);
                                enumInfo=cell(1,0);
                                sampleTimes=[];
                                isMultirate=false;
                                busElementNames=cell(1,0);
                                simStatus=get_param(modelName,'SimulationStatus');

                                if isVirtualBus&&strcmpi(simStatus,'initializing')

                                    compBusStruct=get_param(portHandle,'CompiledBusStruct');
                                    dataTypes=cell(1,0);

                                    if isempty(compBusStruct)
                                        compPortComplex=get_param(portHandle,'CompiledPortComplexSignal');
                                        dataTypes{1}=get_param(portHandle,'CompiledPortDataType');
                                        if compPortComplex==-1||compPortComplex==0
                                            isComplex=0;
                                        else
                                            isComplex=[compPortComplex,2];
                                            dataTypes{2}=dataTypes{1};
                                        end
                                        if(~isequal(portWidth,0))
                                            isComplex=repmat(isComplex,1,portWidth);
                                            dataTypes=repmat(dataTypes,1,portWidth);
                                        end
                                    else

                                        [dataTypes,isComplex,isMultirate,sampleTimes,busElementNames]=getLeafElementInfoForBus(compBusStruct,dataTypes,isComplex,isMultirate,sampleTimes,busElementNames,displayBusElementNames);
                                    end
                                    for idx=1:length(dataTypes)
                                        isBoolean(idx)=strcmpi('boolean',dataTypes{idx});
                                        isFloatingPoint(idx)=isempty(dataTypes{idx})||any(strcmpi({'double','single'},dataTypes{idx}));
                                        isEnumeration(idx)=false;
                                        enumInfo{idx}=[];
                                        if isBoolean(idx)||isFloatingPoint(idx)
                                            wordLength(idx)=0;
                                        else
                                            [wordLength(idx),baseType]=getWordLength(dataTypes,idx,modelName);
                                            if wordLength(idx)==0
                                                isBoolean(idx)=strcmpi('boolean',baseType);
                                                isFloatingPoint(idx)=strcmpi('single',baseType)||...
                                                strcmpi('double',baseType);
                                                if~(isBoolean(idx)||isFloatingPoint(idx))
                                                    [isEnumeration(idx),enumInfo{idx}]=getEnumerationInfo(dataTypes{idx});
                                                end
                                            end
                                        end
                                    end
                                elseif isNonVirtualBus&&strcmpi(simStatus,'initializing')
                                    busDataTypeName=get_param(portHandle,'CompiledPortDataType');
                                    mDFSElements=slInternal('busDiagnostics','getDFSElementsInBus',modelName,busDataTypeName,portWidth);
                                    mNumDFSElements=length(mDFSElements);
                                    if displayBusElementNames
                                        compiledBusStruct=get_param(portHandle,'CompiledBusStruct');
                                        if compiledBusStruct.dfsDataTypeElemIdx~=0
                                            busElementNames=getBusElementInfo(compiledBusStruct,busElementNames);
                                        else
                                            busElementNames=processBusElemNamesForBusObjects(compiledBusStruct,mDFSElements,busElementNames);
                                        end
                                    end

                                    isMultirate=false;
                                    for idx=1:mNumDFSElements

                                        if isstruct(mDFSElements)&&mDFSElements(idx).flatIndex>-1
                                            dataType=mDFSElements(idx).dataType;
                                            sigType=mDFSElements(idx).signalType;
                                            elementWidth=mDFSElements(idx).width;
                                            for indx=1:elementWidth
                                                isBoolean(end+1)=strcmpi('boolean',dataType);
                                                isFloatingPoint(end+1)=strcmpi('single',dataType)||...
                                                strcmpi('double',dataType);
                                                isComplex(end+1)=~strcmpi(sigType,'real');
                                                isEnumeration(end+1)=false;
                                                enumInfo{end+1}=[];
                                                if isempty(indexIntoCellOrVector(dataType,indx))||isBoolean(end)||isFloatingPoint(end)
                                                    wordLength(end+1)=0;
                                                else
                                                    [wordLength(end+1),baseType]=getWordLength(dataType,indx,modelName);
                                                    if wordLength(end)==0

                                                        isBoolean(end)=strcmpi('boolean',baseType);
                                                        isFloatingPoint(end)=strcmpi('single',baseType)||...
                                                        strcmpi('double',baseType);
                                                        if~(isBoolean(end)||isFloatingPoint(end))
                                                            [isEnumeration(end),enumInfo{end}]=getEnumerationInfo(dataType);%#ok<*AGROW>
                                                        end
                                                    end
                                                end
                                                if~strcmpi(sigType,'real')
                                                    isBoolean(end+1)=isBoolean(end);
                                                    isFloatingPoint(end+1)=isFloatingPoint(end);
                                                    isComplex(end+1)=2;
                                                    wordLength(end+1)=wordLength(end);
                                                    isEnumeration(end+1)=isEnumeration(end);
                                                    enumInfo{end+1}=enumInfo{end};
                                                end
                                            end
                                        end
                                    end
                                else

                                    compPortComplex=get_param(portHandle,'CompiledPortComplexSignal');
                                    dataType=get_param(portHandle,'CompiledPortDataType');
                                    numSigs=portWidth;
                                    if compPortComplex==-1||compPortComplex==0
                                        isComplex=0;
                                    else
                                        numSigs=portWidth*(2*compPortComplex);
                                        isComplex=[compPortComplex,2];
                                    end
                                    isBoolean=strcmpi('boolean',dataType);
                                    isFloatingPoint=isempty(dataType)||any(strcmpi({'double','single'},dataType));
                                    isBus=isVirtualBus||isNonVirtualBus;
                                    isEnumeration=false;
                                    enumInfo{1}=[];
                                    if~(isempty(dataType)||isBoolean||isFloatingPoint||isBus)
                                        [wordLength,baseType]=getWordLength(dataType,1,modelName);
                                        if(wordLength==0)
                                            isBoolean=strcmpi('boolean',baseType);
                                            isFloatingPoint=isempty(baseType)||any(strcmpi({'double','single'},baseType));
                                            if~(isFloatingPoint||isBoolean)
                                                [isEnumeration,enumInfo{1}]=getEnumerationInfo(dataType);
                                            end
                                        end
                                    end
                                    if portWidth~=0
                                        isComplex=repmat(isComplex,1,portWidth);
                                        if isBoolean
                                            isBoolean=true(1,numSigs);
                                        else
                                            isBoolean=false(1,numSigs);
                                        end
                                        if isEnumeration
                                            isEnumeration=true(1,numSigs);
                                        else
                                            isEnumeration=false(1,numSigs);
                                        end
                                        if isFloatingPoint
                                            isFloatingPoint=true(1,numSigs);
                                        else
                                            isFloatingPoint=false(1,numSigs);
                                        end
                                        if~isempty(enumInfo{1})
                                            enumInfo=repmat(enumInfo,1,numSigs);
                                        end
                                        wordLength=repmat(wordLength,1,numSigs);
                                    end

                                    if(~isMultirate)
                                        [isMultirate,sampleTimes]=getIsMultirate(sampleTimes,get_param(portHandle,'CompiledPortSampleTime'));
                                    end
                                end

                                isBoolean=logical(isBoolean);
                                isFloatingPoint=logical(isFloatingPoint);
                                isEnumeration=logical(isEnumeration);

                                function[isMultirate,sampleTimes]=getIsMultirate(sampleTimes,value)

                                    if isempty(value)
                                        isMultirate=false;
                                        sampleTimes=Inf;
                                        return;
                                    end

                                    if iscell(value)
                                        for indx=1:length(value)
                                            if isequal(sampleTimes,value{indx}(1))||isempty(sampleTimes)
                                                sampleTimes=value{indx}(1);
                                                isMultirate=false;
                                            else
                                                isMultirate=true;
                                                break;
                                            end
                                        end
                                    else
                                        if isequal(sampleTimes,value(1))||isempty(sampleTimes)
                                            sampleTimes=value(1);
                                            isMultirate=false;
                                        else
                                            isMultirate=true;
                                        end
                                    end

                                    

function[wordLength,baseType]=getWordLength(dataType,indx,modelName)

                                        dataType=indexIntoCellOrVector(dataType,indx);
                                        persistent wordLengthMap baseTypeMap;
                                        if isempty(wordLengthMap)
                                            wordLengthMap=containers.Map;
                                            baseTypeMap=containers.Map;
                                        end
                                        if isKey(wordLengthMap,dataType)
                                            wordLength=wordLengthMap(dataType);
                                            baseType=baseTypeMap(dataType);
                                            return;
                                        end

                                        baseType=dataType;

                                        try
                                            temp=numerictype(dataType);
                                        catch ME %#ok
                                            [temp,exists]=slResolve(dataType,modelName);
                                            if~exists
                                                wordLength=0;
                                                wordLengthMap(dataType)=wordLength;
                                                baseTypeMap(dataType)=baseType;
                                                return;
                                            end
                                        end
                                        if isprop(temp,'WordLength')
                                            if isscaleddouble(temp)
                                                wordLength=0;
                                                baseType='double';
                                            else
                                                wordLength=temp.WordLength;
                                            end
                                        else
                                            if isprop(temp,'BaseType')
                                                baseType=temp.BaseType;
                                                if any(strcmp(baseType,{'double','single'}))
                                                    wordLength=0;
                                                else
                                                    [wordLength,baseType]=getWordLength(baseType,1,modelName);
                                                end
                                            else
                                                wordLength=0;
                                            end
                                        end
                                        wordLengthMap(dataType)=wordLength;
                                        baseTypeMap(dataType)=baseType;


                                        function element=indexIntoCellOrVector(element,index)
                                            if iscell(element)
                                                element=element{index};
                                            end


                                            function[isEnum,enumInfo]=getEnumerationInfo(dataType)

                                                yTickInfo=uiservices.getYTickInfoForEnum(dataType);
                                                if isempty(yTickInfo)
                                                    isEnum=false;
                                                    enumInfo=struct;
                                                else
                                                    isEnum=true;
                                                    enumInfo.values=yTickInfo.Tick;
                                                    enumInfo.strings=yTickInfo.Label;
                                                end

                                                function busWidth=computeNonVirtualBusWidth(modelName,busDataTypeName,portWidth)

                                                    mDFSElements=slInternal('busDiagnostics','getDFSElementsInBus',modelName,busDataTypeName,portWidth);
                                                    busWidth=0;
                                                    mNumDFSElements=length(mDFSElements);
                                                    for idx=1:mNumDFSElements

                                                        if mDFSElements(idx).flatIndex>-1
                                                            busWidth=busWidth+mDFSElements(idx).width;
                                                        end
                                                    end

                                                    function[datatypes,isComplex,isMultirate,sampleTimes,busElementNames]=getLeafElementInfoForBus(compBusStruct,datatypes,isComplex,isMultirate,sampleTimes,busElementNames,displayBusElementNames)

                                                        if(isempty(compBusStruct.signals))
                                                            compiledSigObj=get_param(compBusStruct.src,'Object');
                                                            srcPort=compBusStruct.srcPort+1;
                                                            if(isempty(compiledSigObj.CompiledPortDataTypes))
                                                                return;
                                                            end
                                                            compiledPortDatatype=compiledSigObj.CompiledPortDataTypes.Outport(srcPort);
                                                            compiledPortComplexity=compiledSigObj.CompiledPortComplexSignals.Outport(srcPort);
                                                            if(~isMultirate)
                                                                portHandle=compiledSigObj.PortHandles.Outport(srcPort);
                                                                sampleTime=get_param(portHandle,'CompiledSampleTime');
                                                                [isMultirate,sampleTimes]=getIsMultirate(sampleTimes,sampleTime);
                                                            end
                                                            compPortWidth=compiledSigObj.CompiledPortWidths.Outport(srcPort);
                                                            for pIndx=1:compPortWidth
                                                                datatypes=[datatypes,compiledPortDatatype];
                                                                isComplex=[isComplex,compiledPortComplexity];
                                                                if(compiledPortComplexity)
                                                                    datatypes=[datatypes,compiledPortDatatype];
                                                                    isComplex=[isComplex,2];
                                                                end
                                                                if displayBusElementNames
                                                                    iterRealImag=1;
                                                                    if compiledPortComplexity
                                                                        iterRealImag=2;
                                                                    end
                                                                    for indx=1:iterRealImag
                                                                        compBusElementNames=getCompBusElementName(compBusStruct);
                                                                        if compPortWidth>1
                                                                            if compiledPortComplexity==1&&indx==2
                                                                                compBusElementNames=[compBusElementNames,'(',num2str(pIndx),'i)'];
                                                                            else
                                                                                compBusElementNames=[compBusElementNames,'(',num2str(pIndx),')'];
                                                                            end
                                                                        end
                                                                        if isempty(busElementNames)
                                                                            busElementNames=compBusElementNames;
                                                                        else
                                                                            busElementNames=convertToChar(busElementNames,compBusElementNames);
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        else
                                                            for indx=1:length(compBusStruct.signals)
                                                                [datatypes,isComplex,isMultirate,sampleTimes,busElementNames]=getLeafElementInfoForBus(compBusStruct.signals(indx),datatypes,isComplex,isMultirate,sampleTimes,busElementNames,displayBusElementNames);
                                                            end
                                                        end


                                                        function busElementNames=getBusElementInfo(compBusStruct,busElementNames)
                                                            if(isempty(compBusStruct.signals))
                                                                compiledSigObj=get_param(compBusStruct.src,'Object');
                                                                srcPort=compBusStruct.srcPort+1;
                                                                compPortWidth=compiledSigObj.CompiledPortWidths.Outport(srcPort);
                                                                compiledPortComplexity=compiledSigObj.CompiledPortComplexSignals.Outport(srcPort);
                                                                if exist('isComplex','var')
                                                                    isComplex=[isComplex,compiledPortComplexity];
                                                                else
                                                                    isComplex=compiledPortComplexity;
                                                                end
                                                                if compiledPortComplexity
                                                                    isComplex=[isComplex,2];
                                                                end
                                                                for pIndx=1:compPortWidth
                                                                    iterRealImag=1;
                                                                    if compiledPortComplexity
                                                                        iterRealImag=2;
                                                                    end
                                                                    for indx=1:iterRealImag
                                                                        compBusElementNames=getCompBusElementName(compBusStruct);
                                                                        if compPortWidth>1
                                                                            if compiledPortComplexity==1&&indx==2
                                                                                compBusElementNames=[compBusElementNames,'(',num2str(pIndx),'i)'];
                                                                            else
                                                                                compBusElementNames=[compBusElementNames,'(',num2str(pIndx),')'];
                                                                            end
                                                                        end
                                                                        if isempty(busElementNames)
                                                                            busElementNames=compBusElementNames;
                                                                        else
                                                                            busElementNames=convertToChar(busElementNames,compBusElementNames);
                                                                        end
                                                                    end
                                                                end
                                                            else
                                                                for indx=1:length(compBusStruct.signals)
                                                                    busElementNames=getBusElementInfo(compBusStruct.signals(indx),busElementNames);
                                                                end
                                                            end


                                                            function busElementNames=processBusElemNamesForBusObjects(compBusStruct,mDFSElements,busElementNames)
                                                                mNumDFSElements=length(mDFSElements);
                                                                for idx=1:mNumDFSElements
                                                                    if isstruct(mDFSElements)&&mDFSElements(idx).flatIndex>-1

                                                                        elementWidth=mDFSElements(idx).width;
                                                                        for pIndx=1:elementWidth
                                                                            isComplex=~strcmpi(mDFSElements(idx).signalType,'real');
                                                                            iterRealImag=1;
                                                                            if isComplex
                                                                                iterRealImag=2;
                                                                            end
                                                                            for indx=1:iterRealImag
                                                                                compBusElementNamesFullPath=mDFSElements(idx).fullPath;
                                                                                ocLocations=find(compBusElementNamesFullPath=='(');
                                                                                ccLocations=find(compBusElementNamesFullPath==')');
                                                                                if~isempty(ocLocations)&&~isempty(ccLocations)
                                                                                    busIndexCell=compBusElementNamesFullPath(ocLocations(1)+1:ccLocations(1)-1);
                                                                                end
                                                                                if exist('busIndexCell','var')&&~isempty(busIndexCell)
                                                                                    busIndex=str2double(busIndexCell);
                                                                                    compBusElementNames=['(',num2str(busIndex+1),').',mDFSElements(idx).eName];
                                                                                else
                                                                                    compBusElementNames=mDFSElements(idx).eName;
                                                                                end
                                                                                if elementWidth>1
                                                                                    if isComplex==1&&indx==2
                                                                                        compBusElementNames=[compBusElementNames,'(',num2str(pIndx),'i)'];
                                                                                    else
                                                                                        compBusElementNames=[compBusElementNames,'(',num2str(pIndx),')'];
                                                                                    end
                                                                                end
                                                                                if isempty(busElementNames)
                                                                                    busElementNames=compBusElementNames;
                                                                                else
                                                                                    busElementNames=convertToChar(busElementNames,compBusElementNames);
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end


                                                                function busElementNames=convertToChar(busElementNames,compBusElementNames)
                                                                    busElementNames=char(busElementNames);
                                                                    compBusElementNames=char(compBusElementNames);
                                                                    busElementNames=char(busElementNames,compBusElementNames);

                                                                    

function compBusElementName=getCompBusElementName(compBusStruct)
                                                                        compBusElementName=compBusStruct.name;

                                                                        

function[sigName,shortName]=getFullyQualifiedSignalName(sig)
                                                                            blockPathStr=sig.BlockPath_;
                                                                            delimiters=strfind(blockPathStr,'/');
                                                                            firstDelimiter=delimiters(1);
                                                                            blockPathStr=blockPathStr(firstDelimiter+1:length(blockPathStr));

                                                                            portH=sig.PortHandle;
                                                                            lineName='';
                                                                            if~isequal(portH,-1)
                                                                                lineName=get_param(portH,'Name');
                                                                            end
                                                                            if isempty(lineName)
                                                                                sigName=blockPathStr;

                                                                                ports=get_param(get_param(portH,'ParentHandle'),'PortHandles');
                                                                                if length(ports.Outport)>1
                                                                                    sigName=sprintf('%s:%d',sigName,sig.OutputPortIndex);
                                                                                end
                                                                                shortDelim=strfind(regexprep(sigName,'//','**'),'/');
                                                                                if isempty(shortDelim)
                                                                                    shortName=sigName;
                                                                                else
                                                                                    shortName=sigName(shortDelim(end)+1:end);
                                                                                end
                                                                                shortName=regexprep(shortName,'//','/');
                                                                                sigName=regexprep(sigName,'//','/');
                                                                            else
                                                                                delimiters=strfind(regexprep(blockPathStr,'//','**'),'/');
                                                                                if isempty(delimiters)
                                                                                    sigName=lineName;
                                                                                else
                                                                                    finalDelimiter=delimiters(length(delimiters));
                                                                                    blockPathStr=blockPathStr(1:finalDelimiter);
                                                                                    blockPathStr=regexprep(blockPathStr,'//','/');
                                                                                    sigName=[blockPathStr,lineName];
                                                                                end
                                                                                shortName=lineName;
                                                                            end
                                                                            

function[sigName,shortName]=getFullyQualifiedSFSignalName(sfSig,sig)
                                                                                shortName=[];
                                                                                sigName=[];
                                                                                if~isempty(sfSig)
                                                                                    sigActName=sig.DomainParams_.Activity;
                                                                                    if(strcmpi(sigActName,'Self'))
                                                                                        sigActName='IsActive';
                                                                                    elseif(strcmpi(sigActName,'Child'))
                                                                                        sigActName='ActiveChild';
                                                                                    elseif(strcmpi(sigActName,'Leaf'))
                                                                                        sigActName='ActiveLeaf';
                                                                                    end
                                                                                    shortName=[sfSig.Name,':',sigActName];
                                                                                    sigName=[sfSig.Path,'.',shortName];
                                                                                end
                                                                                

function[sfSig,blkh,isInvalid]=getvalidSFSig(signal)
                                                                                    try
                                                                                        blkPath=signal.BlockPath_;
                                                                                        sfSubSys=get_param(blkPath,'Object');
                                                                                        blkh=get_param(blkPath,'handle');

                                                                                        sfChartObj=find(sfSubSys,...
                                                                                        '-depth',1,...
                                                                                        'Path',blkPath,...
                                                                                        'Name',signal.SignalName_,...
                                                                                        '-isa','Stateflow.Chart',...
                                                                                        '-or','-isa','Stateflow.EMChart',...
                                                                                        '-or','-isa','Stateflow.TruthTableChart',...
                                                                                        '-or','-isa','Stateflow.StateTransitionTableChart',...
                                                                                        '-or','-isa','Stateflow.LinkChart');
                                                                                        if length(sfChartObj)~=1
                                                                                            sfChart=sfSubSys.find('-isa','Stateflow.Chart','Path',blkPath);
                                                                                        elseif~isempty(sfChartObj)
                                                                                            chartId1=sfprivate('block2chart',blkh);
                                                                                            sfChart=idToHandle(sfroot,chartId1);
                                                                                        end
                                                                                        if~strcmp(signal.DomainType_,'sf_chart')
                                                                                            sfSig=sfChart.find('SSIdNumber',str2double(signal.DomainParams_.SSID));
                                                                                        else

                                                                                            sfSig=sfChart.find('Name',signal.SubPath_);
                                                                                            if length(sfSig)~=1


                                                                                                sfSig=sfChart.find('Name',signal.SubPath_,'Path',sfChart.Path);
                                                                                            end
                                                                                        end
                                                                                        isInvalid=isempty(sfSig)||(strcmp(signal.DomainParams_.Activity,'Child')&&(~strcmp(sfSig.Decomposition,'EXCLUSIVE_OR')||...
                                                                                        isempty(sf('SubstatesOf',sfSig.id))));
                                                                                    catch me
                                                                                        blkh='';
                                                                                        sfSig='';
                                                                                        isInvalid=true;
                                                                                    end
     

                                                                               function signals=UpdateSFsigsInAddedSignals(model,signals)
                                                                                        instr_signals=get_param(model,'InstrumentedSignals');

                                                                                        [signals.SFSig]=deal([]);
                                                                                        sigUUIDS={signals.UUID};
                                                                                        if~isempty(instr_signals)
                                                                                            num_signals=instr_signals.Count;
                                                                                            for kndx=1:num_signals
                                                                                                k_signal=instr_signals.get(num_signals-kndx+1,true);
                                                                                                idx=find(strcmp(sigUUIDS,k_signal.UUID));
                                                                                                if~isempty(idx)&&signals(idx).isSF
                                                                                                    signals(idx).SFSig=k_signal;
                                                                                                end
                                                                                            end
                                                                                        end

                                         
                                               function[isBoolean,isFloatingPoint,isComplex,wordLength,isEnumeration,enumInfo,isMultirate,busElementNames]=computeSFDataType(sfSig,signal)
                                                                                            isFloatingPoint=false;
                                                                                            isBoolean=false;
                                                                                            isComplex=0;
                                                                                            wordLength=0;
                                                                                            isEnumeration=false;
                                                                                            enumInfo=cell(1,0);
                                                                                            isMultirate=false;
                                                                                            busElementNames=cell(1,0);
                                                                                            if strcmp(signal.DomainType_,'sf_data')
                                                                                                dataType=sfSig.CompiledType;
                                                                                                isFloatingPoint=isempty(dataType)||any(strcmpi({'double','single'},dataType));
                                                                                                isFloatingPoint=logical(isFloatingPoint);
                                                                                            elseif(~strcmp(signal.DomainParams_.Activity,'Self'))
                                                                                                if sfSig.HasOutputData
                                                                                                    enumType=extractAfter(sfSig.OutputData.DataType,': ');
                                                                                                    [isEnumeration,enumInfo{1}]=getEnumerationInfo(enumType);
                                                                                                else
                                                                                                    [isEnumeration,enumInfo{1}]=fgetStateNames(sfSig);
                                                                                                end
                                                                                            else
                                                                                                isBoolean=true;
                                                                                            end

                                                                                            function[isEnumeration,enumInfo]=fgetStateNames(chart)

                                                                                                literals=[];
                                                                                                enumInfo=cell(1,0);
                                                                                                states=chart.find('-isa','Stateflow.State','-depth',1);
                                                                                                for i=1:length(states)
                                                                                                    if~strcmp(states(i).Name,chart.Name)
                                                                                                        literals=[literals,{states(i).Name}];
                                                                                                    end
                                                                                                end
                                                                                                literals=[{'none'},literals];
                                                                                                isEnumeration=true;
                                                                                                values=0:length(literals)-1;
                                                                                                enumInfo.values=values';
                                                                                                enumInfo.strings=literals;


