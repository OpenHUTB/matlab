classdef XLFileExporter<Simulink.sdi.internal.export.FileExporter





    methods
        success=export(this,runIDs,signalIDs,~,eng,~,opts,bCmdLine)
        fileType=getFileType(this)
        this=setFileName(this,fileName)

        function ret=supportsCancel(~)
            ret=true;
        end
    end


    methods(Access=private)
        ret=getDefaultExportOptions(~,opts)

        ret=exportToExcel(this,eng,bFullRun,numSigs,opts,runIDs,sigIDs,bCmdLine)

        [data,metaData,numMDRows]=createTableWithAllSignals(this,eng,runObj,opts)
        [data,metaData,numMDRows]=createTableWithSelectedSignals(this,eng,runObj,sigIDs,opts)
        ret=createTable(this,eng,sigIDs,numMDRows,varargin)

        sheetNames=generateValidSheetNames(~,eng,runIDs)

        verifyXLColLimit(this,numCols)
        [ret,numMDRows]=createMetadataTable(~,namesRow,mdRows)
        [namesRow,mdRows]=getSignalNamesAndMetadaRows(this,eng,runObj,sigIDs,...
        dtRow,unitsRow,interpRow,bpathRow,portRow)
        [dtRow,unitsRow,interpRow,bpathRow,portRow]=initializeMetadataRows(~,opts)
        [namesRow,mdRows]=populateMetaDataRows(~,eng,sig,namesRow,mdRows)
        mdRows=omitMetadataForTimeCol(~,mdRows)

        readAllSignalValues(this,runIDs,sigIDs);
        ts=getValuesForSignal(this,sig);

        createWorkBook(this,useXL)
        removeSheet(this,sheetName)
        removeAllSheetsExcept(this,runName)
        saveWorkBook(this)
        groupedSigIDs=groupSigIDSBasedOnHierarchy(this,eng,sigIDs)
    end


    properties(Access=private)
        FileType='.xlsx';
        TimeColName='time';
        RateBasedGrouping=true;
        WorkBook;
        HasWorkBook=false;
        MAX_ROWS_ALLOWED=1048576;
        MAX_COLS_ALLOWED=16384;
        SignalValuesCache=[];
    end

end
