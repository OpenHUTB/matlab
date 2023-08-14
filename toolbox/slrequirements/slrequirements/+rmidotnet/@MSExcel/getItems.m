function items=getItems(this,varargin)













    items=[];
    count=0;

    if isstruct(varargin{1})
        options=varargin{1};
    else
        options=parseArgs(varargin);
    end

    calledForSheetNumber=this.iSheet;
    if~this.validate()

        return;
    end
    this.iSheet=calledForSheetNumber;



    this.selectSheet();


    if isfield(options,'rows')
        firstRow=options.rows(1);
        lastRow=options.rows(end);
    else
        firstRow=1;
        lastRow=this.iLastRow;
    end


    if~isfield(options,'usdm')
        options.usdm=false;
    end

    showProgress=rmiut.progressBarFcn('exists');

    this.cacheTextContents(firstRow,lastRow,showProgress);








    doBookmarks=isfield(options,'bookmarks')&&options.bookmarks;


    doMatch=false;
    if isfield(options,'match')&&~isempty(options.match)
        if strcmp(options.match,'NAMES')



            doBookmarks=true;
        else
            doMatch=true;
        end
    end


    includedRows=false(0,1);

    if doBookmarks


        this.cacheNamedRangesInfo(showProgress);

        for i=1:length(this.namedRanges)
            item.type='bookmark';
            item.label=this.namedRanges(i).label;
            item.address=this.namedRanges(i).address;
            item.range=this.namedRanges(i).range;


            addItem();


            includedRows(item.address(1):item.address(1)+item.range(1)-1)=true;
        end

        if isempty(items)&&~doMatch
            rmiut.warnNoBacktrace('Slvnv:slreq:NoNamedRanges',options.subDoc);
        end
    end


    matchCount=0;


    [summaryColumn,keywordsColumn,descriptionColumn,rationaleColumn,attributeColumn,createdByColumn,modifiedByColumn]=...
    getMappedColumnOptions(options);



    if~isempty(attributeColumn)&&isfield(options,'headers')
        headers=options.headers(ismember(options.columns,attributeColumn));
    else
        headers={};
    end


    this.iParents=[];



    mainTableColumnRightEdge=5;

    if doMatch
        if showProgress
            rmiut.progressBarFcn('set',0.4,getString(message('Slvnv:slreq_import:ProcessingMatchesIn',this.sName)));
        end

        for row=firstRow:lastRow
            [matchedCol,text]=findPattern(row,options.match);
            if~isempty(matchedCol)
                matchCount=matchCount+1;
                match=regexp(text,['(',options.match,')'],'tokens');
                item.type='match';
                item.label=match{1}{1};
                lastFilled=findLastFilled(row,matchedCol);
                item.range=[1,lastFilled-matchedCol+1];
                item.address=[row,matchedCol];

                if options.usdm&&matchCount==1



                    mainTableColumnRightEdge=findMainTableRightColumn(item.address);
                end


                if~isempty(summaryColumn)&&summaryColumn>matchedCol
                    item.summary=this.getTextFromCell(row,summaryColumn);
                else
                    item.summary=[];
                end


                if options.usdm
                    usableColumns=keywordsColumn(keywordsColumn>mainTableColumnRightEdge);
                else
                    usableColumns=keywordsColumn(keywordsColumn>matchedCol);
                end
                if~isempty(usableColumns)
                    item.keywords=collectKeywords(this,row,usableColumns);
                else
                    item.keywords=[];
                end



                if~isempty(createdByColumn)
                    item.createdBy=this.getTextFromCell(row,createdByColumn);
                end
                if~isempty(modifiedByColumn)
                    item.modifiedBy=this.getTextFromCell(row,modifiedByColumn);
                end




                if~options.usdm

                    usableDescription=descriptionColumn(descriptionColumn>matchedCol);
                    if~isempty(usableDescription)
                        item.drange=[usableDescription(1),usableDescription(end)];
                        if isempty(item.summary)
                            item.summary=descriptionToSummary(this,row,usableDescription(1),true);
                        end
                    else
                        item.drange=[];
                    end

                    usableRationale=rationaleColumn(rationaleColumn>matchedCol);
                    if~isempty(usableRationale)
                        item.rrange=[usableRationale(1),usableRationale(end)];
                    else
                        item.rrange=[];
                    end
                end


                if~isempty(attributeColumn)
                    if options.usdm
                        isSuitableColumn=(attributeColumn>mainTableColumnRightEdge);
                        usableColumns=attributeColumn(isSuitableColumn);
                        usableHeaders=headers(isSuitableColumn);
                    else
                        usableColumns=attributeColumn;
                        usableHeaders=headers;
                    end
                    [item.attrNames,item.attrValues]=collectAttributeValues(this,row,usableColumns,usableHeaders);
                end


                addItem();
                includedRows(row)=true;
            end
        end

        if matchCount==0
            rmiut.warnNoBacktrace('Slvnv:slreq:NoMatches',options.match,options.subDoc);
            return;
        end

        if oneRowItems(items)||options.usdm||matchCount>10




            this.iParents=getParentsByMatchedLabel(items,this.iParents,options.match);





            averageItemSize=(items(end).address(1)-items(1).address(1))/matchCount;


            for i=1:matchCount

                if i<matchCount
                    numRowsForThisItem=items(i+1).address(1)-items(i).address(1);
                elseif options.usdm
                    numRowsForThisItem=lastRow-items(i).address(1)+1;
                else
                    numRowsForThisItem=averageItemSize;
                end

                if options.usdm



                    lastRowForThisItem=min(items(i).address(1)+numRowsForThisItem-1,lastRow);
                    [summaryRange,items(i).drange,items(i).rrange]=...
                    this.usdmGetPropRangesForItem(items(i).address,lastRowForThisItem,mainTableColumnRightEdge);%#ok<AGROW>
                    if isempty(items(i).summary)
                        items(i).summary=descriptionToSummary(this,items(i).address(1),summaryRange(1),false);%#ok<AGROW>
                    end

                else



                    row=items(i).address(1)+1;
                    while row<items(i).address(1)+numRowsForThisItem
                        if row>lastRow
                            break;
                        end
                        if row>items(i).address(1)+averageItemSize+1
                            break;
                        end
                        firstFilled=findFirstFilled(row,items(i).address(2));
                        if firstFilled<0
                            break;
                        end
                        lastFilled=findLastFilled(row,firstFilled);
                        if lastFilled<=firstFilled
                            break;
                        end

                        items(i).range(1)=row-items(i).address(1)+1;%#ok<AGROW>
                        row=row+1;
                    end
                end
            end
        end

    elseif isfield(options,'columns')

        if isempty(options.columns)
            error('MSExcel.getItems() called without match pattern or columns list');
        end

        if showProgress
            rmiut.progressBarFcn('set',0.25,getString(message('Slvnv:slreq_import:ProcessingRowsIn',this.sName)));
        end


        if isfield(options,'idColumn')
            idColumn=options.idColumn;
            if ischar(idColumn)
                ascii=double(idColumn);
                if any(ascii<double('A'))||any(ascii>double('Z'))
                    error(message('Slvnv:reqmgt:linktype_rmi_excel:InvalidValueForColumnID',idColumn));
                else
                    idColumn=rmiut.xlsColNameToNum(idColumn);
                end
            end
        else
            idColumn=[];
        end



        for row=firstRow:lastRow

            if showProgress&&mod(row,25)==0
                if rmiut.progressBarFcn('isCanceled')
                    break;
                end
                fraction=0.25+0.75*double(row)/double(lastRow);
                rmiut.progressBarFcn('set',fraction,getString(message('Slvnv:slreq_import:ProcessingRowsIn',this.sName)));
            end

            if row<=length(includedRows)&&includedRows(row)
                continue;
            end

            goodColumn=findFirstFilled(row,options.columns(1));
            if goodColumn<1
                continue;
            end


            item.address=[row,options.columns(1)];
            item.range=[1,options.columns(end)-options.columns(1)+1];


            if~isempty(idColumn)
                idText=this.getTextFromCell(row,idColumn);

                if isempty(idText)
                    continue;
                end
                item.label=idText;
                item.id=idText;
                item.type='id';
            else
                item.type='row';
                item.label=sprintf('%s%d',rmiut.xlsColNumToName(item.address(2)),row);
                if~isempty(this.namedRanges)

                    name=rmidotnet.MSExcel.findNameInRange(this.namedRanges,item);
                    if~isempty(name)
                        item.label=name;

                        item.type='bookmark';
                    end
                end
            end

            if~isempty(summaryColumn)
                item.summary=this.getTextFromCell(row,summaryColumn);
            else
                item.summary=[];
            end

            if~isempty(keywordsColumn)
                item.keywords=collectKeywords(this,row,keywordsColumn);
            else
                item.keywords=[];
            end

            if~isempty(createdByColumn)
                item.createdBy=this.getTextFromCell(row,createdByColumn);
            end
            if~isempty(modifiedByColumn)
                item.modifiedBy=this.getTextFromCell(row,modifiedByColumn);
            end

            if~isempty(descriptionColumn)
                item.drange=[descriptionColumn(1),descriptionColumn(end)];
                if isempty(item.summary)
                    item.summary=descriptionToSummary(this,row,descriptionColumn(1),true);
                end
            else
                item.drange=[];
            end

            if~isempty(rationaleColumn)
                item.rrange=[rationaleColumn(1),rationaleColumn(end)];
            else
                item.rrange=[];
            end

            if~isempty(attributeColumn)

                [item.attrNames,item.attrValues]=collectAttributeValues(this,row,attributeColumn,headers);
            end

            addItem();
        end
    end







    function tf=oneRowItems(entries)

        totalEntries=numel(entries);
        if totalEntries<3
            tf=false;
            return;
        end
        prevRow=entries(1).address(1);
        for j=2:totalEntries
            if j>10
                break;
            end
            nextRow=entries(j).address(1);
            if nextRow==prevRow+1
                prevRow=nextRow;
            else
                tf=false;
                return;
            end
        end
        tf=true;
    end

    function[range,text]=findPattern(row,pattern)
        range=[];
        text='';
        myRow=this.cachedText(row,:);
        if iscell(myRow)
            lastCol=length(myRow);
        else
            lastCol=this.iLastCol;
        end
        countEmpty=0;
        for col=1:lastCol
            oneCellText=myRow{col};
            if isempty(oneCellText)
                countEmpty=countEmpty+1;
                if countEmpty>3
                    return;
                end
            else
                countEmpty=0;
                if~isempty(regexp(oneCellText,pattern,'once'))
                    range=col;
                    text=oneCellText;
                    break;
                end
            end
        end
    end

    function nonEmpty=findLastFilled(row,startCol)
        colIdx=startCol;
        nonEmpty=startCol;
        maxAllowEmpty=4;
        allowEmpty=maxAllowEmpty;
        myRow=this.cachedText(row,:);
        while allowEmpty>0&&colIdx<this.iLastCol
            colIdx=colIdx+1;
            oneCellText=myRow{colIdx};
            if isempty(oneCellText)
                allowEmpty=allowEmpty-1;
            else
                nonEmpty=colIdx;
                allowEmpty=maxAllowEmpty;
            end
        end
    end

    function nonEmpty=findFirstFilled(row,startCol)
        colIdx=startCol;
        myRow=this.cachedText(row,:);
        while colIdx<=this.iLastCol


            if~isempty(regexp(myRow{colIdx},'\w','once'))
                nonEmpty=colIdx;
                return;
            end
            colIdx=colIdx+1;
        end
        nonEmpty=-1;
    end

    function addItem()
        count=count+1;
        if count==1
            items=item;
        else
            items(count)=item;
        end
    end

    function mainTableRightColumn=findMainTableRightColumn(topMatchCellAddress)
        mainTableRightColumn=5;
        previousRow=topMatchCellAddress(1)-1;
        if previousRow>0
            mainTableRightColumn=findRightColumnOfMergedRangeInRow(previousRow);
        end
        if isempty(mainTableRightColumn)&&isfield(options,'attributeColoumn')

            mainTableRightColumn=min(options.attributeColumn)-1;
        end
    end

    function rightColumnOfMergedRange=findRightColumnOfMergedRangeInRow(row)
        rightColumnOfMergedRange=[];
        nonEmptyHeaderIdx=find(~strcmp(this.cachedText(1,:),''));
        lastNonEmpty=nonEmptyHeaderIdx(end);
        tempItem.range=[1,1];
        tempItem.type='match';
        for ii=3:lastNonEmpty
            tempItem.address=[row,ii];
            hRange=this.itemToRange(tempItem,'first');
            mergeArea=hRange.MergeArea;
            if mergeArea.Columns.Count>1

                rightColumnOfMergedRange=mergeArea.Column+mergeArea.Columns.Count-1;
                return;
            end
        end
    end
