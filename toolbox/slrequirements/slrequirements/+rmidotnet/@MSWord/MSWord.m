classdef MSWord<handle





    properties(SetAccess=private)

hDoc
sFile
zFile
sName
dTimestamp

sTempDocPath
hTempDoc

iLevels
iParents
iStarts
iEnds
sLabels


sTexts



sLabelPrefixes



htmlFileDir

resourcePath

bookmarks
backlinks
    end



    methods


        function this=MSWord(docName)
            this.htmlFileDir='';
            this.resourcePath='';
            this.zFile=docName;

            if exist(docName,'file')~=2
                error(message('Slvnv:slreq_import:ImportMissingFile',docName));
            elseif~rmiut.isCompletePath(docName)
                docName=which(docName);
            end
            this.hDoc=rmidotnet.MSWord.activate(docName);
            this.sFile=this.hDoc.FullName.char;
            [~,sName,sExt]=fileparts(this.sFile);
            this.sName=[sName,sExt];
            this.sTempDocPath=[tempname,sExt];
            this.hTempDoc=[];
            this.dTimestamp=0;
        end

        function setMinimized(this,state)
            if state

                this.hDoc.Application.WindowState=Microsoft.Office.Interop.Word.WdWindowState.wdWindowStateMinimize;
            else
                this.hDoc.Application.WindowState=Microsoft.Office.Interop.Word.WdWindowState.wdWindowStateNormal;
            end
        end

        function success=validate(this)


            try
                success=this.refresh();
            catch
                try
                    this.hDoc=rmidotnet.MSWord.activate(this.sFile);
                    success=this.refresh();
                catch
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
            this.hTempDoc=[];
        end

        function updateScratchCopy(this)

            if~this.hDoc.Saved()
                error(message('Slvnv:slreq_import:UseCurrentErrorMsg',this.sFile));
            end

            this.discardScratchCopy();

            copyfile(this.zFile,this.sTempDocPath,'f');
            this.hTempDoc=rmidotnet.MSWord.activate(this.sTempDocPath);

            this.hTempDoc.Application.WindowState=Microsoft.Office.Interop.Word.WdWindowState.wdWindowStateMinimize;
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


        function paragText=getText(this,item)
            if isstruct(item)
                paragIdx=item.parags(1);
            else
                paragIdx=item;
            end
            if ischar(this.sTexts{paragIdx})

                paragText=this.sTexts{paragIdx};
            else

                paragText=this.hDoc.Paragraphs.Item(paragIdx).Range.Text;
                paragText=rmiut.filterChars(paragText.char,true,true);
                this.sTexts{paragIdx}=paragText;
            end
        end




        function label=getLabel(this,paragIdx)
            if ischar(this.sLabels{paragIdx})
                label=this.sLabels{paragIdx};
            else
                paragText=this.getText(paragIdx);
                label=rmidotnet.MSWord.textToSummary(paragText);
                this.sLabels{paragIdx}=label;
            end
        end




        function summary=makeSummary(this,item,isHeading)
            if isstruct(item)

                paragText=this.getText(item);
                if nargin<3
                    doTrim=strcmp(item.type,'parag');
                end
            else

                paragText=item;
                if nargin<3
                    doTrim=true;
                else
                    doTrim=~isHeading;
                end
            end
            if isempty(paragText)
                summary='';
                return;
            end

            if doTrim
                summary=rmidotnet.MSWord.textToSummary(paragText);
            else
                summary=paragText;
            end
        end

        function[paragCount,headerCount,bookmarkCount]=getBasicInfo(this)
            bookmarkCount=this.hDoc.Bookmarks.Count;
            paragCount=length(this.iLevels);
            headerCount=sum(this.iLevels>0);
        end


        isUpToDate=refresh(this);
        [items]=getItems(this,varargin)
        count=highlight(this,items)
        [html,cacheFile]=paragsToHtml(this,label,startP,endP,richText,ignoreOutlineNumbers)
        [html,cacheFile]=preview(this,items)
        highlightInScratch(this,item,color)


        backlinksData=findBacklinks(this)
        bookmarksData=findBookmarks(this,bookmarkId)

    end

    methods(Access='private')

        initPaths(this);

    end


    methods(Access='private',Static=true)

        function hDoc=activate(docPath)
            hDoc=[];
            hApp=rmidotnet.MSWord.application();
            allDocs=hApp.Documents;

            isOneDrive=rmidotnet.isOneDrivePath(docPath);
            shortName=slreq.uri.getShortNameExt(docPath);
            for i=1:allDocs.Count
                oneDoc=allDocs.Item(i);
                docFullName=oneDoc.FullName.char;
                if strcmp(docFullName,docPath)
                    hDoc=oneDoc;
                    break;
                elseif isOneDrive
                    docShortName=slreq.uri.getShortNameExt(docFullName);
                    if strcmp(docShortName,shortName)
                        hDoc=oneDoc;
                        break;
                    end
                end
            end
            if isempty(hDoc)
                if isOneDrive


                    scratchFolder=fullfile(tempdir,'RMI','scratch');
                    copyfile(docPath,scratchFolder,'f');
                    docPath=fullfile(scratchFolder,slreq.uri.getShortNameExt(docPath));
                end
                allDocs.Open(docPath,0,0);
                hDoc=hApp.ActiveDocument;
            end

            hApp.Visible=1;
            if(strcmpi(hApp.WindowState.char,'wdWindowStateMinimize'))
                hApp.WindowState=Microsoft.Office.Interop.Word.WdWindowState();
            end
            hDoc.Activate;
        end

    end


    methods(Static=true)


        result=application(varargin)
        docPath=currentDocPath()
        currentlyOpenDocuments=getOpenDocuments(counter)
        label=textToSummary(text);

        function tf=hasBookmarks(srcDoc)
            docObj=rmidotnet.docUtilObj(srcDoc);
            tf=(docObj.hDoc.Bookmarks.Count>0);
        end

    end




end
