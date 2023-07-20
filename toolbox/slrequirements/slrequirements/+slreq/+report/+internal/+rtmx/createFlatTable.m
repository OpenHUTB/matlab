function tableStr=createFlatTable(reqSetList)
    import slreq.report.internal.rtmx.*


    allTypes=slreq.utils.getAllLinkTypes;



    typeLinkMap=containers.Map('KeyType','double','ValueType','any');


    linkNumStats=containers.Map('KeyType','double','ValueType','any');







    cHeader=createEmptyCell('header',3);
    currentColumn=2;
    for index=1:length(allTypes)
        currentColumn=currentColumn+2;
        cType=allTypes(index);
        cellContent=cType.typeName;
        cHeader1=createTableHeaderCell(cellContent,'colspan','2');
        typeLinkMap(currentColumn)=cType;
        cHeader=sprintf('%s%s\n',cHeader,cHeader1);

    end

    totalColumns=currentColumn;
    rowStr{1}=createCellStr('tr',cHeader);



    cHeader=createEmptyCell('header',3);

    for index=3:2:totalColumns
        cellContent=getLinkDirIcon('in');
        cHeader1=createTableHeaderCell(cellContent);

        cellContent=getLinkDirIcon('out');
        cHeader2=createTableHeaderCell(cellContent);
        cHeader=sprintf('%s%s\n%s\n',cHeader,cHeader1,cHeader2);
    end

    rowStr{2}=createCellStr('tr',cHeader);




    rowStr{3}='';








    reqList=[];
    for rsindex=1:length(reqSetList)
        [mwReq,exReq]=reqSetList(rsindex).getItems;
        reqList=[reqList,mwReq,exReq];
    end


    for rindex=1:length(reqList)


        cReq=reqList(rindex);
        classLevel=length(strfind(cReq.index,'.'))+1;
        if isempty(cReq.customId)
            cellContent=[cReq.index,'(No ID)'];
        else
            cellContent=[cReq.index,'(',cReq.customId,')'];
        end
        column{1}=createTableHeaderCell(cellContent,'class','colheader','level',['c',num2str(classLevel)]);


        cellContent=cReq.summary;
        column{2}=createTableHeaderCell(cellContent,'class','colheader');


        column{3}='';


        currentColumn=3;
        totalLinks=0;
        for index=currentColumn+1:2:totalColumns
            thisLinkType=typeLinkMap(index);
            if isa(cReq,'slreq.data.Requirement')
                [inLinks,outLinks]=cReq.getLinks(thisLinkType.typeName);
            elseif isa(reqItem,'slreq.data.SourceItem')
                [outLinks,inLinks]=cReq.getLinks(thisLinkType.typeName);
            end
            nInLinks=numel(inLinks);
            nOutLinks=numel(outLinks);

            cellContent=num2str(nInLinks);
            column{end+1}=createCellStr('td',cellContent);

            cellContent=num2str(nOutLinks);
            column{end+1}=createCellStr('td',cellContent);
            totalLinks=totalLinks+nInLinks+nOutLinks;

            if isKey(linkNumStats,index)
                linkNumStats(index)=linkNumStats(index)+[nInLinks,nOutLinks];
            else
                linkNumStats(index)=[nInLinks,nOutLinks];
            end
        end
        cellContent=num2str(totalLinks);
        column{3}=createTableHeaderCell(cellContent,'class','totalLinks');
        rowStr{end+1}=createCellStr('tr',strjoin(column,'\n'));
        column={};
    end




    cHeader=createEmptyCell('header',3);

    for index=4:2:totalColumns
        allNum=linkNumStats(index);
        cHeader1=createTableHeaderCell(num2str(allNum(1)));
        cHeader2=createTableHeaderCell(num2str(allNum(2)));
        cHeader=sprintf('%s%s\n%s\n',cHeader,cHeader1,cHeader2);
    end

    rowStr{3}=cHeader;


    bodyStr=strjoin(rowStr,'\n');



    tableStr=createCellStr('table',bodyStr,'id','flatTable');

end


function out=createEmptyCell(type,numerofcell)
    out=[];
    switch type
    case 'header'
        for index=1:numerofcell
            cHeader=createTableHeaderCell('');
            out=sprintf('%s%s\n',out,cHeader);
        end
    case 'body'
        for index=1:numerofcell
            cHeader=createCellStr('td','');
            out=sprintf('%s%s\n',out,cHeader);
        end
    end
end

function out=getLinkDirIcon(type)
    switch type
    case 'in'
        arrowicon='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAIAAAALu/iQAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAjUlEQVR42mL8//8/AxJgZWX9/fs3AzYAEEBMyJxZs2Yx4AYAAcSErM7Y2BiPUoAAYsFUh2l2dnY20FUAAcSCpu7EiRNo6s6ePQthAAQQC0TT1KlTGQgBgAACKQUaDvQ4RDVQGy6lAAHE8B8GWFhYZs6cCST/4wAAAcQC1wMxG48DAAIIJVxxBT4EAAQYAC4FS47Vh8x2AAAAAElFTkSuQmCC';
    case 'out'
        arrowicon='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAIAAAALu/iQAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAi0lEQVR42mL4jwPMnDkTTQQggJgYcANWVlZkLkAA4VM6depUZNUAAcQCxLNmzcKq1MfHB2L279+/gQyAAGJBFsUExsbGELOBqgECCKp0y5YtDIQAQAAxAr2G5nxktwLJ7OxsiAMAAogBV2CxsLAAwwtIwkUAAghkKp6QgpoHBgABhC+wkNUBAUCAAQBZNW1N172/5QAAAABJRU5ErkJggg==';
    end
    out=createCellStr('img','','src',arrowicon);
end
