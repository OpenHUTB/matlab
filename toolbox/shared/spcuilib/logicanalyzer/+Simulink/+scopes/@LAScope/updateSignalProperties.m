function updateSignalProperties(this,runID)
    orig_state=warning('off','Simulink:DataType:DynamicEnum_InvalidStorageType');

    sdiEngine=Simulink.sdi.Instance.engine;

    runIDs=sdiEngine.getAllRunIDs();
    isInvalidRunID=isempty(find(runIDs==runID,1));
    if(isInvalidRunID)
        sigProps.invalidRun=true;
        sigStruct={sigProps};
        warning(orig_state);
        this.createSignalObject(jsonencode(sigStruct));
        return;
    end

    sigIDs=sdiEngine.getAllSignalIDs(runID,'top');


    numSignals=length(sigIDs);
    sigStruct=cell(1,0);
    modelName=this.ModelName;
    laGraphicalSettings=get_param(modelName,'LogicAnalyzerGraphicalSettings');
    hasTrace=~isempty(laGraphicalSettings);
    displayBusElementNames=false;
    if~isempty(laGraphicalSettings)
        if~isempty(regexp(laGraphicalSettings,'displayBusElementNames','once'))
            displayBusElementNames=true;
        end
    end
    for indx=1:numSignals




        try
            sig=sdiEngine.getSignal(sigIDs(indx));
        catch
            continue;
        end
        if(sig.ParentID==0)
            sigProps=[];
            sigProps.runID=runID;
            sigProps=initializeSignalProps(sigProps);
            sigObj=sdiEngine.getSignalObject(sigIDs(indx));



            if isequal(sigObj.Domain,'Outports')||(isequal(sigObj.PortIndex,0)&&~strcmp(sigObj.Domain,'Stateflow'))
                continue;
            end
            try

                sigProps=getParentProperties(sigObj,sigProps);
            catch
                continue;
            end
            sigProps.hasTrace=hasTrace;
            sigProps.displayBusElementNames=displayBusElementNames;


            [sigProps]=getSignalProperties(sigObj,sigProps,0);
            sigProps=removeFields(sigProps);
            sigProps.enumInfo=jsonencode(sigProps.enumInfo);
            sigStruct{end+1}=sigProps;
        end
    end
    this.createSignalObject(jsonencode(sigStruct));
    warning(orig_state);
end

function[sigProps]=getSignalProperties(sigObj,sigProps,childIdx)




    isMuxOrMatrix=prod(sigObj.SampleDims)>1;
    if isMuxOrMatrix
        sigProps=getSignalPropertiesForLeaf(sigObj,sigProps,childIdx,isMuxOrMatrix);
    else

        sigChildren=sigObj.Children;
        numChildren=numel(sigChildren);
        if numChildren==0

            sigProps=getSignalPropertiesForLeaf(sigObj,sigProps,childIdx,isMuxOrMatrix);
        else
            for childIdx=1:numChildren



                [sigProps]=getSignalProperties(sigChildren(childIdx),sigProps,childIdx);
            end
        end
    end
end

