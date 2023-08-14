function runID=importFromXLS(this,repo,varParsers,addToRunID,varargin)






    p=inputParser;
    p.KeepUnmatched=true;
    p.addParameter('model','',@(x)validate_model(x));
    p.addParameter('sheets',{},@(x)validate_sheets(x));
    p.addOptional('OneRun',false,@mustBeNumericOrLogical);
    p.parse(varargin{:});
    params=p.Results;
    this.Model=char(params.model);
    this.Sheets=cellstr(params.sheets);
    oneRun=params.OneRun;


    existingSignalIDs=[];
    if(addToRunID<=0)

        runID=repo.createEmptyRun(this.RunName,0,'sdi',true);
    else

        runID=addToRunID;
        existingSignalIDs=repo.getAllSignalIDs(runID,'all');
    end


    try
        runID=locImportDataFromTable(repo,this,varParsers,runID,this.RunName,oneRun);
        this.CachedTableData=containers.Map;
    catch me
        if addToRunID<=0

            repo.removeRun(runID);
            runID=0;
            if this.CmdLine
                throwAsCaller(me);
            end
            return;
        end

        newSignalIDs=repo.getAllSignalIDs(runID,'all');
        for i=length(existingSignalIDs)+1:length(newSignalIDs)
            repo.remove(newSignalIDs(i))
        end

        if this.CmdLine
            throwAsCaller(me);
        end
    end
end


function ret=validate_model(x)
    ret=ischar(x)||(isstring(x)&&isscalar(x));
end


function ret=validate_sheets(x)
    ret=iscellstr(x)||isstring(x)||ischar(x);
end


