function isUpToDate=refresh(this)

    if~rmidotnet.confirmSaved(this.hDoc)
        isUpToDate=false;
        return;
    end

    if this.matchTimestamp()
        isUpToDate=true;
        return;
    end

    hParagraphs=this.hDoc.Paragraphs;
    totalParagraphs=hParagraphs.Count;

    parentCallHasProgressBar=~rmiut.progressBarFcn('isCanceled');
    displayProgress(0,totalParagraphs,this.sName);


    this.iStarts=zeros(totalParagraphs,1);
    this.iEnds=zeros(totalParagraphs,1);
    this.sLabels=cell(totalParagraphs,1);
    this.sLabelPrefixes=cell(totalParagraphs,1);
    this.iLevels=zeros(totalParagraphs,1);
    this.iParents=zeros(totalParagraphs,1);
    this.sTexts=cell(totalParagraphs,1);

    findParentIdx(0,0);

    hItem=hParagraphs.First;

    aborted=false;
    paragIdx=1;




    while~isempty(hItem)


        hRange=hItem.Range;


        this.sLabelPrefixes{paragIdx}=hRange.ListFormat.ListString.char;
        this.iStarts(paragIdx)=hRange.Start;
        this.iEnds(paragIdx)=hRange.End;
        this.iLevels(paragIdx)=getHeaderLevel(hItem);
        this.iParents(paragIdx)=findParentIdx(paragIdx,this.iLevels(paragIdx));








        if this.iEnds(paragIdx)-this.iStarts(paragIdx)<=1
            this.sTexts{paragIdx}='';
        else
            this.sTexts{paragIdx}=rmiut.filterChars(hRange.Text.char,true,true);
        end

        if displayProgress(paragIdx,totalParagraphs,this.sName)
            aborted=true;
            break;
        end

        hItem=hItem.Next;
        paragIdx=paragIdx+1;
    end

    if~parentCallHasProgressBar
        rmiut.progressBarFcn('delete');
    end

    if aborted
        isUpToDate=false;
        this.dTimestamp=0;
    else
        this.dTimestamp=this.getDocTime();
        this.bookmarks=[];
        this.backlinks=[];
        isUpToDate=true;
    end
end

function level=getHeaderLevel(paragraph)


    level=paragraph.OutlineLevel.int32;
    if level==10

        level=-1;
    end
end

function interrupted=displayProgress(i,total,sName)
    interrupted=false;
    if mod(i,33)==0
        fractionDone=double(i)/double(total);
        rmiut.progressBarFcn('set',fractionDone,['Processing ',sName,'...']);
    end
    if mod(i,7)==0&&rmiut.progressBarFcn('isCanceled')
        interrupted=true;
    end
end

function parentIdx=findParentIdx(idx,level)
    persistent parentsList levelsList
    if level==0

        levelsList=0;
        parentsList=-1;
    end
    if level<1

        parentIdx=parentsList(end);
    else

        isParent=(levelsList<level);
        if any(~isParent)
            levelsList(~isParent)=[];
            parentsList(~isParent)=[];
        end
        parentIdx=parentsList(end);
        levelsList(end+1)=level;
        parentsList(end+1)=idx;
    end
end