function sigProps=getSignalPropertiesForLeaf(sigObj,sigProps,childIdx,isMuxOrMatrix)
    dataType=sigObj.DataType;
    numElems=prod(sigObj.SampleDims);
    if isMuxOrMatrix
        sigProps.signalWidth=sigProps.signalWidth+numElems;
    else
        sigProps.signalWidth=sigProps.signalWidth+1;
    end

    modelName=sigObj.Model;
    sigProps=getDatatypeProperties(sigObj,dataType,sigProps,modelName,isMuxOrMatrix);



    if isequal(sigProps.signalID,Inf)
        if isMuxOrMatrix

            if isequal(sigObj.Complexity,'complex')
                sigProps.signalID=sigObj.Children(1).Children(1).ID;
            else
                sigProps.signalID=sigObj.Children(1).ID;
            end
        else
            sigProps.signalID=sigObj.ID;
        end
    end

    if isMuxOrMatrix
        if isequal(sigObj.Complexity,'complex')
            sigProps.isComplex=[sigProps.isComplex,repmat([1,2],1,numElems)];
        else
            sigProps.isComplex=[sigProps.isComplex,zeros(1,numElems)];
        end
    else
        isComplex=0;
        if isequal(sigObj.Complexity,'complex')
            if isequal(childIdx,1)
                isComplex=1;
            else
                isComplex=2;


                sigProps.signalWidth=sigProps.signalWidth-1;
            end
        end
        sigProps.isComplex(end+1)=isComplex;
    end

    sampleTime=sigObj.SampleTime;
    if isMuxOrMatrix
        sigProps.isMultirate=false;
    else
        if~sigProps.isMultirate&&~isempty(sigProps.sampleTime)&&...
            ~isequal(sampleTime,sigProps.sampleTime)
            sigProps.isMultirate=true;
        else
            sigProps.sampleTime=sampleTime;
        end
    end
end

function sigProps=getDatatypeProperties(sigObj,dataType,sigProps,modelName,isMuxOrMatrix)
    if isMuxOrMatrix
        numElements=prod(sigObj.SampleDims);
        if isequal(sigObj.Complexity,'complex')
            numElements=numElements*2;
        end
        isBoolean=strcmpi('boolean',dataType);
        isFloatingPoint=isempty(dataType)||any(strcmpi({'double','single'},dataType));
        sigProps.isBoolean=[sigProps.isBoolean,repmat(isBoolean,1,numElements)];
        sigProps.isFloatingPoint=[sigProps.isFloatingPoint,repmat(isFloatingPoint,1,numElements)];
        sigProps.isEnumeration=[sigProps.isEnumeration,false(1,numElements)];
        sigProps.enumInfo=[sigProps.enumInfo,cell(1,numElements)];
        if isBoolean||isFloatingPoint
            sigProps.wordLength=[sigProps.wordLength,zeros(1,numElements)];
        else
            [wordLength,baseType]=getWordLength(dataType,modelName);
            if wordLength==0
                isBoolean=strcmpi('boolean',baseType);
                isFloatingPoint=any(strcmpi({'double','single'},baseType));
                sigProps.isBoolean(end-numElements-1:end)=isBoolean;
                sigProps.isFloatingPoint(end-numElements-1:end)=isFloatingPoint;
                if~(isBoolean||isFloatingPoint)
                    [isEnum,enumInfo]=getEnumerationInfo(dataType);
                    sigProps.isEnumeration(end-numElements-1:end)=isEnum;
                    sigProps.enumInfo(end-numElements-1:end)={enumInfo};
                end
            end
            sigProps.wordLength=[sigProps.wordLength,repmat(wordLength,1,numElements)];
        end
    else
        sigProps.isBoolean(end+1)=strcmpi('boolean',dataType);
        sigProps.isFloatingPoint(end+1)=isempty(dataType)||any(strcmpi({'double','single'},dataType));
        sigProps.isEnumeration(end+1)=false;
        sigProps.enumInfo{end+1}=[];
        if sigProps.isBoolean(end)||sigProps.isFloatingPoint(end)
            sigProps.wordLength(end+1)=0;
        else
            [sigProps.wordLength(end+1),baseType]=getWordLength(dataType,modelName);
            if sigProps.wordLength(end)==0
                sigProps.isBoolean(end)=strcmpi('boolean',baseType);
                sigProps.isFloatingPoint(end)=strcmpi('single',baseType)||...
                strcmpi('double',baseType);
                if~(sigProps.isBoolean(end)||sigProps.isFloatingPoint(end))
                    [sigProps.isEnumeration(end),sigProps.enumInfo{end}]=getEnumerationInfo(dataType);
                end
            end
        end

        if(sigProps.displayBusElementNames)
            fullLeafName=sigObj.Name;
            leafName=strsplit(fullLeafName,'.');
            sigProps.busElementNames{end+1}=leafName{end};
        end
    end