function allRunIDs=locImportDataFromTable(repo,xlsFileParserObj,cachedVarParsers,runID,runName,oneRun)


    varParsers={};
    this=xlsFileParserObj;
    fileName=this.Filename;
    fileInfo=dir(fileName);
    fileSize=fileInfo.bytes;




    currentBytesRead=0;
    avgSheetSize=fileSize/this.NumSheets;
    valPerSig=1;
    if~isempty(this.ProgressTracker)
        totalNumSigs=locGetTotalNumSignals(cachedVarParsers,0);
        if fileSize>=(2*totalNumSigs)
            valPerSig=uint64(fileSize/totalNumSigs);
        end
        this.ProgressTracker.changeMaxValue(fileSize+valPerSig*totalNumSigs);
    end

    sw=warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');
    tmp=onCleanup(@()warning(sw));
    numRuns=ones(1,this.NumSheets);
    skippedSheets=[];
    for sheetIdx=1:this.NumSheets
        currSheetName=this.SheetNames{sheetIdx};


        if~isVariableChecked(cachedVarParsers{sheetIdx})
            skippedSheets(end+1)=sheetIdx;%#ok<AGROW>
            continue;
        end
        if~isempty(this.Sheets)&&~any(strcmp(this.Sheets,currSheetName))
            skippedSheets(end+1)=sheetIdx;%#ok<AGROW>
            continue;
        end

        numMetadataRows=this.NumMetaDataRows{sheetIdx}+1;
        [currTable,types]=this.readTableForSheet(currSheetName,sheetIdx);
        currentBytesRead=currentBytesRead+avgSheetSize;
        if~isempty(this.ProgressTracker)
            this.ProgressTracker.setCurrentProgressValue(currentBytesRead);
        end
        currTable=currTable(numMetadataRows+1:end,:);
        signalDataOnSheet=this.SignalMetaData{sheetIdx};
        signalDataOnSheet=locApplyBusTypes(signalDataOnSheet,this.Model);
        for sigIdx=1:length(signalDataOnSheet)
            currSigData=signalDataOnSheet(sigIdx);

            if isempty(currSigData.TimeColID)

                valTypes=types(:,sigIdx);
            else
                valTypes=types(:,currSigData.TimeColID);
            end
            valTypes=valTypes(numMetadataRows+1:end);

            if isa(currSigData.Element,'Simulink.SimulationData.Parameter')
                continue;
            end



            msgStr=locValidateTimeColumn(currSigData,sigIdx,currTable,...
            this.CmdLine,this.Model,valTypes,this.TypeIDs);
            if~isempty(msgStr)
                locShowXLImportErrorDlg(msgStr);
                locCancelImport(repo);
            end
            currSigData.RealDataVals={};
            currSigData.ImagDataVals={};
            md=currSigData.Element.getVisualizationMetadata;
            hasRealPart=length(currSigData.RealColIDs)>=1;
            hasImagPart=length(currSigData.ImagColIDs)>=1;
            numChannels=prod(currSigData.Dims);
            imagDataVals=[];
            for channelIdx=1:numChannels
                dataIdx=locChannelDataIdx(currSigData,channelIdx);


                timeVals=currTable(:,currSigData.TimeColID);
                timeVals=locRemoveTrailingEmpty(timeVals,valTypes,...
                this.TypeIDs);
                [numPts,~]=size(timeVals);

                if hasRealPart&&dataIdx(1)

                    realDataVals=currTable(:,currSigData.RealColIDs(dataIdx(1)));
                    realDataValTypes=types(:,currSigData.RealColIDs(dataIdx(1)));
                    realDataValTypes=realDataValTypes(numMetadataRows+1:end);
                    realDataVals=locRemoveTrailingEmpty(realDataVals,realDataValTypes,...
                    this.TypeIDs);
                    realDataValTypes=realDataValTypes(1:numel(realDataVals));
                    if all((realDataValTypes==1|realDataValTypes==4))

                        realDataVals=cell2mat(realDataVals);
                    else
                        realDataVals=string(realDataVals);
                    end
                    [realDataVals,md]=locGetDataForSignal(realDataVals,md,false,this.Model);
                    currSigData.Element=currSigData.Element.setVisualizationMetadata(md);
                else

                    emptyVals=repmat("",numPts,1);
                    [realDataVals,md]=locGetDataForSignal(emptyVals,md,true,this.Model);
                    currSigData.Element=currSigData.Element.setVisualizationMetadata(md);
                end

                if hasImagPart
                    if dataIdx(2)

                        imagDataVals=currTable(:,currSigData.ImagColIDs(dataIdx(2)));
                        imagDataValTypes=types(:,currSigData.ImagColIDs(dataIdx(2)));
                        imagDataValTypes=imagDataValTypes(numMetadataRows+1:end);
                        imagDataVals=locRemoveTrailingEmpty(imagDataVals,imagDataValTypes,...
                        this.TypeIDs);
                        imagDataValTypes=imagDataValTypes(1:numel(imagDataVals));
                        if(imagDataValTypes(1)==1||imagDataValTypes(1)==4)

                            imagDataVals=cell2mat(imagDataVals);
                        else
                            imagDataVals=string(imagDataVals);
                        end
                        imagDataVals=locGetDataForSignal(imagDataVals,md,false,this.Model);
                    else

                        emptyVals=repmat("",numPts,1);
                        imagDataVals=locGetDataForSignal(emptyVals,md,true,this.Model);
                    end
                end

                currSigData.RealDataVals{end+1}=locNaNPadIfNeeded(numPts,realDataVals);
                currSigData.ImagDataVals{end+1}=locNaNPadIfNeeded(numPts,imagDataVals);
            end
            data_real=[];
            if strcmpi(md.Type,'logical')
                data_real=logical(data_real);
            end
            data_imag=[];
            for colIdx=1:length(currSigData.RealDataVals)
                data_real=[data_real,currSigData.RealDataVals{colIdx}];%#ok
                try
                    data_imag=[data_imag,currSigData.ImagDataVals{colIdx}];%#ok
                catch
                    data_imag=[];
                end
                if isempty(data_imag)
                    currSigData.DataVals=data_real;
                else
                    currSigData.DataVals=complex(data_real,data_imag);
                end
            end
            if numel(currSigData.Dims)>1


                [numRows,~]=size(currSigData.DataVals);
                currSigData.DataVals=reshape(currSigData.DataVals.',...
                [currSigData.Dims,numRows]);
            end
            if isempty(currSigData.TimeColID)

                currSigData.TimeVals=currSigData.DataVals;
                currSigData.DataVals=ones(size(currSigData.DataVals));
                md=currSigData.Element.getVisualizationMetadata();
                md.IsMessage=true;
                currSigData.Element=currSigData.Element.setVisualizationMetadata(md);
            else
                currSigTimeVals=currTable(:,currSigData.TimeColID);
                currSigTimeValTypes=types(:,currSigData.TimeColID);
                currSigTimeValTypes=currSigTimeValTypes(numMetadataRows+1:end);
                currSigTimeVals=locRemoveTrailingEmpty(currSigTimeVals,currSigTimeValTypes,...
                this.TypeIDs);
                isTimeVectorSorted=true;
                try
                    currSigTimeVals=cell2mat(currSigTimeVals);
                    if~issorted(currSigTimeVals)
                        isTimeVectorSorted=false;
                    end
                catch

                    isTimeVectorSorted=false;
                end


                if~isTimeVectorSorted
                    if this.CmdLine
                        error(message('SDI:sdi:TimeNotIncMonotonicallyErr'));
                    else
                        msgStr=getString(message('SDI:sdi:TimeNotIncMonotonicallyErr'));
                        locShowXLImportErrorDlg(msgStr);
                        locCancelImport(repo);
                    end
                end
                currSigData.TimeVals=currSigTimeVals;
            end
            signalDataOnSheet(sigIdx)=currSigData;
        end
        currDataSet=Simulink.SimulationData.Dataset();
        busBlockPaths={};
        signalNamesFromFile={};
        SignalData=signalDataOnSheet;
        for sigIdx=1:length(SignalData)
            curSig=SignalData(sigIdx);
            if isa(curSig.Element,'Simulink.SimulationData.Parameter')
                currDataSet=currDataSet.addElement(curSig.Element);
            elseif curSig.isBus

                nameParts=curSig.BusHier;
                nameParts{end+1}=curSig.LeafName;%#ok
                if curSig.Element.BlockPath.getLength()
                    busBlockPaths{end+1}=curSig.Element.BlockPath;%#ok
                    hasBlockPath=true;
                else
                    busBlockPaths{end+1}=Simulink.SimulationData.BlockPath;%#ok
                    hasBlockPath=false;
                end
                rootBusName=nameParts{1};
                signalNameFromFile=strjoin(nameParts,'.');
                isLeafNameRepeated=any(contains(signalNamesFromFile,...
                signalNameFromFile));
                signalNamesFromFile{end+1}=signalNameFromFile;%#ok
                nameParts=nameParts(2:end);
                fullSignalName=strjoin(nameParts,'.');
                if isempty(currDataSet.getElement(rootBusName))||isLeafNameRepeated
                    sigBus=curSig.Element;
                    sigBus.Values=struct();
                    md=sigBus.getVisualizationMetadata();
                    sigBus=sigBus.setVisualizationMetadata({md});
                else
                    ds=currDataSet.getElement(rootBusName);
                    if isa(ds,'Simulink.SimulationData.Dataset')
                        sigBus=ds{end};
                    elseif isa(ds,'Simulink.SimulationData.Signal')
                        sigBus=ds;
                    end



                    if hasBlockPath&&~isequal(sigBus.BlockPath,busBlockPaths{end})
                        sigBus=curSig.Element;
                        sigBus.Values=struct();
                        md=sigBus.getVisualizationMetadata();
                        sigBus=sigBus.setVisualizationMetadata({md});
                        isLeafNameRepeated=true;
                    else
                        md=sigBus.getVisualizationMetadata();
                        md{end+1}=curSig.Element.getVisualizationMetadata();%#ok<AGROW>
                        sigBus=sigBus.setVisualizationMetadata(md);
                    end
                end
                sigTs=curSig.Element.Values;
                sigTs.Name=curSig.LeafName;
                if isstring(curSig.DataVals)
                    sigTs.set('Time',curSig.TimeVals,'Data',zeros(size(curSig.DataVals)));
                    sigTs.Data=curSig.DataVals;
                else
                    sigTs.set('Time',curSig.TimeVals,'Data',curSig.DataVals);
                end
                strToEval=['sigBus.Values.',fullSignalName,' = sigTs;'];
                try
                    eval(strToEval);
                catch me %#ok<NASGU>
                    me=message('SDI:sdi:XLSInvalidBusEl',fullSignalName);
                    Simulink.sdi.internal.warning(me);
                end
                if hasBlockPath
                    sigBus.BlockPath=busBlockPaths{end};
                end
                if isempty(currDataSet.getElement(rootBusName))||isLeafNameRepeated
                    currDataSet=currDataSet.addElement(sigBus,rootBusName);
                else

                    elemInd=find(cellfun(@(x)strcmp(x,rootBusName),...
                    currDataSet.getElementNames));
                    elemInd=elemInd(end);
                    currDataSet=setElement(currDataSet,elemInd,sigBus);
                end
                if isLeafNameRepeated
                    signalNamesFromFile={};
                end
            else
                sig=curSig.Element;
                sig.Name=curSig.LeafName;
                sigTs=timeseries.utcreatewithoutcheck(curSig.DataVals,curSig.TimeVals,false,false);


                if curSig.Dims(1)>1||curSig.isComplex
                    sigTs.Name=sig.Name;
                else
                    sigTs.Name=sig.Values.Name;
                end
                sigTs.DataInfo=sig.Values.DataInfo;
                sig.Values=sigTs;
                currDataSet=currDataSet.addElement(sig);
            end
        end



        sheetDSs=locSeparateSheetDatasets(currDataSet,cachedVarParsers{sheetIdx});
        wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
        for dsIdx=1:numel(sheetDSs)
            varParser=Simulink.sdi.internal.import.DatasetParser;
            varParser.VariableName=currSheetName;
            varParser.VariableValue=sheetDSs{dsIdx};
            varParser.TimeSourceRule='';
            varParser.WorkspaceParser=wksParser;
            varParsers{end+1}=varParser;%#ok
        end
        numRuns(sheetIdx)=numel(sheetDSs);
    end

    bSeparateRuns=any(numRuns>1);
    if bSeparateRuns


        cachedVarParsers=varParsers;
    else


        cachedVarParsers(skippedSheets)=[];
    end
    bSeparateRuns=~oneRun&&bSeparateRuns;
    allRunIDs=Simulink.sdi.internal.safeTransaction(...
    @locAddSignalsToRun,repo,runID,varParsers,...
    cachedVarParsers,bSeparateRuns,runName,this.ProgressTracker,valPerSig);
