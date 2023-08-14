function tableStr=createForwardTable(reqSetList)























    import slreq.report.internal.rtmx.*
    expandButton="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAhklEQVR42mL8//8/AyUAIICYGCgEAAFEsQEAAUSxAQABxIIu0NTURDBQ6urqGGFsgABiwaagpqYOp+aWliYUPkAAUewFgACi2ACAAGLBKcGCafafP/8wxAACCKcB2BRjAwABRLEXAAKIYgMAAoiFmKjCBwACiJHSzAQQQBR7ASCAKDYAIMAAUtQUow+YsTsAAAAASUVORK5CYII=";
    collapseButton="data:/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAkUlEQVR42mL8//8/AyUAIICYGCgEAAFEsQEAAUSxAQABxIIu0NTURDBQ6urqGGFsgABiwaagpqYOp+aWliYUPkAAEfQCCwt+JQABRHEYAAQQCzE2w9h//vzDUAcQQDgNgCkGacamEQYAAohiLwAEEEED8NkOAgABxEJMVOEDAAHESGlmAgggisMAIIAoNgAgwAC+/BqtC+40NQAAAABJRU5ErkJggg==";

    allTypes=slreq.utils.getAllLinkTypes;



    typeLinkMap=containers.Map('KeyType','double','ValueType','any');


    linkNumStats=containers.Map('KeyType','double','ValueType','any');



    column2SrcUuidMap=containers.Map('KeyType','double','ValueType','char');


    column2SrcDescMap=containers.Map('KeyType','double','ValueType','char');

    column2SrcInfo=containers.Map('KeyType','double','ValueType','any');



    column2SrcArtifactMap=containers.Map('KeyType','double','ValueType','char');



    linksInfo=traverseAllLinkInfo;


















    currentColumn=0;





    rowHeader{1}=createEmptyCell('header',2);
    rowHeader{2}=createTableHeaderCell('',...
    'class','emptysummaryheader');
    rowHeader{3}=createEmptyCell('header',1);
    rowHeader1=strjoin(rowHeader,'\n');
    rowHeader2=strjoin(rowHeader,'\n');

    currentColumn=currentColumn+4;
    srcInfoStruct=struct('type','','srcuuid','','srcdesc','','artifact','');
    allSrcArtifact=linksInfo.linkSet2LinkedItems.keys;
    totalColumns=4;
    visualColumn=4;
    for index=1:length(allSrcArtifact)
        cArtifact=allSrcArtifact{index};
        allItems=linksInfo.linkSet2LinkedItems(cArtifact);
        numofsrcItems=length(allItems);
        colSpanNum=numofsrcItems;

        [~,filename,fileext]=fileparts(cArtifact);

        linktype=allItems(1).domain;



        cellContent=[filename,fileext,'<br>(',linktype,')'];

        collapseStr=createCellStr('img','',...
        'src',collapseButton,...
        'onclick',['expandartifact(this, ''src'', ''',cArtifact,''')'],...
        'class','collapseIcon');

        briefHeader=createTableHeaderCell(...
        [collapseStr,cellContent],...
        'rowspan','2',...
        'belongstosrc',cArtifact,...
        'class','srcartifactbrief',...
        'expandstatus','collapse',...
        'infotype','brief',...
        'srcexptype','collapse',...
        'dstexptype','none');


        currentColumn=currentColumn+1;
        visualColumn=visualColumn+1;
        totalColumns=totalColumns+1;
        srcInfo=srcInfoStruct;
        srcInfo.type='brief';
        srcInfo.artifact=cArtifact;
        column2SrcInfo(visualColumn)=srcInfo;

        cellContent=[filename,fileext,'(',linktype,')'];

        expandStr=createCellStr('img','',...
        'src',expandButton,...
        'onclick',['collapseartifact(this, ''src'', ''',cArtifact,''')'],...
        'class','collapseIcon');

        detailHeader=createTableHeaderCell(...
        [expandStr,cellContent],...
        'colspan',num2str(colSpanNum),...
        'belongstosrc',cArtifact,...
        'class','srcartifactheader',...
        'infotype','details',...
        'srcexptype','expanded',...
        'dstexptype','none');

        spannedCol=currentColumn+1:currentColumn+numofsrcItems;

        artifactInfo=cell(size(spannedCol));
        artifactInfo(:)={cArtifact};

        if length(spannedCol)==1
            cMap=containers.Map({spannedCol},artifactInfo);
        else
            cMap=containers.Map(spannedCol,artifactInfo);
        end


        column2SrcArtifactMap=[column2SrcArtifactMap;cMap];

        rowHeader1=sprintf('%s%s%s',rowHeader1,briefHeader,detailHeader);



        for sIndex=1:length(allItems)


            visualColumn=visualColumn+1;
            cItem=allItems(sIndex);
            if~isa(cItem,'slreq.data.SourceItem')
                disp('??');
            end

            [adapter,artifact,id]=this.linkSrc.getAdapter();
            cItemStr=adapter.getSummaryString(artifact,id);
            cItemUuid=cItem.getUuid;

            linkUrlStr=adapter.getClickActionCommandString(artifact,id,'standalone');


            linkUrl=['matlab:',linkUrlStr];

            cellContent=refineHtmlContent(cItemStr);
            headerContent=createCellStr('a',cellContent,'href',linkUrl);
            srcInfo=srcInfoStruct;
            srcInfo.type='details';
            srcInfo.srcuuid=cItemUuid;
            srcInfo.srcdesc=cItemStr;
            srcInfo.artifact=cArtifact;
            column2SrcInfo(visualColumn)=srcInfo;

            column2SrcUuidMap(visualColumn)=cItemUuid;
            column2SrcDescMap(visualColumn)=cItemStr;
            headerContent=createCellStr(...
            'span',headerContent);
            headerContentWithDiv=createCellStr(...
            'div',headerContent);
            cHeader2=createTableHeaderCell(...
            headerContentWithDiv,...
            'belongstosrc',cArtifact,...
            'idassrc',cItemUuid,...
            'infotype','details',...
            'class','srcartifactitems',...
            'srcexptype','expanded',...
            'dstexptype','none');
            rowHeader2=sprintf('%s%s\n',rowHeader2,cHeader2);
            currentColumn=currentColumn+1;

        end

        totalColumns=totalColumns+numofsrcItems;
    end

    rowStr{1}=createCellStr('tr',rowHeader1);
    rowStr{2}=createCellStr('tr',rowHeader2);




    cHeader=strjoin(rowHeader(1:2),'/n');
    cellContent='stats';
    statsHeader=createTableHeaderCell(cellContent);
    cHeader=sprintf('%s%s',cHeader,statsHeader);

    for index=5:totalColumns
        srcInfo=column2SrcInfo(index);
        switch srcInfo.type
        case 'brief'
            headerContent=createTableHeaderCell('',...
            'belongstosrc',srcInfo.artifact,...
            'infotype','brief',...
            'statstype','srcartifact',...
            'class','stats',...
            'srcexptype','collapse',...
            'dstexptype','none');

        case 'details'
            headerContent=createTableHeaderCell('',...
            'class','stats',...
            'belongstosrc',srcInfo.artifact,...
            'idassrc',srcInfo.srcuuid,...
            'statstype','srcartifactitem',...
            'infotype','details',...
            'srcexptype','expanded',...
            'dstexptype','none');
        end

        cHeader=sprintf('%s%s',cHeader,headerContent);
    end

    rowStr{3}=createCellStr('tr',cHeader);


















































    reqSetList=[linksInfo.allDstArtifact,linksInfo.allDstReqArtifact];
    allDstArtifact={};
    reqData=slreq.data.ReqData.getInstance;
    for rsindex=1:length(reqSetList)


        cReqSet=reqSetList(rsindex);
        [mwReq,exReq]=cReqSet.getItems;
        reqList=[mwReq,exReq];

        numOfReq=length(reqList);
        cArtifact=cReqSet.filepath;
        allDstArtifact{end+1}=cArtifact;
        [~,filename,fileext]=fileparts(cArtifact);


        cellContent=[filename,fileext,'<br>(',num2str(length(reqList)),')'];
        collapseStr=createCellStr('img','',...
        'src',collapseButton,...
        'onclick',['expandartifact(this, ''dst'', ''',cArtifact,''')'],...
        'class','collapseIcon');


        briefrowcolumn{1}=createTableHeaderCell([collapseStr,cellContent],...
        'colspan','3',...
        'belongstodst',cArtifact,...
        'class','dstartifactbrief',...
        'expandstatus','collapse',...
        'infotype','brief',...
        'dstexptype','collapse',...
        'srcexptype','none');

        briefrowcolumn{2}=createTableHeaderCell('',...
        'class','stats',...
        'belongstodst',cArtifact,...
        'statstype','dstartifact',...
        'infotype','brief',...
        'dstexptype','collapse',...
        'srcexptype','none');


        for cindex=5:totalColumns
            srcInfo=column2SrcInfo(cindex);
            switch srcInfo.type
            case 'brief'
                briefrowcolumn{end+1}=createTableHeaderCell('',...
                'class','stats',...
                'belongstosrc',srcInfo.artifact,...
                'belongstodst',cArtifact,...
                'infotype','brief',...
                'statstype','artifact2artifact',...
                'dstexptype','collapse',...
                'srcexptype','collapse');
            case 'details'
                briefrowcolumn{end+1}=createTableHeaderCell('',...
                'class','stats',...
                'belongstosrc',srcInfo.artifact,...
                'belongstodst',cArtifact,...
                'idassrc',srcInfo.srcuuid,...
                'statstype','item2artifact',...
                'infotype','details',...
                'dstexptype','collapse',...
                'srcexptype','expanded');
            end
        end


        rowStr{end+1}=createCellStr(...
        'tr',strjoin(briefrowcolumn,'\n'),...
        'belongstodst',cArtifact,...
        'infotype','brief',...
        'dstexptype','collapse',...
        'srcexptype','none');

        briefrowcolumn={};






        cellContent=[filename,fileext,'(',num2str(length(reqList)),')'];
        expandStr=createCellStr('img','',...
        'src',expandButton,...
        'onclick',['collapseartifact(this, ''dst'', ''',cArtifact,''')'],...
        'class','collapseIcon');
        column{1}=createTableHeaderCell([expandStr,cellContent],...
        'rowspan',num2str(numOfReq),...
        'class','dstartifactdetails',...
        'belongstodst',cArtifact,...
        'infotype','details',...
        'dstexptype','expanded',...
        'srcexptype','none');

        for rindex=1:numOfReq
            fprintf('.');

            cReq=reqList(rindex);
            classLevel=length(strfind(cReq.index,'.'))+1;
            if isempty(cReq.customId)
                cellContent=[cReq.index,'(No ID)'];
            else
                cellContent=[cReq.index,'(',cReq.customId,')'];
            end

            linkUrlStr=slreq.gui.LinkTargetUIProvider.getClickActionCommandString(cReq,'standalone',true);

            linkUrl=['matlab:',linkUrlStr];
            headerContent=createCellStr('a',cellContent,'href',linkUrl);

            if~isempty(cReq.children)
                collapseStr=createCellStr('img','',...
                'src',collapseButton,...
                'onclick','toggle(this)',...
                'class','collapseIcon',...
                'collapsestatus','off');
                headerContent=[collapseStr,headerContent];
            end

            column{2}=createTableHeaderCell(...
            headerContent,...
            'class','dstartifactid',...
            'level',['c',num2str(classLevel)],...
            'belongstodst',cArtifact,...
            'dsttype','id',...
            'idasdst',cReq.getUuid,...
            'infotype','details',...
            'dstexptype','expanded',...
            'srcexptype','none');


            cellContent=cReq.summary;
            column{3}=createTableHeaderCell(cellContent,...
            'class','dstartifactsummary',...
            'belongstodst',cArtifact,...
            'idasdst',cReq.getUuid,...
            'dsttype','summary',...
            'infotype','details',...
            'dstexptype','expanded',...
            'srcexptype','none');


            column{4}=createTableHeaderCell('',...
            'class','stats',...
            'belongstodst',cArtifact,...
            'idasdst',cReq.getUuid,...
            'statstype','dstartifactitem',...
            'infotype','details',...
            'dstexptype','expanded',...
            'srcexptype','none');

            currentColumn=4;
            totalLinks=0;
            cDstUuid=cReq.getUuid;
            for index=currentColumn+1:totalColumns
                srcInfo=column2SrcInfo(index);

                switch srcInfo.type
                case 'brief'
                    column{end+1}=createTableHeaderCell('',...
                    'class','stats',...
                    'belongstodst',cArtifact,...
                    'belongstosrc',srcInfo.artifact,...
                    'idasdst',cReq.getUuid,...
                    'statstype','artifact2item',...
                    'infotype','details',...
                    'dstexptype','expanded',...
                    'srcexptype','collapse');
                case 'details'
                    cSrcUuid=srcInfo.srcuuid;
                    cSrcArti=srcInfo.artifact;
                    linkKey=[cSrcUuid,'->',cDstUuid];

                    if isKey(linksInfo.srcDstToLinkMap,linkKey)
                        linkUuid=linksInfo.srcDstToLinkMap(linkKey);
                        linkInfo=linksInfo.linkMap(linkUuid);
                        desStr=trimStr(linkInfo.description,40);
                        srcStr=trimStr(column2SrcDescMap(index),40);
                        dstStr=trimStr(cReq.summary,40);

                        tooltip=sprintf('Des: %s;<br/>Src: %s;<br/>Dst: %s',desStr,srcStr,dstStr);
                        tooltipstr=createCellStr('span',tooltip,'class','linktooltip');

                        cellContent=[linkInfo.type(1),tooltipstr];
                        linktype=linkInfo.type;
                        filtertype='off';

                        totalLinks=totalLinks+1;
                    else
                        srcInfo=reqData.findObject(cSrcUuid);

                        [srcAdapter,srcArtifact,srcId]=srcInfo.getAdapter();
                        srcStr=srcAdapter.getSummaryString(srcArtifact,srcId);

                        dstInfo=reqData.findObject(cDstUuid);
                        [dstAdapter,dstArtifact,dstId]=dstInfo.getAdapter();
                        dstStr=dstAdapter.getSummaryString(dstArtifact,dstId);

                        hyperlink=createCellStr('a','Create Link',...
                        'href',...
                        ['matlab:slreq.report.internal.rtmx.createLinkDialog(''',cSrcUuid,''', ''',cDstUuid,''')']);

                        tooltip=sprintf('No Links. %s Between %s and %s',hyperlink,srcStr,dstStr);

                        tooltipstr=createCellStr('span',tooltip,'class','linktooltip');

                        cellContent=[' ',tooltipstr];
                        linktype='none';
                        filtertype='na';

                    end

                    column{end+1}=createCellStr(...
                    'td',cellContent,...
                    'class','links',...
                    'linktype',linktype,...
                    'link-imp',num2str(double(strcmp(linktype,'Implement'))),...
                    'link-ver',num2str(double(strcmp(linktype,'Verify'))),...
                    'link-rel',num2str(double(strcmp(linktype,'Relate'))),...
                    'link-der',num2str(double(strcmp(linktype,'Derive'))),...
                    'link-ref',num2str(double(strcmp(linktype,'Refine'))),...
                    'srcid',cSrcUuid,...
                    'dstid',cDstUuid,...
                    'belongstosrc',cSrcArti,...
                    'belongstodst',cArtifact,...
                    'linkstatus','',...
                    'onmouseover','highlightLink(this, true)',...
                    'onmouseleave','highlightLink(this, false)',...
                    'infotype','details',...
                    'dstexptype','expanded',...
                    'srcexptype','expanded',...
                    'filter',filtertype);
                end
            end










            if rindex==1
                rowStr{end+1}=createCellStr(...
                'tr',strjoin(column,'\n'),...
                'belongstodst',cArtifact,...
                'infotype','details',...
                'dstexptype','expanded',...
                'srcexptype','none');
            else
                rowStr{end+1}=createCellStr(...
                'tr',strjoin(column(2:end),'\n'),...
                'belongstodst',cArtifact,...
                'infotype','details',...
                'dstexptype','expanded',...
                'srcexptype','none');
            end
            column={};
        end
    end












    headerRows=createCellStr(...
    'thead',strjoin(rowStr(1:3),'\n'));
    bodyRows=createCellStr(...
    'tbody',strjoin(rowStr(4:end),'\n'));

    columnProperty{1}=createCellStr(...
    'col','',...
    'class','headercol');
    columnProperty{2}=createCellStr(...
    'col','',...
    'class','headercol');
    columnProperty{3}=createCellStr(...
    'col','',...
    'class','headercol');
    columnProperty{4}=createCellStr(...
    'col','',...
    'class','headercol');
    for index=5:totalColumns
        cSrcType=column2SrcInfo(index);

        if strcmp(cSrcType.type,'brief')
            columnProperty{index}=createCellStr(...
            'col','',...
            'class','briefcol');
        else
            columnProperty{index}=createCellStr(...
            'col','',...
            'class','detailcol');
        end
    end

    colGroups=createCellStr(...
    'colgroup',strjoin(columnProperty));


    captionStr=createCellStr('caption','Simulink Requirment Traciability Matrix');
    bodyStr=[captionStr,colGroups,headerRows,bodyRows];



    tableStr=createCellStr('table',bodyStr,'id','forwardTable');







end


function out=createEmptyCell(type,numerofcell)
    import slreq.report.internal.rtmx.*
    out=[];
    switch type
    case 'header'
        for index=1:numerofcell
            cHeader=createTableHeaderCell('',...
            'class','emptyheader');
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
    import slreq.report.internal.rtmx.*
    switch type
    case 'in'
        arrowicon='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAIAAAALu/iQAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAjUlEQVR42mL8//8/AxJgZWX9/fs3AzYAEEBMyJxZs2Yx4AYAAcSErM7Y2BiPUoAAYsFUh2l2dnY20FUAAcSCpu7EiRNo6s6ePQthAAQQC0TT1KlTGQgBgAACKQUaDvQ4RDVQGy6lAAHE8B8GWFhYZs6cCST/4wAAAcQC1wMxG48DAAIIJVxxBT4EAAQYAC4FS47Vh8x2AAAAAElFTkSuQmCC';
    case 'out'
        arrowicon='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAIAAAALu/iQAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAi0lEQVR42mL4jwPMnDkTTQQggJgYcANWVlZkLkAA4VM6depUZNUAAcQCxLNmzcKq1MfHB2L279+/gQyAAGJBFsUExsbGELOBqgECCKp0y5YtDIQAQAAxAr2G5nxktwLJ7OxsiAMAAogBV2CxsLAAwwtIwkUAAghkKp6QgpoHBgABhC+wkNUBAUCAAQBZNW1N172/5QAAAABJRU5ErkJggg==';
    end
    out=createCellStr('img','','src',arrowicon);
end


function outstr=trimStr(instr,numlength)
    if nargin<2
        numlength=30;
    end
    if length(instr)>numlength
        outstr=[instr(1:27),'...'];
    else
        outstr=instr;
    end
end

function out=createCheckBoxlist(artifactList,srcOrDst)
    import slreq.report.internal.rtmx.*
    switch srcOrDst
    case 'src'
        filterStr='filter sources';
        argStr='src';
        changeCallBack='filterArtifacts(this, ''src'')';
        onclickCallBack='showSrcCheckBox()';
        selectionListID='sourcelist';
    case 'dst'
        filterStr='filter destination';
        argStr='dst';
        changeCallBack='filterArtifacts(this, ''dst'')';
        onclickCallBack='showDstCheckBox()';
        selectionListID='destinationlist';
    end
    checkListStr=[];
    for index=1:length(artifactList)
        cArtifact=artifactList{index};

        checkBoxStr=createCellStr('input','',...
        [argStr,'id'],cArtifact,...
        'type','checkbox',...
        'checked','checked',...
        'onchange',changeCallBack);
        labelStr=createCellStr('label',[checkBoxStr,cArtifact],...
        'for',cArtifact);
        checkListStr=[checkListStr,labelStr];
    end

    checkBoxDiv=createCellStr('div',checkListStr,...
    'id',selectionListID);

    selectionMenu=createCellStr('option',filterStr);
    selectionMenu=createCellStr('select',selectionMenu);
    selectionMenu2=createCellStr('div','','class','overselect');
    selectionMenu=createCellStr('div',[selectionMenu,selectionMenu2],...
    'class','selectBox',...
    'onclick',onclickCallBack);

    multiselectionAllStr=createCellStr('div',[selectionMenu,checkBoxDiv],...
    'class','mutilselect');

    out=createCellStr('form',multiselectionAllStr);
end