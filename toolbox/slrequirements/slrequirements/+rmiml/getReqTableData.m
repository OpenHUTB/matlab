function table=getReqTableData(srcKey)





    table={};

    allIdsAndLabels=mleditor.getAll(srcKey,false);
    if isempty(allIdsAndLabels)
        return;
    end
    totalBookmarks=size(allIdsAndLabels,1);
    skip=false(totalBookmarks,1);
    for i=1:totalBookmarks
        skip(i)=~any(allIdsAndLabels{i,5});
    end
    if any(skip)
        allIdsAndLabels(skip,:)=[];
        if isempty(allIdsAndLabels)
            return;
        end
        totalBookmarks=size(allIdsAndLabels,1);
    end









    [sortedStarts,index]=sort(cell2mat(allIdsAndLabels(:,2)));
    sortedEnds=allIdsAndLabels(index,3);
    sortedIDs=allIdsAndLabels(index,1);
    table=cell(totalBookmarks,4);
    fullText=rmiml.getText(srcKey);
    crPositions=find(fullText==10);
    for i=1:totalBookmarks
        table{i,1}=sortedIDs{i};
        table{i,2}=[sortedStarts(i),sortedEnds{i}];
        bookmarkText=rmiml.getText(srcKey,table{i,2});
        [table{i,3},table{i,4}]=prependLineNumbers(bookmarkText,sum(crPositions<sortedStarts(i)));
    end
end

function[contentWithLineNumbers,lineRange]=prependLineNumbers(content,numLinesBefore)
    contentWithLineNumbers='';
    lines=strsplit(content,'\n');
    lineRange=[numLinesBefore+1,numLinesBefore+length(lines)];
    maxNumberLength=length(sprintf('%d',lineRange(2)));
    fixedWidthFormat=['%s%',num2str(maxNumberLength),'d\t%s\n'];
    for i=1:length(lines)
        contentWithLineNumbers=sprintf(fixedWidthFormat,contentWithLineNumbers,numLinesBefore+i,lines{i});
    end
end