end


function[ret,md]=locGetDataForSignal(dataVals,md,bDefaultVals,mdl)


    if~isempty(md.Enum)
        ret=locCreateEnumData(dataVals,md,bDefaultVals);
    elseif~isempty(md.Fixdt)
        ret=locCreateFixdtData(dataVals,md,bDefaultVals,mdl);
    elseif strcmpi(md.Type,'string')
        ret=dataVals;
    else
        [ret,md]=locCreateBuiltinData(dataVals,md,bDefaultVals,mdl);
    end
end


function sigData=locApplyBusTypes(sigData,mdl)





    busMap=containers.Map;
    for idx=1:numel(sigData)
        if~isempty(sigData(idx).BusHier)
            rootBus=sigData(idx).BusHier{1};
            if busMap.isKey(rootBus)
                val=busMap(rootBus);
            else
                val=struct('Elements',[],'BusName','');
            end

            val.Elements(end+1)=idx;
            md=sigData(idx).Element.getVisualizationMetadata();
            if~isempty(md.Bus)
                val.BusName=md.Bus;
            end
            busMap(rootBus)=val;
        end
    end


    fw=Simulink.sdi.internal.Framework.getFramework();
    busNames=busMap.keys;
    for idx=1:numel(busNames)
        busData=busMap(busNames{idx});
        if~isempty(busData.BusName)

            try
                busStruct=fw.createMATLABStructForBus(mdl,busData.BusName);
                if isempty(busStruct)
                    continue
                end
            catch me %#ok<NASGU>
                continue
            end



            for idx2=1:numel(busData.Elements)
                elIdx=busData.Elements(idx2);
                md=sigData(elIdx).Element.getVisualizationMetadata();
                md.Bus=busData.BusName;
                md.Alias='';

                busPath=[{'busStruct'},sigData(elIdx).BusHier(2:end),{sigData(elIdx).LeafName}];
                pathStr=strjoin(busPath,'.');
                try
                    md.Type=eval(sprintf('class(%s)',pathStr));
                catch me %#ok<NASGU>

                    continue;
                end


                if strcmpi(md.Type,'embedded.fi')
                    md.Type='';
                    dt=eval(sprintf('%s.numerictype',pathStr));
                    md.Fixdt=fixdt(dt);
                end

                sigData(elIdx).Element=sigData(elIdx).Element.setVisualizationMetadata(md);
            end
        end
    end
