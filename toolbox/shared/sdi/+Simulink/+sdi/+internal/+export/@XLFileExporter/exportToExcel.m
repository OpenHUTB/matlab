function ret=exportToExcel(this,eng,bFullRun,numSigs,opts,runIDs,sigIDs,bCmdLine)







    MAX_CELLS_FOR_SINGLE_WRITE=10000;
    bUseTracker=~isempty(this.ProgressTracker);


    this.readAllSignalValues(runIDs,sigIDs);



    if numSigs>0
        repo=sdi.Repository(1);
        for sigIdx=1:numSigs
            currentSig=Simulink.sdi.Signal(repo,sigIDs(sigIdx));
            parentRunID=currentSig.RunID;


            if isempty(find(runIDs==parentRunID,1))
                runIDs(end+1)=parentRunID;%#ok
                bFullRun(end+1)=false;%#ok
            end
        end
    end
    numRuns=length(runIDs);
    sheetNames=this.generateValidSheetNames(eng,runIDs);
    fileExists=exist(this.FileName,'file');
    sheetsToRemove={};


    this.HasWorkBook=false;
    try

        if fileExists
            if strcmpi(opts.overwrite,'file')
                if~bCmdLine
                    sw=warning('off','MATLAB:DELETE:Permission');
                    tmp=onCleanup(@()warning(sw));
                end
                delete(this.FileName);
                sheetsToRemove='default';
            elseif strcmpi(opts.overwrite,'sheets')
                sheetsToRemove=this.generateValidSheetNames(eng,runIDs);
                this.createWorkBook(false);
                if length(this.WorkBook.SheetNames)==1&&contains(sheetsToRemove,this.WorkBook.SheetNames{1})
                    delete(this.FileName);
                    this.HasWorkBook=false;
                    opts.overwrite='file';
                    sheetsToRemove='default';
                end
            end
        else
            sheetsToRemove='default';
        end


        repo=sdi.Repository(1);
        for runIdx=1:numRuns
            r=Simulink.sdi.Run(repo,runIDs(runIdx));
            if bFullRun(runIdx)
                [data,metaData,numMDRows]=this.createTableWithAllSignals(eng,r,opts);
            else
                [data,metaData,numMDRows]=this.createTableWithSelectedSignals(eng,r,sigIDs,opts);
            end
            runName=sheetNames{runIdx};



            startRow=numMDRows+2;
            if strcmpi(opts.overwrite,'sheets')&&any(contains(sheetsToRemove,runName))

                this.createWorkBook(false);
                this.removeSheet(runName);
                this.saveWorkBook();
                sheetsToRemove=setdiff(sheetsToRemove,runName);
            end



            writetable(metaData,this.FileName,'Sheet',runName,...
            'WriteVariableNames',false,'Range','A1',...
            'UseExcel',false);
            numCols=width(data);
            numRows=height(data);
            if~bUseTracker||numRows*numCols<=MAX_CELLS_FOR_SINGLE_WRITE
                this.createWorkBook(false);
                sheetObj=this.WorkBook.getSheet(runName);
                usedSheetRange=sheetObj.usedRange;
                appendRange=getRangeToWrite(usedSheetRange);
                numRange=sheetObj.getRange(appendRange,false);
                writeRng=[numRange(1),numRange(2),numRows,numCols];
                sheetObj.write(data,writeRng,false);
                if bUseTracker

                    curVal=this.ProgressTracker.getCurrentProgressValue();
                    curVal=curVal+numCols-1;
                    this.ProgressTracker.setCurrentProgressValue(curVal);
                end
            else
                locWriteTableColumns(this,data,runName,startRow);
            end
            this.saveWorkBook();
        end
        this.createWorkBook(false);
        if~isempty(sheetsToRemove)
            this.removeSheet(sheetsToRemove);
        end
        this.saveWorkBook();
    catch me
        wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
        if wksParser.IsImportCancelled
            this.saveWorkBook();
            me.throwAsCaller();
        end
        ret=false;
        switch me.identifier
        case{'MATLAB:spreadsheet:book:save','MATLAB:table:write:FileOpenInAnotherProcess'}
            errorStr=getString(message('SDI:sdi:UnableToWriteErr'));
        case 'MATLAB:spreadsheet:book:openSheetName'
            errorStr=[runName,' ',getString(message('SDI:sdi:SheetNotFoundErr'))];
        otherwise
            errorStr=me.message;
        end

        if bCmdLine
            error(me.identifier,errorStr);
        else
            locShowXLExportErrorDlg(errorStr);
        end
        return
    end
    ret=true;
end


function locWriteTableColumns(this,data,runName,startRow)
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    this.createWorkBook(true);
    [nRows,nCols]=size(data);
    sheetObj=this.WorkBook.getSheet(runName);

    MAX_COLS_TO_WRITE=100;
    numChunks=floor(nCols/MAX_COLS_TO_WRITE);
    lastChunkWidth=0;
    if numChunks<=1
        numChunks=1;
    else
        lastChunkWidth=nCols-numChunks*MAX_COLS_TO_WRITE;
    end

    for idx=1:numChunks
        startCol=MAX_COLS_TO_WRITE*(idx-1)+1;
        if fw.isImportCancelled()
            wksParser.IsImportCancelled=true;
            error('cancel')
        end
        if numChunks==1
            writeRng=[startRow,startCol,nRows,nCols];
            sheetObj.write(data,writeRng,false);
        else
            cellsToWrite=data(1:end,...
            MAX_COLS_TO_WRITE*(idx-1)+1:MAX_COLS_TO_WRITE*idx);
            writeRng=[startRow,startCol,nRows,MAX_COLS_TO_WRITE];
            sheetObj.write(cellsToWrite,writeRng,false);
        end
        this.ProgressTracker.incrementValue();
    end

    if lastChunkWidth>0
        if fw.isImportCancelled()
            wksParser.IsImportCancelled=true;
            error('cancel')
        end
        startCol=MAX_COLS_TO_WRITE*numChunks+1;
        cellsToWrite=data(1:end,MAX_COLS_TO_WRITE*numChunks:end);
        writeRng=[startRow,startCol,nRows,lastChunkWidth];
        sheetObj.write(cellsToWrite,writeRng,false);
        this.ProgressTracker.incrementValue();
    end
end


function locShowXLExportErrorDlg(msgStr)
    titleStr=getString(message('SDI:sdi:ExportError'));
    okStr=getString(message('SDI:sdi:OKShortcut'));
    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
    'default',...
    titleStr,...
    msgStr,...
    {okStr},...
    0,...
    -1,...
    []);
end

function rangeVal=getRangeToWrite(sheetWrittenRange)


    if~isempty(sheetWrittenRange)

        startRow=extractBefore(sheetWrittenRange,":");
        startNumInRow=regexp(startRow,'[0-9]');
        startRow=startRow(1:startNumInRow-1);
        endCol=extractAfter(sheetWrittenRange,":");
        startNumInRow=regexp(endCol,'[0-9]');
        endCol=str2double(endCol(startNumInRow:end))+1;
        rangeVal=convertStringsToChars(sprintf("%s%d",startRow,endCol));
    else
        rangeVal=[];
    end
end