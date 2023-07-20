

classdef WordUtil<handle

    properties(SetAccess=private)

hApp
hDoc
sName
sFullName

sTimestamp
hBookmarks
iLevels
iParents
iStarts
iEnds
sContents
sLabels

    end


    methods


        function docData=WordUtil(docName)
            docData.hApp=rmiref.WordUtil.getApplication(false);
            if nargin<1||isempty(docName)
                docData.hDoc=docData.hApp.ActiveDocument;
            else
                docData.hDoc=rmiref.WordUtil.activateDocument(docName);
            end
            docData.sName=docData.hDoc.Name;
            docData.sFullName=docData.hDoc.FullName;
            docData.sTimestamp=0;
            docData.validate();
        end


        function text=getText(this,idx)
            if this.iLevels(idx)==0
                text='';
            else
                text=this.sContents{idx};
                if isempty(text)
                    parags=this.hDoc.Paragraphs;
                    text=parags.Item(idx).Range.Text;
                    if isempty(text)
                        this.iLevels(idx)=0;
                    else
                        this.sContents{idx}=text;
                    end
                end
            end
        end
        function label=getLabel(this,idx)
            if this.iLevels(idx)==0
                label='';
            else
                label=this.sLabels{idx};
                if isempty(label)
                    text=this.getText(idx);
                    if isempty(text)
                        label='';
                    else
                        if length(text)>100
                            text=[text(1:100),'...'];
                        end

                        parag=this.hDoc.Paragraphs.Item(idx);
                        numStr=parag.Range.ListFormat.ListString;
                        if~isempty(numStr)
                            label=[numStr,' ',text];
                        else
                            label=text;
                        end
                    end
                    this.sLabels{idx}=label;
                end
            end
        end

        function idx=getParagraphIdx(this,range)
            allParagraphsBefore=find(this.iStarts<=range.Start);
            if~isempty(allParagraphsBefore)
                idx=allParagraphsBefore(end);
            else
                idx=[];
            end
        end

        function[targetFilePath,html]=getSectionContents(this,idx)
            doc=this.sFullName;
            fnameSuffix=sprintf('p%d',idx);
            targetFilePath=rmiref.WordUtil.getCacheFilePath(doc,fnameSuffix);
            if rmiref.WordUtil.isUpToDate(targetFilePath,doc)
                resultsFile=targetFilePath;
            else
                targetRange=this.hDoc.Range;
                targetRange.Start=this.iStarts(idx);
                targetRange.End=this.iEnds(idx);
                myRange=this.expandRange(targetRange,0);
                resultsFile=rmiref.WordUtil.rangeToHtml(myRange,targetFilePath,this);
            end
            if~isempty(resultsFile)&&exist(resultsFile,'file')==2
                html=rmi.Informer.htmlFileToString(resultsFile);
            else
                error('rmiref.WordUtil.getbookmarkedItems(): failed to gextract item %s',fnameSuffix);
            end
        end

        function[targetFilePath,html]=getContentForBookmark(this,hBookmark)
            doc=this.sFullName;
            targetFilePath=rmiref.WordUtil.getCacheFilePath(doc,hBookmark.Name);
            if rmiref.WordUtil.isUpToDate(targetFilePath,doc)
                resultsFile=targetFilePath;
            else
                hRange=hBookmark.Range;
                myRange=this.expandRange(hRange,0);
                resultsFile=rmiref.WordUtil.rangeToHtml(myRange,targetFilePath,this);
            end
            if~isempty(resultsFile)&&exist(resultsFile,'file')==2
                html=rmi.Informer.htmlFileToString(resultsFile);
            else
                error('rmiref.WordUtil.getbookmarkedItems(): failed to gextract item %s',hBookmark.Name);
            end
        end


        function range=expandRange(this,range,preferredSize)
            [paragIdx,paragRange]=this.rangeToParag(range);

            range.Start=paragRange(1);
            range.End=paragRange(2);

            if preferredSize>0&&range.End-range.Start>=preferredSize
                return;
            end

            childParags=this.getChildren(paragIdx(end));
            if~isempty(childParags)


                range.End=this.iEnds(childParags(end));
                return;
            end

            if range.Tables.Count==1
                myTable=range.Tables.Item(1);
                range.Start=myTable.Range.Start;
                if myTable.Range.End>range.End
                    range.End=myTable.Range.End;
                end
            end


            if preferredSize>0&&range.End-range.Start<preferredSize
                parentParagIdx=this.getParent(paragIdx(1));
                if parentParagIdx>1&&this.iStarts(parentParagIdx)>100










                    origStart=range.Start;
                    origBookmarkCount=range.Bookmarks.Count;
                    range.Start=this.iStarts(parentParagIdx);
                    if range.Bookmarks.Count>origBookmarkCount

                        range.Start=origStart;
                    end
                end
            end
        end


        function[paragIdx,paragRange]=rangeToParag(this,rangeObj)
            startsBefore=find(this.iStarts<=rangeObj.Start);
            myStart=startsBefore(end);
            endsAfter=find(this.iEnds>=rangeObj.End);
            myEnd=endsAfter(1);
            paragIdx=[myStart,myEnd];
            paragRange=[this.iStarts(myStart),this.iEnds(myEnd)];
        end


        function[parentIdx,parentText]=getParent(this,idx)
            this.validate();
            parentIdx=this.iParents(idx);
            if parentIdx>0
                parentText=this.getText(parentIdx);
            else
                parentText='';
            end
        end

        function[childIds,childTexts]=getChildren(this,idx)
            this.validate();
            childIds=find(this.iParents==idx);
            childTexts=cell(size(childIds));
            for i=1:length(childIds)
                childTexts{i}=this.getText(childIds(i));
            end
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


                this.hApp=rmiref.WordUtil.getApplication(false);
                this.hDoc=rmiref.WordUtil.activateDocument(this.sFullName);
                this.populateDocData(true);
            end
        end

        function resave(this)

            this.hDoc.Save();
            this.updateTimestamp();
        end


        function reload(this)
            this.populateDocData(false);
        end
        function printHierarchy(this)
            this.loadContents();
            topItems=find(this.iLevels==1);
            for i=1:length(topItems)
                printItems(this,topItems(i),0);
            end
            function printItems(this,idx,offset)
                offsets=repmat('..',1,offset);
                fprintf(1,[offsets,' %s\n'],rmiut.filterChars(this.sLabels{idx},false,false));
                childIdx=find(this.iParents==idx&this.iLevels~=0);
                for j=1:length(childIdx)
                    printItems(this,childIdx(j),offset+1);
                end
            end
        end
        function loadContents(this)
            for i=1:length(this.iLevels)
                if this.iLevels(i)==0
                    continue;
                else
                    this.getLabel(i);
                end
            end
        end
    end


    methods(Access='private')

        function populateDocData(this,showProgress)

            if showProgress
                parentCallHasProgressBar=~rmiut.progressBarFcn('isCanceled');
                rmiut.progressBarFcn('set',0);
                this.loadHierarchy([0,0.9]);
                rmiut.progressBarFcn('set',1);
                if~parentCallHasProgressBar
                    rmiut.progressBarFcn('delete');
                end
            else
                disp(['Querying document structure for ',this.sName,' ...']);
                this.loadHierarchy([]);
            end


            this.sContents=cell(size(this.iLevels));
            this.sLabels=cell(size(this.iLevels));


            this.hBookmarks=this.hDoc.Bookmarks;




            this.updateTimestamp();
        end

        function saved=promptToSave(this)
            reply=questdlg({...
            getString(message('Slvnv:rmi:informer:HasUnsavedChanges',this.sName)),...
            getString(message('Slvnv:rmi:informer:SaveNowQ'))},...
            getString(message('Slvnv:rmi:informer:DocumentModified')),...
            getString(message('Slvnv:rmiml:Yes')),...
            getString(message('Slvnv:rmiml:No')),...
            getString(message('Slvnv:rmiml:Yes')));
            if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmiml:Yes')))
                this.hDoc.Save();
                saved=true;
            else
                saved=false;
            end
        end

        function updateTimestamp(this)
            fData=dir(this.sFullName);
            this.sTimestamp=fData.date;
        end

        loadHierarchy(this,statusBarData);
    end



    methods(Static=true)


        app=getApplication(use_current);
        [currentDocName,hApp,hDoc]=getCurrentDoc();
        hDoc=activateDocument(doc);


        [docTxt,bookMarkId]=findBookmark(shapeRange);
        findNamedItem(hApp,thisDoc,namedItem);
        found=searchBookmarks(comDocument,namedItem);
        [found,aborted]=searchHeadings(hApp,comDocument,namedItem);
        selectRange(hApp,hDoc,location);


        [docitem,button,idx]=findActxObject(doc,item);
        insertActxButton(thisDoc,thisSelection,actxId,bitmap,navcmd,dispstr);
        insertHyperlink(thisDoc,thisSelection,bitmap,url,dispstr);


        [html,cacheFilePath]=itemToHtml(doc,itemId);
        varargout=appState(method,varargin);
        yesno=isUpToDate(htmlFilePath,doc);
        fPath=getCacheFilePath(doc,bookmarkId);


        docUtil=docUtilObj(docPath);
        resultsFile=rangeToHtml(range,targetFilePath,utilObj);
        value=getDocProperty(file,propTag);
        contents=getBookmarkedItems(filename,varargin);
        contents=getSection(filename,paragIdx);
        contents=getItemsByLevel(filename,level);
        contents=getItemsByPattern(filename,pattern);
        contents=getItem(filename,idx);
        sections=getDocStructure(filename);
        parents=getParents(filename,paragIdx);
        contents=getContentByParagIdx(doc,cacheLabel,paragIdx)

    end

end