end


function[ret,md]=locCreateBuiltinData(dataVals,md,bDefaultVals,mdl)

    ret=[];



    fw=Simulink.sdi.internal.Framework.getFramework();
    if~isempty(md.Alias)
        try
            dt=fw.evalWksVar(mdl,md.Alias);
        catch me %#ok<NASGU>

            dt=[];
        end
        if isscalar(dt)&&isa(dt,'Simulink.AliasType')&&~isempty(dt.BaseType)
            if contains(dt.BaseType,'enum:','IgnoreCase',true)

                md.Type=strtrim(dt.BaseType(6:end));
                md.Alias='';
            else
                md.Type=dt.BaseType;
            end
        end
    end


    try
        dt=fw.evalWksVar(mdl,md.Type);
        if isa(dt,'Simulink.NumericType')
            md.Fixdt=md.Type;
            md.Type='';
            md.Alias='';
            ret=locCreateFixdtData(dataVals,md,bDefaultVals,mdl);
            return
        elseif isa(dt,'Simulink.AliasType')
            md.Alias=md.Type;
            md.Type='';
            [ret,md]=locCreateBuiltinData(dataVals,md,bDefaultVals,mdl);
            return
        end
    catch me %#ok<NASGU>

    end


    if strcmpi(md.Type,'boolean')
        md.Type='logical';
    end

    sigType=md.Type;
    if isempty(sigType)
        sigType='double';
    end


    if bDefaultVals
        if isempty(enumeration(sigType))
            ret=zeros(size(dataVals),sigType);
        else
            md.Enum=sigType;
            ret=locCreateEnumData(dataVals,md,bDefaultVals);
        end
        return
    end





    try
        if strcmpi(sigType,'logical')
            ret=logical(dataVals);
        elseif isempty(enumeration(sigType))
            ret=eval([sigType,'(double(dataVals))']);
        else
            ret=eval([sigType,'(dataVals)']);
        end
    catch ex
        if strcmp(ex.identifier,'MATLAB:UndefinedFunction')


            msgStr=getString(message('SDI:sdi:XLSUnknownEnumClass',sigType,md.Name));
            Simulink.sdi.internal.warning('SDI:sdi:XLSUnknownEnumClass',msgStr);
            ret=dataVals;
        end
    end
end


function ret=locCreateEnumData(dataVals,md,bDefaultVals)

    ret=[];

    eVals=enumeration(md.Enum);
    if isempty(eVals)
        msgStr=getString(message('SDI:sdi:XLSUnknownEnumClass',md.Enum,md.Name));
        Simulink.sdi.internal.warning('SDI:sdi:XLSUnknownEnumClass',msgStr);
        ret=dataVals;
        return
    end


    if bDefaultVals
        try
            defVal=eval([md.Enum,'.getDefaultValue']);
        catch me %#ok<NASGU>
            defVal=eVals(1);
        end
        ret=repmat(defVal,size(dataVals));
        return
    end

    try
        ret=eval([md.Enum,'(dataVals)']);
    catch ex
        if strcmp(ex.identifier,'MATLAB:UndefinedFunction')


            msgStr=getString(message('SDI:sdi:XLSUnknownEnumClass',md.Enum,md.Name));
            Simulink.sdi.internal.warning('SDI:sdi:XLSUnknownEnumClass',msgStr);
            ret=dataVals;
        end
    end
end


function ret=locIsFixedDT(dt)
    if~isscalar(dt)
        ret=false;
    else
        ret=isa(dt,'Simulink.NumericType')||isa(dt,'embedded.numerictype');
    end
end


