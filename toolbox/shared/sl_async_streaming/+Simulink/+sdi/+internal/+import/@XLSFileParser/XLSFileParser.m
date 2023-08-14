classdef XLSFileParser<Simulink.sdi.internal.import.FileParser





    methods

        function this=XLSFileParser()
            this.REAL_PART_STR='(real)';
            this.IMAG_PART_STR='(imag)';
            this.BusRx='((^|\w|\))\.\w+)';
            this.DimsRx='(\((\s*\d+\s*,|\s*\d+\s*(?=\)))+\)(?!\.))';
            this.CachedTableData=containers.Map;
        end


        runID=import(this,varParsers,repo,addToRunID,varargin)
        extension=getFileExtension(~)
        varParsers=getVarParser(this,wksParser,fileName,varargin)
    end


    methods(Access=private)

        runID=importFromXLS(this,repo,varParsers,addToRunID,varargin)
        [ret,types]=readTableForSheet(this,sheetName,sheet)
        currDataSet=getSignalDataFromSheet(this,signalNames,...
        signalMetadata,signalIndices,timeIndices,sheetIdx)
        SignalData=initializeSignalData(this)


        rowNum=getRowNumFromCell(this,cellStr)
        colLabel=getXLColNameFromNum(~,colNum)
        [tt,types]=removeEmptyCols(this,tt,types)


        [rootBusName,remainingSigName]=getRootBusName(this,busName)
        isComplex=isComplexSignal(this,sigName)
        isBus=isBusSignal(this,sigName)
        isMultiDimensional=isMultiDimensionalSignal(this,leafName)
        extractedLeafName_Comp=extractSignalNameFromComplex(this,leafName)
        extractedLeafName_Dims=extractSignalNameFromDims(this,leafName);
        [realColIDs,imagColIDs]=getRealAndImagColIDs(this,leafName,...
        actualLeafStr,signalNames,signalIndices)
        isReal=isRealPart(this,leafName)
        isImag=isImagPart(this,leafName)

        [retSignalData,realColIDs,imagColIDs,extractedLeafName_Comp]=...
        extractComplexSignalData(this,signalData,signalNames,...
        signalIndices,leafName)
        [retSignalData,dimsColIDs]=...
        extractMultiDimensionalSignalData(this,isBus,signalData,...
        signalNames,signalIndices,leafName,timeIndices,ds,sigIdx)
        dataSet=getVarParserForSheet(this,SignalData,signalNames,...
        signalIndices,busHier,sheetIdx)
        [foundIndices,channels,dims]=findDimensionColIDs(this,currSigName,signalNames,...
        signalIndices,timeIndices,ds,bp,curSigIdx)
        dims=getSignalDimensions(this,sigName)
    end


    properties(Access=private)
        VarParsers={}
        SheetNames={}
        NumSheets=0
        SignalMetaData={}
        NumMetaDataRows={}
        UniqueBuses={}
        UniqueBusBlockPaths={}
REAL_PART_STR
IMAG_PART_STR
BusRx
DimsRx
        Model=''
        Sheets={}
CachedTableData
CachedTableTypes
WorkBook
TypeIDs
    end
end