end



function parents=getParentsByMatchedLabel(items,parents,pattern)
    patternSep=getPatternSep(pattern);
    if isempty(patternSep)


        parents=findParentsByPrefix(items,parents);
    else
        parents=findParentsByIds(items,parents,patternSep);
    end
end

function patternSep=getPatternSep(pattern)
    patternSep='';

    insideBracket=regexp(pattern,'\[([^\]]+)\]','tokens');
    if isempty(insideBracket)
        return;
    end
    noEscape=strrep(insideBracket{1}{1},'\','');
    hasUnderscore=any(noEscape=='_');
    possibleSeparators=regexprep(noEscape,'\w','');
    if hasUnderscore
        possibleSeparators=['_',possibleSeparators];
    end
    if isempty(possibleSeparators)
        return;
    elseif length(possibleSeparators)==1
        patternSep=possibleSeparators;
    else

        patternSep=possibleSeparators(end);
    end
end

function parents=findParentsByIds(items,parents,patternSep)
    knownParents=containers.Map('KeyType','char','ValueType','double');
    for i=1:numel(items)
        item=items(i);
        label=item.label;
        knownParents(label)=item.address(1);
        sepIdx=find(label==patternSep);
        if isempty(sepIdx)
            continue;
        end
        beforeSep=label(1:sepIdx(end)-1);
        if isKey(knownParents,beforeSep)
            parents(item.address(1))=knownParents(beforeSep);

        end
    end
end

function parents=findParentsByPrefix(items,parents)
    processedMatches=cell(0,2);
    for i=1:length(items)
        item=items(i);
        if strcmp(item.type,'match')
            parentIdx=findParentByPrefix(processedMatches(:,1),item.label);
            if~isempty(parentIdx)
                parents(item.address(1))=processedMatches{parentIdx,2};
            end
            processedMatches(end+1,:)={item.label,item.address(1)};%#ok<AGROW>
        end
    end
end

function parentIdx=findParentByPrefix(previousLabels,label)
    parentIdx=[];
    for i=length(previousLabels):-1:1
        prevID=strtok(previousLabels{i});
        if startsWith(label,prevID)
            parentIdx=i;
            break;
        end
    end
end


function options=parseArgs(args)
    for i=1:2:length(args)
        option=args{i};
        value=args{i+1};
        if any(strcmp(option,{'columns','rows','headers','summaryColumn','idColumn',...
            'descriptionColumn','rationaleColumn','keywordsColumn','attributeColumn'}))
            options.(option)=value;
        else
            error('MSExcel.getItems(): invlid option "%s"',option);
        end
    end
end


function[summaryColumn,keywordsColumn,descriptionColumn,rationaleColumn,attributeColumn,createdByColumn,modifiedByColumn]=...
    getMappedColumnOptions(options)
    if isfield(options,'summaryColumn')&&~isempty(options.summaryColumn)
        summaryColumn=options.summaryColumn;
    else
        summaryColumn=[];
    end
    if isfield(options,'keywordsColumn')
        keywordsColumn=options.keywordsColumn;
    else
        keywordsColumn=[];
    end
    if isfield(options,'descriptionColumn')
        descriptionColumn=options.descriptionColumn;
    else
        descriptionColumn=[];
    end
    if isfield(options,'rationaleColumn')
        rationaleColumn=options.rationaleColumn;
    else
        rationaleColumn=[];
    end
    if isfield(options,'attributeColumn')&&~isempty(options.attributeColumn)
        attributeColumn=options.attributeColumn;
    else
        attributeColumn=[];
    end
    if isfield(options,'createdByColumn')
        createdByColumn=options.createdByColumn;
    else
        createdByColumn=[];
    end
    if isfield(options,'modifiedByColumn')
        modifiedByColumn=options.modifiedByColumn;
    else
        modifiedByColumn=[];
    end
end


function keywordsStr=collectKeywords(utilObj,row,keywordsColumn)
    keywordsStr='';
    for i=1:length(keywordsColumn)
        oneKeyword=utilObj.getTextFromCell(row,keywordsColumn(i));
        if~isempty(oneKeyword)
            keywordsStr=[keywordsStr,',',oneKeyword];%#ok<AGROW>
        end
    end
    if~isempty(keywordsStr)
        keywordsStr=keywordsStr(2:end);
    end
end


function summary=descriptionToSummary(utilObj,row,descriptionColumn,doTrim)
    textForSummary=utilObj.getTextFromCell(row,descriptionColumn);
    TRIM_LENGTH=80;
    if doTrim&&length(textForSummary)>TRIM_LENGTH




        firstLine=regexp(textForSummary,'^\s*([^\n]+)','tokens');
        if~isempty(firstLine)
            textForSummary=firstLine{1}{1};
        else
            textForSummary=[textForSummary(1:TRIM_LENGTH),'...'];
        end
    end
    summary=rmiut.filterChars(textForSummary,false);
end


function[attrNames,attrValues]=collectAttributeValues(utilObj,row,attributeColumn,headers)
    attrNames=cell(size(attributeColumn));
    attrValues=cell(size(attributeColumn));
    for i=1:length(attributeColumn)
        column=attributeColumn(i);
        attrNames{i}=headers{i};
        attrValues{i}=utilObj.getTextFromCell(row,column);
    end
end