function ret=locCreateFixdtData(dataVals,md,bDefaultVals,mdl)

    if bDefaultVals
        ret=zeros(size(dataVals));
    else
        ret=double(dataVals);
    end




    fw=Simulink.sdi.internal.Framework.getFramework();
    try
        dt=fw.evalWksVar(mdl,md.Fixdt);
    catch me %#ok<NASGU>
        dt=[];
    end



    if~locIsFixedDT(dt)
        try
            [dt,bScaledDouble]=fixdt(md.Fixdt);
            if bScaledDouble
                dt=numerictype(dt,'DataType','ScaledDouble');
            end
        catch me

            Simulink.sdi.internal.warning(me.identifier,me.message);
            return
        end

        if~locIsFixedDT(dt)
            msg=getString(message('SDI:sdi:XLSUnknownFixdtClass',md.Fixdt,md.Name));
            Simulink.sdi.internal.warning('SDI:sdi:XLSUnknownFixdtClass',msg);
            return
        end


    end


    try
        fpData=fi(ret,dt);
    catch me

        Simulink.sdi.internal.warning(me.identifier,me.message);
        return
    end

    ret=fpData;
end


function allRunIDs=locAddSignalsToRun(repo,runID,varParsers,cachedVarParsers,bSeparateRuns,runName,progressTracker,progPerSig)
    leafSigs=int32.empty;
    runTimeRange=struct('Start',[],'Stop',[]);
    parentSigID=0;
    onlyOneRun=true;
    streamedRunID=0;
    allRunIDs=runID;

    numParsers=length(varParsers);
    for parserIdx=1:numParsers

        if bSeparateRuns&&parserIdx>1
            runID=repo.createEmptyRun(runName,0,'sdi',true);
            allRunIDs(end+1)=int32(runID);%#ok<AGROW>
        end
        runIDs=int32(runID);


        if isHierarchical(varParsers{parserIdx})
            [~,~,leafIDs,runTimeRange]=locCreateHierarchicalSignal(...
            repo,runID,parentSigID,varParsers{parserIdx},...
            cachedVarParsers{parserIdx},onlyOneRun,runIDs,...
            streamedRunID,runTimeRange,progressTracker,progPerSig);
        else
            [~,leafIDs,runTimeRange]=locCreateLeafSignal(repo,runID,...
            parentSigID,varParsers{parserIdx},...
            cachedVarParsers{parserIdx},runTimeRange,progressTracker,progPerSig);
        end
        leafSigs=[leafSigs,leafIDs];%#ok<AGROW>
    end
end


function[sigID,runIDs,leafSigs,runTimeRange]=locCreateHierarchicalSignal(...
    repo,runID,parentSigID,varParser,cachedVarParser,onlyOneRun,...
    runIDs,streamedRunID,runTimeRange,progressTracker,progPerSig)

    leafSigs=int32.empty;
    sigID=int32.empty;
    if~isVariableChecked(cachedVarParser)
        return
    end


    sigID=parentSigID;
    if~isVirtualNode(varParser)
        sigID=locCreateLeafSignal(repo,runID,parentSigID,varParser,...
        cachedVarParser,runTimeRange,progressTracker,progPerSig);
        forEachDims=getForEachParentDims(varParser);
        if~isempty(forEachDims)
            setSignalIsForEachParent(repo,sigID,uint64(forEachDims));
        end
    end


    try
        childParsers=getChildren(varParser);
        cachedChildParsers=getChildren(cachedVarParser);
        for idx=1:length(childParsers)
            if isHierarchical(childParsers{idx})
                [~,runIDs,leafIDs,runTimeRange]=locCreateHierarchicalSignal(...
                repo,runID,sigID,childParsers{idx},...
                cachedChildParsers{idx},onlyOneRun,runIDs,...
                streamedRunID,runTimeRange,progressTracker,progPerSig);
            else
                [~,leafIDs,runTimeRange]=locCreateLeafSignal(repo,...
                runID,sigID,childParsers{idx},cachedChildParsers{idx},...
                runTimeRange,progressTracker,progPerSig);
            end
            leafSigs=[leafSigs,leafIDs];%#ok<AGROW>
        end
    catch
    end


    if isempty(leafSigs)&&~isVirtualNode(varParser)
        repo.remove(sigID);
        sigID=int32.empty;
    end
end


