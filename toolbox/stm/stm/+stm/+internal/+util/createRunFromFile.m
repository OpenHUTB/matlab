function[runID,listOfNotFoundSignals]=createRunFromFile(sigSpecArray,filePath,srcId)








    engine=Simulink.sdi.Instance.engine;
    repo=sdi.Repository(1);
    listOfNotFoundSignals='';
    nSigSpecs=length(sigSpecArray);


    not_found=ones(1,nSigSpecs);

    [~,~,ext]=fileparts(filePath);
    isMatFile=strcmpi(ext,'.mat');

    if isMatFile
        try
            runID=Simulink.sdi.createRun('bslnRun','file',filePath);
        catch me

            if strcmp(me.identifier,'SDI:sdi:ImportFileNotFound')
                error(message('stm:general:BaselineNotFound',filePath));
            else
                rethrow(me)
            end
        end
    else
        [sheets,ranges,model,~]=stm.internal.getSheetRangeInfo(srcId,...
        int32(stm.internal.SourceSelectionTypes.Baseline));
        useExcelOptions=~isempty(sheets);
        runID=Simulink.sdi.createRun('bslnRun');

        if useExcelOptions

            T=xls.internal.ReadTable(filePath,'Sheets',sheets,'Ranges',ranges,'Model',model);
            ds=T.readMetadata(xls.internal.SourceTypes.Output);
            Simulink.sdi.addToRun(runID,'vars',ds);
        else
            loc_createRunFromSpreadsheet(engine,filePath,runID);
        end
    end
    Simulink.sdi.internal.moveRunToApp(runID,'stm');
    runObj=Simulink.sdi.getRun(runID);



    Simulink.sdi.internal.ConnectorAPI.disableEventCallback('treeSignalPropertyEvent');
    ocSys=onCleanup(...
    @()Simulink.sdi.internal.ConnectorAPI.enableEventCallback(...
    'treeSignalPropertyEvent'));




    sigs_to_rmv=[];
    dataSrcMap=containers.Map({sigSpecArray.DataSource},(1:nSigSpecs));
    sigNameMap=containers.Map({sigSpecArray.SignalName},(1:nSigSpecs));
    blPathPortIndxMap=containers.Map('a',0);
    for indx=1:nSigSpecs
        if~isempty(sigSpecArray(indx).BlockPath)
            blPathPortIndxMap(strcat(sigSpecArray(indx).BlockPath,int2str(sigSpecArray(indx).PortIndex)))=indx;
        end
    end



    for sigObj=runObj.getAllSignals
        indx=[];


        dataSrc=sigObj.DataSource;


        if(any(sigObj.Dimensions~=1)&&~isempty(sigObj.Channel))||strcmp(sigObj.Complexity,'complex')
            dataSrc='';
            sigID=sigObj.ID;
            while(sigID&&isempty(dataSrc))

                sigID=engine.getSignalParent(sigID);
                if sigID
                    parentSig=Simulink.sdi.getSignal(sigID);
                    if isempty(parentSig.Channel)
                        dataSrc=engine.getSignalDataSource(sigID);
                    end
                end
            end
        end

        uniquePath=strcat(sigObj.BlockPath,int2str(sigObj.PortIndex));


        isBusLeaf=~isempty(repo.getSignalComplexityAndLeafPath(sigObj(1).ID).LeafBusPath);


        if dataSrcMap.isKey(dataSrc)
            indx=dataSrcMap(dataSrc);
        elseif sigNameMap.isKey(sigObj.Name)
            indx=sigNameMap(sigObj.Name);
        elseif~isBusLeaf&&blPathPortIndxMap.isKey(uniquePath)
            indx=blPathPortIndxMap(uniquePath);
        end

        if~isempty(indx)

            not_found(indx)=0;

            engine.setSignalAbsTol(sigObj.ID,sigSpecArray(indx).Abs);
            engine.setSignalRelTol(sigObj.ID,sigSpecArray(indx).Rel);
            engine.setSignalInterpMethod(sigObj.ID,sigSpecArray(indx).InterpMethod);
            engine.setSignalSyncMethod(sigObj.ID,sigSpecArray(indx).SyncMethod);
            repo.setSignalForwardTimeTol(sigObj.ID,sigSpecArray(indx).ForwardTimeTol);
            repo.setSignalBackwardTimeTol(sigObj.ID,sigSpecArray(indx).BackwardTimeTol);
        else

            sigs_to_rmv=[sigs_to_rmv,sigObj.ID];
        end
    end

    if~isempty(sigs_to_rmv)
        Simulink.sdi.deleteSignal(sigs_to_rmv);
    end




    if any(not_found)
        sigRowArr=arrayfun(@(sigSpec)loc_constructSigNotFoundRow(sigSpec),...
        sigSpecArray(find(not_found)),'UniformOutput',false);
        listOfNotFoundSignals=strjoin(sigRowArr,newline);
    end

    loadSimValuesInStmDebugger(runObj);
end

function loc_createRunFromSpreadsheet(engine,fileName,runID)

    excelReader=sl_iofile.ExcelReader(fileName);

    try

        jsonReturned=excelReader.importAll();
    catch
        jsonReturned=[];
    end

    if isempty(jsonReturned)

        return;
    end

    outStruct=jsondecode(jsonReturned).arrayOfListItems;

    arrayfun(@(sigMetaArr)addToRun(engine.WksParser,engine,runID,{sigMetaArr.Parser}),outStruct);
end


function sigRow=loc_constructSigNotFoundRow(specStruct)
    sigRow=['<b>',getString(message('stm:general:Name')),'</b> '...
    ,specStruct.SignalName,'  <b>',getString(message('stm:general:DataSource')),'</b> ',specStruct.DataSource];
end

function loadSimValuesInStmDebugger(runObj)

    import stm.internal.SlicerDebuggingStatus;
    if stm.internal.slicerDebugStatus~=SlicerDebuggingStatus.DebugModeTestRun


        return;
    end

    dataSet=Simulink.SimulationData.Dataset();

    dataSetToExport=runObj.export();

    dataSet=populateSignalsInDataSet(dataSet,dataSetToExport);


    stmDebugger=stm.internal.StmDebugger.getInstance();
    stmDebugger.secondSimData=dataSet;
end

function dataSetToPopulate=populateSignalsInDataSet(dataSetToPopulate,dataSetToExtractFrom)


    numElems=dataSetToExtractFrom.numElements;
    for idx=1:numElems
        element=dataSetToExtractFrom.getElement(idx);
        if strcmpi(class(element),'Simulink.SimulationData.DataSet')
            dataSetToPopulate=populateSignalsInDataSet(dataSetToPopulate,element);
        elseif strcmpi(class(element),'Simulink.SimulationData.Signal')
            dataSetToPopulate=dataSetToPopulate.addElement(element);
        end
    end
end