end

function sigProps=getParentProperties(sigObj,sigProps)
    blockPath=sigObj.BlockPath;
    sigProps.blockPath={blockPath};
    sigProps.outputPortIdx=sigObj.PortIndex;
    sigProps.blkh=get_param(blockPath,'Handle');
    portHandles=get_param(blockPath,'portHandles');
    if(strcmp(sigObj.Domain,'Stateflow'))
        sigProps.portHandle=-1;
        sigProps.isSF=true;
    elseif(isempty(portHandles.Outport))
        sigProps.portHandle=portHandles.Inport(sigProps.outputPortIdx);
    else
        sigProps.portHandle=portHandles.Outport(sigProps.outputPortIdx);
    end

    [sigName,shortName]=getFullyQualifiedName(sigObj,blockPath,sigProps.portHandle,sigProps.isSF);
    sigProps.name=sigName;
    sigProps.shortName=shortName;

    sigProps.signalDims=[];
    sigProps.mdlRefBlockPath=Simulink.BlockPath();
    hModel=sigObj.Model;


    isMdlRef=~strcmpi(get_param(hModel,'ModelReferenceTargetType'),'none');
    if isMdlRef
        sigProps.mdlRefBlockPath=get_param(hModel,'ModelReferenceNormalModeVisibilityBlockPath');
    end
    sigProps.mdlRefBlockPath=sigProps.mdlRefBlockPath.convertToCell();
    sigProps.isCommented=strcmp(get_param(sigProps.blkh,'Commented'),'on');
end

function sigProps=initializeSignalProps(sigProps)
    sigProps.dataType=[];
    sigProps.isBoolean=zeros(1,0);
    sigProps.signalWidth=0;
    sigProps.isFloatingPoint=zeros(1,0);
    sigProps.isComplex=zeros(1,0);
    sigProps.wordLength=zeros(1,0);
    sigProps.isEnumeration=zeros(1,0);
    sigProps.enumInfo=cell(1,0);
    sigProps.isMultirate=false;
    sigProps.sampleTime=[];
    sigProps.isCommented=false;
    sigProps.isSF=false;
    sigProps.hasTrace=false;
    sigProps.signalID=Inf;
    sigProps.isSerialized=false;
    sigProps.invalidRun=false;
    sigProps.busElementNames=cell(1,0);
end

function[wordLength,baseType]=getWordLength(dataType,modelName)
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
end

function sigProps=removeFields(sigProps)

    sigProps=rmfield(sigProps,'sampleTime');
    sigProps=rmfield(sigProps,'displayBusElementNames');
end
function[sigName,shortName]=getFullyQualifiedName(sigObj,blockPath,portH,isSF)

    if(isSF)
        shortName=sigObj.Name;
        sigName=sigObj.FullBlockPath;
    else
        delimiters=strfind(blockPath,'/');
        firstDelimiter=delimiters(1);
        blockPath=blockPath(firstDelimiter+1:length(blockPath));
        lineName='';
        if~isequal(portH,-1)
            lineName=get_param(portH,'Name');
        end

        if isempty(lineName)
            sigName=blockPath;

            ports=get_param(get_param(portH,'ParentHandle'),'portHandles');
            if length(ports.Outport)>1
                sigName=sprintf('%s:%d',sigName,sigObj.PortIndex);
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
            delimiters=strfind(regexprep(blockPath,'//','**'),'/');
            if isempty(delimiters)



                sigName=lineName;
            else

                finalDelimiter=delimiters(length(delimiters));
                blockPath=blockPath(1:finalDelimiter);
                blockPath=regexprep(blockPath,'//','/');
                sigName=[blockPath,lineName];
            end
            shortName=lineName;
        end
    end
end