function[sigID,leafSigs,runTimeRange]=locCreateLeafSignal(repo,runID,...
    parentSigID,varParser,cachedVarParser,runTimeRange,progressTracker,progPerSig)
    if nargin<7
        runTimeRange.Start=int32.empty;
        runTimeRange.Stop=int32.empty;
    end
    leafSigs=int32.empty;
    sigID=int32.empty;
    if~isVariableChecked(cachedVarParser)
        return
    end

    fw=Simulink.sdi.internal.AppFramework.getSetFramework();


    if~isempty(progressTracker)
        curVal=progressTracker.getCurrentProgressValue()+progPerSig;
        tmp=onCleanup(@()progressTracker.setCurrentProgressValue(curVal));
    end


    sampleDims=int32(getSampleDims(varParser));
    timeDim=int32(getTimeDim(varParser));
    dataVals=getTimeAndDataForSignalConstruction(varParser);
    hasData=~isempty(dataVals.Data);
    if~hasData&&~isHierarchical(varParser)
        return
    elseif~hasData
        dataVals=[];
    else
        totalChannels=prod(sampleDims);


        if isempty(runTimeRange.Start)||dataVals.Time(1)<runTimeRange.Start
            runTimeRange.Start=dataVals.Time(1);
        end
        if isempty(runTimeRange.Stop)||dataVals.Time(end)>runTimeRange.Stop
            runTimeRange.Stop=dataVals.Time(end);
        end
    end


    bpath=locRepInvalidChars(getBlockSource(varParser));
    signalName=locRepInvalidChars(getSignalLabel(varParser));
    if isempty(bpath)&&~isempty(varParser.VariableBlockPath)
        bpath=varParser.VariableBlockPath;
        if~isempty(varParser.VariableSignalName)||...
            contains(signalName,'.find(''')
            signalName=varParser.VariableSignalName;
        end
    end
    if~isempty(varParser.ForEachIter)
        dimsStr=sprintf('%d,',varParser.ForEachIter);
        signalName=[signalName,'(',dimsStr(1:end-1),')'];
    end


    if hasData
        channelIdx=int32(1);
    else
        channelIdx=int32.empty;
    end


    dataSourceStr=getDataSource(varParser);
    unitStr=getUnit(varParser);
    sigID=repo.add(...
    repo,...
    runID,...
    getRootSource(varParser),...
    getTimeSource(varParser),...
    dataSourceStr,...
    dataVals,...
    bpath,...
    getModelSource(varParser),...
    signalName,...
    timeDim,...
    sampleDims,...
    int32(getPortIndex(varParser)),...
    channelIdx,...
    '',...
    getMetaData(varParser),...
    int32(parentSigID),...
    getRootSource(varParser),...
    getInterpolation(varParser),...
    unitStr);


    tmMode=getTimeMetadataMode(varParser);
    tmNumPts=0;
    if~isempty(tmMode)
        repo.setSignalTmMode(sigID,tmMode);
        if~isempty(dataVals)
            tmNumPts=length(dataVals.Time);
            repo.setSignalTmNumPoints(sigID,tmNumPts);
        end
    end


    fullPath=getFullBlockPath(varParser);
    if fullPath.getLength()>1
        repo.setSignalBlockSource(sigID,fullPath.convertToCell());
    end


    hierRef=getHierarchyReference(varParser);
    if~isempty(hierRef)
        repo.setSignalHierarchyReference(sigID,hierRef);
    end
    leafPathStr=locRepInvalidChars(varParser.LeafBusPath);
    if~isempty(leafPathStr)&&hasData
        repo.setLeafBusSignal(sigID,leafPathStr);
        if fw.isImportCancelled()
            locCancelImport(repo);
        end
    end
    stStr=getSampleTimeString(varParser);
    if~isempty(stStr)
        repo.setSignalSampleTimeLabel(sigID,stStr);
    end
    dtStr=getDomainType(varParser);
    if~isempty(dtStr)
        repo.setSignalDomainType(sigID,dtStr);
    end
    if isEventBasedSignal(varParser)
        repo.setSignalIsEventBased(sigID,true);
    end
    if~isempty(varParser.ForEachIter)
        repo.setSignalForEachIter(sigID,uint64(varParser.ForEachIter));
    end
    [logName,sigName,propName]=getCustomExportNames(varParser);
    if~isempty(logName)||~isempty(sigName)||~isempty(propName)
        repo.setSignalExportNames(sigID,logName,sigName,propName);
    end


    md=getExtendedSDIProperties(varParser);
    if~isempty(md)&&isstruct(md)
        locSetExtendedProperties(repo,sigID,md,varParser,runID);
    end

    if isTopLevelDatasetElement(varParser)
        repo.setSignalIsTopLevelElement(sigID);
    end


    if hasData

        keepDimensions=true;
        firstLeafID=locGetFirstLeafSignal(repo,sigID);



        bIsFixedMatrix=totalChannels>1;
        if bIsFixedMatrix&&~isempty(timeDim)&&timeDim==1&&numel(sampleDims)<2
            dataVals.Data=dataVals.Data.';
        end


        repo.setSignalDataValues(firstLeafID,dataVals,keepDimensions);



        if firstLeafID~=sigID
            leafSigs=repo.getSignalChildren(sigID);
            locSetChannelProperties(repo,leafSigs,dataSourceStr,sampleDims,...
            tmMode,tmNumPts,unitStr,dtStr,leafPathStr,bIsFixedMatrix);
            if~isempty(md)&&isstruct(md)
                for idx=1:numel(leafSigs)
                    locSetExtendedProperties(repo,leafSigs(idx),md,varParser,runID);
                end
            end
        else
            leafSigs=firstLeafID;
        end
    end
    if fw.isImportCancelled()
        locCancelImport(repo);
    end

    setSignalCustomMetaData(varParser,sigID);
end


function sigID=locGetFirstLeafSignal(repo,sigID)
    childIDs=repo.getSignalChildren(sigID);
    if~isempty(childIDs)
        sigID=locGetFirstLeafSignal(repo,childIDs(1));
    end
end


