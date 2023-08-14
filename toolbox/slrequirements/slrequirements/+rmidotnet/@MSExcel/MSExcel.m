classdef MSExcel<handle





    properties(SetAccess=private)

hDoc
sFile
zFile
sName
dTimestamp
sSheets

iSheet
iLevels
iParents
iLastRow
iLastCol

sTempDocPath
hTempDoc

namedRanges


cachedText


htmlFileDir

resourcePath

backlinks





hSheet

hSheetNames
    end


    methods(Access='private')

        initPaths(this);

    end

    methods


        function this=MSExcel(docName)
            this.htmlFileDir='';
            this.resourcePath='';
            this.zFile=docName;

            if exist(docName,'file')~=2
                error(message('Slvnv:slreq_import:ImportMissingFile',docName));
            elseif~rmiut.isCompletePath(docName)
                docName=which(docName);
            end
            this.hDoc=rmidotnet.MSExcel.activate(docName,false);
            this.sFile=this.hDoc.FullName.char;
            [~,sName,sExt]=fileparts(this.sFile);
            this.sName=[sName,sExt];
            this.sTempDocPath=[tempname,sExt];
            this.dTimestamp=0;
            this.cachedText={};
            this.refresh();
        end

        function sheetNames=getSheetNames(this)
            if isempty(this.sSheets)
                this.sSheets=rmidotnet.MSExcel.getSheetNamesInWorkbook(this.hDoc);
            end
            sheetNames=this.sSheets;
        end

        function idx=getActiveSheet(this)
            try

                idx=rmidotnet.MSExcel.getActiveSheetInWorkbook(this.hDoc);
            catch
                idx=-1;
            end
        end

        function setActiveSheet(this,idx)
            if ischar(idx)

                this.refresh();
                match=find(strcmp(this.sSheets,idx));
                if length(match)==1
                    this.iSheet=match;
                else
                    warning(['MSExcel: failed to set Active Sheet to ',idx]);
                end
            else
                this.iSheet=idx;
            end
        end

        function count=countRows(this)
            count=rmidotnet.MSExcel.countRowsInSheet(this.hDoc,this.iSheet);
        end

        function count=countCols(this)
            count=rmidotnet.MSExcel.countColsInSheet(this.hDoc,this.iSheet);
        end

        function success=validate(this)


            try
                success=this.refresh();
            catch
                try
                    this.hDoc=rmidotnet.MSExcel.activate(this.sFile);
                    success=this.refresh();
                catch ex
                    rmiut.warnNoBacktrace('Slvnv:rmiref:DocCheckExcel:locateDocument',ex.message);
                    success=false;
                end
            end
        end

        function yesno=matchTimestamp(this)
            docTime=this.getDocTime();
            yesno=(docTime==this.dTimestamp);
        end

        function docTime=getDocTime(this)
            docInfo=dir(this.zFile);
            docTime=docInfo.datenum;
        end

        function saveDocCacheTimestamp(this)






            this.hDoc.Save();
            this.dTimestamp=this.getDocTime();
        end

        function saveDocClearTimestamp(this)
            this.hDoc.Save();
            this.dTimestamp=0;
        end

        function delete(this)
            this.hDoc=[];
            this.dTimestamp=0;
        end

        function updateScratchCopy(this)

            if~this.hDoc.Saved()
                error(message('Slvnv:slreq_import:UseCurrentErrorMsg',this.sFile));
            end

            this.discardScratchCopy();

            copyfile(this.zFile,this.sTempDocPath,'f');
            this.hTempDoc=rmidotnet.MSExcel.activate(this.sTempDocPath);
        end

        function discardScratchCopy(this)
            if~isempty(this.hTempDoc)
                try
                    this.hTempDoc.Close(0);
                catch
                end
                this.hTempDoc=[];
            end
            if exist(this.sTempDocPath,'file')==2
                delete(this.sTempDocPath);
            end
        end



















        function summary=makeSummary(this,item)
            if isempty(this.cachedText)
                firstRow=1;
                lastRow=this.countRows();
                cacheTextContents(this,firstRow,lastRow,false);
            end
            row=item.address(1);
            col=item.address(2);
            width=item.range(2);
            if row<=size(this.cachedText,1)&&col+width-1<=size(this.cachedText,2)
                itemRowText=this.cachedText(row,col:col+width-1);
            else
                itemRowText=cell(1,width);

                mySheet=Microsoft.Office.Interop.Excel.Worksheet(this.hDoc.Sheets.Item(this.iSheet));
                myRow=Microsoft.Office.Interop.Excel.Range(mySheet.Rows.Item(row));
                myCells=myRow.Cells;
                for idx=1:width
                    colIdx=col+idx-1;
                    oneCell=Microsoft.Office.Interop.Excel.Range(myCells.Item(colIdx));
                    itemRowText(1,idx)=oneCell.Text.char;
                end
            end

            summary=itemRowText{1};
            current=1;
            while length(summary)<30&&current<width
                current=current+1;
                summary=[summary,' ',itemRowText{current}];%#ok<AGROW>
            end

            if length(summary)>100
                summary=[summary(1:60),'...'];
            end

            summary=rmiut.filterChars(summary,false);
        end

        function address=makeAddress(this,item)
            sheetName=this.sSheets{this.iSheet};
            row=item.address(1);
            col=item.address(2);
            colName=rmiut.xlsColNumToName(col);
            address=sprintf('$%s!%s%d',sheetName,colName,row);
        end


        function selectSheet(this)
            if this.iSheet==0

                this.hSheet=Microsoft.Office.Interop.Excel.Worksheet(this.hDoc.ActiveSheet);
                this.iSheet=this.hSheet.Index;
            else
                this.hSheet=Microsoft.Office.Interop.Excel.Worksheet(this.hDoc.Sheets.Item(this.iSheet));
            end
            this.hSheetNames=this.hSheet.Names;
            usedRange=this.hSheet.UsedRange;
            this.iLastRow=usedRange.Rows.Count;
            this.iLastCol=usedRange.Columns.Count;
        end

        function text=getTextFromCell(this,row,col)
            if row<=size(this.cachedText,1)&&col<=size(this.cachedText,2)
                text=this.cachedText{row,col};
            else

                this.selectSheet();
                text=rmidotnet.MSExcel.getTextFromCellInSheet(this.hSheet,[row,col]);
            end
        end

        function texts=getTextFromCells(this,rows,cols)
            if rows(end)<=size(this.cachedText,1)&&cols(end)<=size(this.cachedText,2)
                texts=this.cachedText(rows,cols);
            else
                texts=rmidotnet.MSExcel.getTextFromRange(this.sFile,rows,cols);
            end
        end

        function tf=isMergedCell(this,row,col)
            sheet=Microsoft.Office.Interop.Excel.Worksheet(this.hDoc.Worksheets.Item(this.iSheet));
            row=Microsoft.Office.Interop.Excel.Range(sheet.Rows.Item(row));
            cell=Microsoft.Office.Interop.Excel.Range(row.Cells.Item(col));
            tf=cell.MergeCells;
        end

        function mergedText=getMergedText(this,row,col)
            sheet=Microsoft.Office.Interop.Excel.Worksheet(this.hDoc.Worksheets.Item(this.iSheet));
            row=Microsoft.Office.Interop.Excel.Range(sheet.Rows.Item(row));
            cell=Microsoft.Office.Interop.Excel.Range(row.Cells.Item(col));
            range=cell.MergeArea;
            row_first=range.Row;
            row_last=row_first+range.Rows.Count-1;
            col_first=range.Column;
            col_last=col_first+range.Columns.Count-1;
            mergedText='';
            for i=row_first:row_last
                for j=col_first:col_last
                    mergedText=[mergedText,' ',this.cachedText{i,j}];%#ok<AGROW>
                end
            end
            mergedText=rmiut.filterChars(mergedText);
        end


        isUpToDate=refresh(this);
        [items]=getItems(this,varargin)

        [html,cacheFile]=preview(this,items)
        hRange=itemToRange(this,item,option)
        [html,htFile]=rangeToHtml(this,label,range,richContent)
        highlightInScratch(this,item,color);
        cacheNamedRangesInfo(this,varargin);
        cacheTextContents(this,firstRow,lastRow,showProgress);
        html=cellsToHtml(this,rowRange,colRange);
        [smryRng,descrRng,ratnlRng]=usdmGetPropRangesForItem(this,itemIdAddress,lastRowForThisItem,lastColumn);


        backlinksData=findBacklinks(this);
        namedRangeData=findNamedRange(this,rangeId);
    end


    methods(Static=true)


        result=application(varargin)
        docPath=currentDocPath()
        currentlyOpenDocuments=getOpenDocuments(counter)
        hDoc=activate(docPath,doShow)
        [rws,cols,text]=promptForSelection(docPath,instruction)
        [headersRow,headersText]=getColumnHeaders(docPath,sheetNameOrIdx)
        [textFromCells,isId,isNaturalText,isColumnEmpty]=getTextFromRange(docPath,rowRange,colRange)
        rangeString=itemToRangeString(item,option)
        name=findNameInRange(namedRanges,item)
        [isId,isNaturalText,isColumnEmpty]=classifyContents(cellTextArray);

        function text=getTextFromCellInSheet(sheet,address)
            row=Microsoft.Office.Interop.Excel.Range(sheet.Rows.Item(address(1)));
            cell=Microsoft.Office.Interop.Excel.Range(row.Cells.Item(address(2)));
            text=cell.Text.char;
        end

        function sheetNames=getSheetNamesInWorkbook(msDoc)
            allSheets=msDoc.Sheets;
            totalSheets=allSheets.Count;
            sheetNames=cell(totalSheets,1);
            for i=1:totalSheets
                oneSheet=Microsoft.Office.Interop.Excel.Worksheet(allSheets.Item(i));
                sheetNames{i}=oneSheet.Name.char;
            end
        end

        function[idx,title]=getActiveSheetInWorkbook(msDoc)
            oneSheet=Microsoft.Office.Interop.Excel.Worksheet(msDoc.ActiveSheet);
            idx=oneSheet.Index;
            title=oneSheet.Name;
        end


        function bottomUsedRow=countRowsInSheet(msDoc,sheetIdx)
            mySheet=Microsoft.Office.Interop.Excel.Worksheet(msDoc.Sheets.Item(sheetIdx));
            topUsedRow=mySheet.UsedRange.Rows.Row;
            totalUsedRows=mySheet.UsedRange.Rows.Count;
            bottomUsedRow=topUsedRow+totalUsedRows-1;
        end


        function rightmostUsedColumn=countColsInSheet(msDoc,sheetIdx)
            mySheet=Microsoft.Office.Interop.Excel.Worksheet(msDoc.Sheets.Item(sheetIdx));
            firstUsedColumn=mySheet.UsedRange.Columns.Column;
            totalUsedColumns=mySheet.UsedRange.Columns.Count;
            rightmostUsedColumn=firstUsedColumn+totalUsedColumns-1;
        end

        function[namedRanges,sheetIdx]=getNamedRangesInWorkbook(msDoc)
            sheetNames=rmidotnet.MSExcel.getSheetNamesInWorkbook(msDoc);
            namedRanges=msDoc.Names;
            sheetIdx=zeros(namedRanges.Count,1);

            i=0;
            rangeEnumerator=namedRanges.GetEnumerator();
            while rangeEnumerator.MoveNext()
                i=i+1;
                comObj=rangeEnumerator.Current();
                if~isa(comObj,'Microsoft.Office.Interop.Excel.Name')
                    namedRangeItem=Microsoft.Office.Interop.Excel.Name(comObj);
                end

                if contains(namedRangeItem.NameLocal.char,'!Print_Area')
                    continue;
                end

                sheetName=strtok(namedRangeItem.RefersTo.char,'!');
                sheetName(sheetName=='=')=[];
                sheetName(sheetName=='''')=[];
                matched=strcmp(sheetNames,sheetName);
                if any(matched)
                    sheetIdx(i)=find(matched);
                end
            end
        end

        function rowColAddress=getRowAndColAddress(shape)


            topLeftAddress=getRowAndColNumber(char(shape.TopLeftCell.Address));
            bottomRightAddress=getRowAndColNumber(char(shape.BottomRightCell.Address));
            middleAddress=(double(topLeftAddress)+double(bottomRightAddress))/2;
            rowColAddress=floor(middleAddress);

            function rowAndColNumbers=getRowAndColNumber(stringAddress)
                colAndRow=regexp(stringAddress,'\$([A-Z]+)\$([0-9]+)','tokens');
                if isempty(colAndRow)
                    rowAndColNumbers=[];
                else
                    rowAndColNumbers=[str2num(colAndRow{1}{2}),rmiut.xlsColNameToNum(colAndRow{1}{1})];%#ok<ST2NM> % [row col] as numbers
                end
            end
        end

        function deleteMatchedRows(pathToDoc,itemsToDelete,doSave)
            hDoc=rmidotnet.MSExcel.activate(pathToDoc,true);
            hSheet=Microsoft.Office.Interop.Excel.Worksheet(hDoc.ActiveSheet);
            fullRange=hSheet.Range('A1:Z1000');
            for i=1:numel(itemsToDelete)
                hCell=fullRange.Find(itemsToDelete{i});
                rowNumberToDelete=hCell.Row;
                hRowToDelete=Microsoft.Office.Interop.Excel.Range(hSheet.Rows.Item(rowNumberToDelete));
                hRowToDelete.Delete;
            end
            if doSave
                hDoc.Save();
            end
        end

    end


end
