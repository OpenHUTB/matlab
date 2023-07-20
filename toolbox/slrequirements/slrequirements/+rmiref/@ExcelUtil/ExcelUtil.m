

classdef ExcelUtil<handle

    properties
hApp
hDoc
sName
sFullName

sTimestamp
hBookmarks
iLevels
iParents


sContents
sLabels
    end

    methods


        function docData=ExcelUtil(docName)
            docData.hApp=rmiref.ExcelUtil.getApplication(false);
            if nargin<1||isempty(docName)
                docData.hDoc=docData.hApp.ActiveDocument;
            else
                docData.hDoc=rmiref.ExcelUtil.activateDocument(docName);
            end
            docData.sName=docData.hDoc.Name;
            docData.sFullName=docData.hDoc.FullName;
            docData.sTimestamp=0;
            docData.validate();
        end


        function validate(this)
            persistent lastSessionId
            if isempty(lastSessionId)
                lastSessionId=0;
            end
            try
                if~this.hDoc.Saved
                    currentSessionId=rmi.Informer.cache('getSessionId');
                    if currentSessionId>lastSessionId
                        this.promptToSave();
                        lastSessionId=currentSessionId;
                    end
                end
                fData=dir(this.sFullName);
                if~strcmp(this.sTimestamp,fData.date)
                    this.populateDocData(true);
                end
            catch


                this.hApp=rmiref.ExcelUtil.getApplication(false);
                this.hDoc=rmiref.ExcelUtil.activateDocument(this.sFullName);
                this.populateDocData(true);
            end
        end

        function[targetFilePath,html]=getContentForBookmark(this,hBookmark)
            doc=this.sFullName;
            targetFilePath=rmiref.ExcelUtil.getCacheFilePath(doc,hBookmark.Name);
            if rmiref.ExcelUtil.isUpToDate(targetFilePath,doc)
                resultsFile=targetFilePath;
            else
                hRange=hBookmark.RefersToRange;
                hRange=this.expandRange(hRange,5);
                resultsFile=rmiref.ExcelUtil.rangeToHtml(hRange,targetFilePath,this);
            end
            if~isempty(resultsFile)&&exist(resultsFile,'file')==2
                html=rmi.Informer.htmlFileToString(resultsFile);
            else
                error('rmiref.WordUtil.getbookmarkedItems(): failed to gextract item %s',hBookmark.Name);
            end
        end

        function range=expandRange(this,range,maxSize)%#ok<INUSD,INUSL>





            range=range.EntireRow;
        end

        function label=getLabel(this,idx)
            if this.iLevels(idx)==0
                label='';
            else
                label=this.sLabels{idx};
                if isempty(label)
                    oneRow=this.hDoc.Sheets.Item(1).Rows.Item(idx);
                    label=rmiref.ExcelUtil.rowToLabel(oneRow);
                end
                if isempty(label)
                    this.sLabels{idx}=' ';
                else
                    this.sLabels{idx}=label;
                end
            end
        end

    end

    methods(Access='private')

        function populateDocData(this,showProgress)

            if showProgress
                parentCallHasProgressBar=~rmiut.progressBarFcn('isCanceled');
                rmiut.progressBarFcn('set',0);
                this.hBookmarks=this.hDoc.Names;
                this.loadHierarchy([0,0.9]);
                rmiut.progressBarFcn('set',1);
                if~parentCallHasProgressBar
                    rmiut.progressBarFcn('delete');
                end
            else
                disp(['Querying document structure for ',this.sName,' ...']);
                this.hBookmarks=this.hDoc.Names;
                this.loadHierarchy([0,0.9]);
            end


            this.sContents=cell(size(this.iLevels));
            this.sLabels=cell(size(this.iLevels));


            this.updateTimestamp();
        end

        function updateTimestamp(this)
            fData=dir(this.sFullName);
            this.sTimestamp=fData.date;
        end

        loadHierarchy(this,statusBarData);

    end


    methods(Static)

        hDoc=activateDocument(doc)
        [docitem,button,idx]=findActxObject(doc,item)
        hApp=getApplication(true)
        [currentDocName,hApp,hDoc]=getCurrentDoc()
        inserted=insertInCell(hDoc,targetCell,varargin)
        count=insertions(method,varargin)
        sheet=itemToSheetName(item_name)
        [sheet,location]=locationToSheetName(location_string)
        hRange=selectCell(~,hDoc,locationStr)


        [html,cachedHtmlFile]=itemToHtml(doc,itemId);
        varargout=appState(method,varargin);
        yesno=isUpToDate(htmlFilePath,doc);
        fPath=getCacheFilePath(doc,rangeId);


        docUtil=docUtilObj(docPath);
        resultsFile=rangeToHtml(range,targetFilePath,utilObj);
        value=getDocProperty(file,propTag);
        contents=getBookmarkedItems(filename,varargin);
        contents=getItemsByPattern(filename,pattern);
        contents=getItemsByColumn(filename,column);
        contents=getItem(filename,arg);
        sections=getDocStructure(filename);
        parents=getParents(filename,arg);

        function label=rowToLabel(excelRowObj)
            label='';



            goodLength=7;
            cellNum=1;
            countEmpty=0;
            countGoodParts=0;
            while countGoodParts<3&&countEmpty<3
                oneCellText=excelRowObj.Cells.Item(cellNum).Text;
                if isempty(oneCellText)
                    countEmpty=countEmpty+1;
                else
                    countEmpty=0;
                    label=[label,oneCellText,' | '];%#ok<AGROW>
                    if length(oneCellText)>goodLength
                        countGoodParts=countGoodParts+1;
                    end
                end
                cellNum=cellNum+1;
            end
            if~isempty(label)
                label=label(1:end-3);
                if length(label)>50
                    label=[label(1:45),'...'];
                end
            end
        end

    end

end