function locSetChannelProperties(repo,childIDs,dataSourceStr,sampleDims,...
    tmMode,tmNumPts,unitStr,dtStr,leafPathStr,bIsFixedMatrix)


    numLeaves=numel(childIDs);
    for idx=1:numLeaves
        if bIsFixedMatrix
            idxStr=locGetChannelIdxStr(sampleDims,idx);
            repo.setSignalDataSource(childIDs(idx),[dataSourceStr,idxStr]);
        else
            repo.setSignalDataSource(childIDs(idx),dataSourceStr);
        end
        if~isempty(tmMode)
            repo.setSignalTmMode(childIDs(idx),tmMode);
            repo.setSignalTmNumPoints(childIDs(idx),tmNumPts);
        end
        if~isempty(unitStr)
            repo.setUnit(childIDs(idx),unitStr);
        end
        if~isempty(dtStr)
            repo.setSignalDomainType(childIDs(idx),dtStr);
        end
        if~isempty(leafPathStr)
            repo.setLeafBusSignal(childIDs(idx),leafPathStr);
        end
    end
end


function idxStr=locGetChannelIdxStr(sampleDims,channelIdx)
    dimIdx=cell(size(sampleDims));
    [dimIdx{:}]=ind2sub(sampleDims,channelIdx);
    channel=cell2mat(dimIdx);
    numDims=length(channel);
    if numDims==1
        idxStr=sprintf('(:,%d)',channel);
    else
        idxStr=sprintf('%d,',channel);
        idxStr=sprintf('(%s:)',idxStr);
    end
end


function ret=locRepInvalidChars(str)
    ret=regexprep(str,'\n',' ');
end


function locCancelImport(~)
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    wksParser.IsImportCancelled=true;

    msgID='XLSImport:Cancelled';
    msg='XL import is cancelled';
    impEx=MException(msgID,msg);
    throw(impEx);
end


function locShowXLImportErrorDlg(msgStr)
    titleStr=getString(message('SDI:sdi:ImportError'));
    okStr=getString(message('SDI:sdi:OKShortcut'));
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    ctrl=Simulink.sdi.internal.controllers.ImportDialog.getController();
    fw.displayMsgBox(...
    'default',...
    titleStr,...
    msgStr,...
    {okStr},...
    0,...
    -1,...
    [],...
    'clientID',ctrl.ClientID);
end


function ret=locSeparateSheetDatasets(fullDs,cachedParser)


    ret={};


    parserChildren=cachedParser.getChildren();
    assert(numel(parserChildren)==fullDs.numElements);


    curSim='';
    curSource='';
    curDS=Simulink.SimulationData.Dataset;


    for idx=1:fullDs.numElements
        el=fullDs{idx};
        md=el.getVisualizationMetadata();


        if iscell(md)

            thisSim='';
            thisSource='';
            for idx2=1:numel(md)
                md{idx2}.Simulation=lower(char(md{idx2}.Simulation));
                md{idx2}.Source=lower(char(md{idx2}.Source));
                if~strcmp(md{idx2}.Simulation,thisSim)
                    thisSim=md{idx2}.Simulation;
                end
                if~strcmp(md{idx2}.Source,thisSource)
                    thisSource=md{idx2}.Source;
                end
            end


            for idx2=1:numel(md)
                if isempty(thisSim)
                    md{idx2}.Simulation=curSim;
                else
                    md{idx2}.Simulation=thisSim;
                end
                if isempty(thisSource)
                    md{idx2}.Source=curSource;
                else
                    md{idx2}.Source=thisSource;
                end
            end


            el=el.setVisualizationMetadata(md);


        elseif isstruct(md)
            md.Simulation=char(md.Simulation);
            md.Source=char(md.Source);


            if isempty(md.Simulation)
                md.Simulation=curSim;
            end
            if isempty(md.Source)
                md.Source=curSource;
            end


            md.Simulation=lower(md.Simulation);
            md.Source=lower(md.Source);
            el=el.setVisualizationMetadata(md);

            thisSim=md.Simulation;
            thisSource=md.Source;
        end


        if~strcmpi(thisSim,curSim)||~strcmpi(thisSource,curSource)
            if curDS.numElements
                ret{end+1}=curDS;%#ok<AGROW>
                curDS=Simulink.SimulationData.Dataset;
            end
            curSim=thisSim;
            curSource=thisSource;
        end


        if isVariableChecked(parserChildren{idx})
            curDS=curDS.add(el);
        end
    end


    if curDS.numElements
        ret{end+1}=curDS;
    end
end


function err=locValidateTimeColumn(sigData,sigIdx,dataTable,bThrow,mdl,valTypes,typeIDs)
    err='';
    bError=false;
    if isempty(sigData.TimeColID)||(sigIdx==1&&sigData.TimeColID~=1)


        if~isempty(sigData.BusHier)||sigData.isComplex

            bError=true;
        elseif~isequal(sigData.Dims,1)||numel(sigData.RealColIDs)~=1

            bError=true;
        else

            md=sigData.Element.getVisualizationMetadata();
            vals=dataTable(:,sigData.RealColIDs(1));
            vals=locRemoveTrailingEmpty(vals,valTypes,typeIDs);
            vals=cell2mat(vals);
            vals=locGetDataForSignal(vals,md,false,mdl);
            if~isa(vals,'double')||~issorted(vals)
                bError=true;
            end
        end
    end


    if bThrow&&bError
        error(message('SDI:sdi:XLInvalidFcnCall',sigData.LeafName));
    elseif bError
        err=getString(message('SDI:sdi:XLInvalidFcnCall',sigData.LeafName));
    end
end


function locSetExtendedProperties(repo,sigID,md,varParser,runID)

    if isfield(md,'CustomName')&&~isempty(md.CustomName)
        repo.setSignalLabel(sigID,char(md.CustomName))
    end
    if isfield(md,'AbsTol')&&~isempty(md.AbsTol)
        val=str2double(md.AbsTol);
        if~isnan(val)&&val>0
            repo.setSignalAbsTol(sigID,val);
        end
    end
    if isfield(md,'RelTol')&&~isempty(md.RelTol)
        val=str2double(md.RelTol);
        if~isnan(val)&&val>0
            repo.setSignalRelTol(sigID,val);
        end
    end
    if isfield(md,'TimeTol')&&~isempty(md.TimeTol)
        val=str2double(md.TimeTol);
        if~isnan(val)&&val>0
            repo.setSignalTimeTol(sigID,val);
        end
    end
    if isfield(md,'LaggingTol')&&~isempty(md.LaggingTol)
        val=str2double(md.LaggingTol);
        if~isnan(val)&&val>0
            repo.setSignalBackwardTimeTol(sigID,val);
        end
    end
    if isfield(md,'LeadingTol')&&~isempty(md.LeadingTol)
        val=str2double(md.LeadingTol);
        if~isnan(val)&&val>0
            repo.setSignalForwardTimeTol(sigID,val);
        end
    end
    if isfield(md,'Sync')&&~isempty(md.Sync)
        val=lower(md.Sync);

        if strcmp(val,'intersection')
            repo.setSignalSyncMethod(sigID,val);
        end
    end
    if isfield(md,'Alias')&&~isempty(md.Alias)&&~isHierarchical(varParser)
        repo.setSignalDataTypeAliasName(sigID,md.Alias);
    end
    if isfield(md,'IsMessage')&&isequal(md.IsMessage,true)
        repo.setSignalIsEventBased(sigID,true);
    end


    if isfield(md,'Bus')&&~isempty(md.Bus)&&isempty(varParser.LeafBusPath)&&isHierarchical(varParser)
        repo.setSignalDataTypeAliasName(sigID,md.Bus);
    end


    if isfield(md,'Simulation')&&~isempty(md.Simulation)
        repo.setRunMetaDataUstring(runID,'SimulationID',md.Simulation);
    end
    if isfield(md,'Source')&&~isempty(md.Source)
        repo.setRunMetaDataUstring(runID,'SimulationSource',md.Source);
    end


    if isfield(md,'IsEventBased')&&~isempty(md.IsEventBased)
        repo.setSignalIsEventBased(sigID,md.IsEventBased);
        if(md.IsEventBased)

            EMPTY_STR='';
            repo.setSignalSampleTimeLabel(sigID,EMPTY_STR);
        end
    end


    if isfield(md,'OverridePortIndex')&&md.OverridePortIndex
        repo.setSignalPortIndex(sigID,0);
    end
end


function dataIdx=locChannelDataIdx(sigData,channelIdx)
    isImg=~isempty(sigData.ImagColIDs);
    if isImg
        dataIdx=[1,1];
    else
        dataIdx=[1,0];
    end


    if isempty(sigData.ChannelIdxs)
        return
    end


    channelIdxs=sigData.ChannelIdxs;
    if numel(sigData.Dims)>1
        for idx=1:numel(channelIdxs)
            if numel(channelIdxs{idx})>1
                curIdx=num2cell(channelIdxs{idx});
                channelIdxs{idx}=sub2ind(sigData.Dims,curIdx{:});
            end
        end
    end


    dataIdx=[0,0];
    pos=find(cell2mat(channelIdxs)==channelIdx);
    for idx=1:numel(pos)

        colIdx=sigData.DimsColIDs(pos(idx));
        pos2=find(sigData.RealColIDs==colIdx);
        if~isempty(pos2)
            dataIdx(1)=pos2;
        else
            pos2=find(sigData.ImagColIDs==colIdx);
            if~isempty(pos2)
                dataIdx(2)=pos2;
            end
        end
    end
end


function vals=locRemoveTrailingEmpty(vals,valTypes,typeIDs)
    supportedIds=valTypes==typeIDs.NUMBER|...
    valTypes==typeIDs.STRING|...
    valTypes==typeIDs.BOOLEAN;
    lastSupportedRow=find(supportedIds==1,1,'last');
    vals=vals(1:lastSupportedRow,:);
end


function d=locNaNPadIfNeeded(numPts,d)

    curLen=numel(d);
    if curLen>numPts
        d=d(1:curLen);
    elseif curLen&&curLen<numPts
        newPts=numPts-curLen;
        d(end:end+newPts)=nan;
    end
end


function ret=locGetTotalNumSignals(varParsers,ret)
    numParsers=length(varParsers);
    for idx=1:numParsers
        if isVariableChecked(varParsers{idx})
            if~isVirtualNode(varParsers{idx})
                ret=ret+1;
            end
            if isHierarchical(varParsers{idx})
                try
                    ret=locGetTotalNumSignals(getChildren(varParsers{idx}),ret);
                catch me %#ok<NASGU>
                end
            end
        end
    end
end
