function linktype=linktype_rmi_word

    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;
    linktype.Label=getString(message('Slvnv:reqmgt:linktype_rmi_word:MicrosoftWord'));


    linktype.IsFile=1;
    linktype.Extensions={'.doc','.rtf','.docx','.docm'};


    linktype.LocDelimiters='?@#';
    linktype.Version='';

    linktype.NavigateFcn=@NavigateFcn;
    linktype.ContentsFcn=@ContentsFcn;
    linktype.AtExitFcn=@AtExitFcn;
    linktype.IsValidIdFcn=@IsValidIdFcn;
    linktype.IsValidDescFcn=@IsValidDescFcn;
    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;
    linktype.DetailsFcn=@DetailsFcn;
    linktype.ResolveDocFcn=@ResolveDocFcn;
    linktype.DocDateFcn=@DocDateFcn;
    linktype.HtmlViewFcn=@HtmlViewFcn;


    linktype.SelectionLinkLabel=getString(message('Slvnv:rmisl:menus_rmi_object:LinkToSelectionInWord'));
    linktype.SelectionLinkFcn=@SelectionLinkFcn;


    linktype.BacklinkCheckFcn=@BacklinkCheckFcn;
    linktype.BacklinkInsertFcn=@BacklinkInsertFcn;
    linktype.BacklinkDeleteFcn=@BacklinkDeleteFcn;
    linktype.BacklinksCleanupFcn=@BacklinksCleanupFcn;

end

function NavigateFcn(filename,locationStr)
    if~ispc
        errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_word:WordNotSupportedOnUnix')),getString(message('Slvnv:reqmgt:linktype_rmi_word:RequirementsError')),'modal');
        return;
    end
    [hWord,hDoc]=openWordDoc(filename,false);
    navigateToId(hWord,hDoc,locationStr);


    [~,fName,fExt]=fileparts(filename);
    reqmgt('winFocus',['^',fName,fExt]);
end

function[labels,depths,locations]=ContentsFcn(filePath)

    labels={};
    depths=[];
    locations={};

    try
        rmiut.progressBarFcn('set',0,...
        getString(message('Slvnv:reqmgt:linktype_rmi_word:ProcessingContent')),...
        getString(message('Slvnv:rmiut:progressBar:GettingDocInfo')));



        closeWordApp=~rmicom.wordApp('exists');
        hWord=rmicom.wordApp();
        comDocument=rmicom.wordApp('finddoc',filePath);
        if isempty(comDocument)
            closeWordDoc=true;
            comDocument=com_open_doc(hWord,filePath);
        else
            closeWordDoc=false;
        end

        if~rmiut.progressBarFcn('isCanceled')


            allBookMarkText=com_all_bookmark_text(comDocument,1/6,1/3);


            try
                [hLabels,hIDs,hLevels]=com_find_headings(comDocument,1/2,1/2);
            catch Mex
                warning(message('Slvnv:reqmgt:linktype_rmi_word:GenerateIndexFailed',filePath,Mex.message));
                hIDs={};
            end


            labels={['================= ',getString(message('Slvnv:reqmgt:linktype_rmi_word:OutlineHeadings')),'=====================']};
            depths=0;
            locations={''};

            if isempty(hIDs)
                labels=[labels;{getString(message('Slvnv:reqmgt:linktype_rmi_word:HasNoOutlineHeadings',filePath))}];
                depths=[depths;0];
                locations=[locations;{''}];
            else
                labels=[labels;hLabels'];
                depths=[depths;hLevels'];
                locations=[locations;strcat('@',hIDs')];
            end

            labels=[labels;{['================= ',getString(message('Slvnv:reqmgt:linktype_rmi_word:Bookmarks')),' =========================']}];
            depths=[depths;0];
            locations=[locations;{''}];
            if isempty(allBookMarkText)
                labels=[labels;{sprintf('%s',getString(message('Slvnv:reqmgt:linktype_rmi_word:HasNoBookmarks',filePath)))}];
                depths=[depths;0];
                locations=[locations;{''}];
            else
                labels=[labels;allBookMarkText'];
                depths=[depths;zeros(length(allBookMarkText),1)];
                locations=[locations;strcat('@',allBookMarkText')];
            end

            if closeWordDoc
                comDocument.Close(0);
            end

        end

        if closeWordApp
            hWord.Quit;
        end
        rmiut.progressBarFcn('delete');

    catch Mex1
        try
            if closeWordApp
                hWord.Quit;
            end
            rmiut.progressBarFcn('delete');
        catch Mex2 %#ok<NASGU>
        end
        warning(message('Slvnv:reqmgt:linktype_rmi_word:GenerateDocumentIndexFailed',Mex1.message));
    end
end

function AtExitFcn

end

function success=IsValidIdFcn(filename,locationStr)
    if~ispc
        error(message('Slvnv:reqmgt:linktype_rmi_word:WordNotSupportedOnUnix'));
    end

    [hWord,hDoc]=openWordDoc(filename,true);

    try
        navigateToId(hWord,hDoc,locationStr)
        success=true;
    catch Mex %#ok<NASGU>
        success=false;
    end
end

function[success,new_description]=IsValidDescFcn(filename,locationStr,currDesc)




    currDesc=strrep(currDesc,'',' ');
    currDesc=strtrim(currDesc);

    [hWord,hDoc]=openWordDoc(filename,true);
    if is_bookmark(locationStr)
        navigateToId(hWord,hDoc,locationStr)
        new_desc=make_label_from_selection(hDoc);
        if strcmp(currDesc,new_desc)
            success=true;
            new_description='';
        else
            success=false;
            new_description=new_desc;
        end
    else
        success=true;
        new_description='';
    end
end

function[docPath,isRel]=ResolveDocFcn(doc,refSrc)
    isRel=false;


    if rmisl.isDocBlockPath(doc)
        docPath=doc;
    else

        docPath=rmisl.locateFile(doc,refSrc);
        if~isempty(docPath)&&~strcmp(docPath,doc)
            isRel=true;
        end
    end
end

function docDate=DocDateFcn(doc)


    if rmisl.isDocBlockPath(doc)

        mdlName=strtok(doc,':');
        try
            load_system(mdlName);
        catch ex %#ok<NASGU>
            docDate=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:SystemNotFound'));
            return;
        end
        try
            modelTimestamp=get_param(mdlName,'LastModifiedDate');

            modelDatetime=datetime(modelTimestamp,'InputFormat','eee MMM dd HH:mm:ss yyyy','Locale','en_US');


            docDate=datestr(modelDatetime,'yyyy-mm-dd HH:MM:SS');
        catch

            docDate=modelTimestamp;
        end
    else
        fileinfo=dir(doc);
        if isempty(fileinfo)
            docDate=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
        else
            docDate=datestr(fileinfo.datenum,'yyyy-mm-dd HH:MM:SS');
        end
    end

end

function url=CreateURLFcn(docPath,refSrc,locationStr)
    if rmisl.isDocBlockPath(docPath)
        dot=strfind(docPath,'.');
        sid=docPath(1:dot-1);
        model=strtok(sid,':');
        command=sprintf('rmi.navigate(''other'',''%s'',''%s'',''%s'');',docPath,locationStr,model);
        url=['matlab:',command];
    else

        docPath=strrep(docPath,'/',filesep);
        docPath=rmi.locateFile(docPath,refSrc);
        if isempty(docPath)
            url='';
        else
            url=rmiut.filepathToUrl(docPath);
            if contains(url,'file://')&&~isempty(locationStr)&&locationStr(1)=='@'
                url=[url,'#',locationStr(2:end)];
            end
        end
    end

end

function label=UrlLabelFcn(doc,docLabel,location)
    if~isempty(docLabel)
        doc=docLabel;
    else
        doc=RptgenRMI.shortPath(doc);
    end
    if length(location)>1
        label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',...
        doc,location(2:end)));
    else
        label=doc;
    end
end






function[depths,items]=DetailsFcn(document,itemId,detailsLevel)



    if nargin>2&&detailsLevel==0
        depths=[];
        items={};
        return
    end


    if isempty(itemId)||length(itemId)<2
        depths=0;
        items={getString(message('Slvnv:reqmgt:linktype_rmi_word:LocationNotEntered'))};
        return
    end

    try
        [hWord,hDoc]=openWordDoc(document,true);
    catch Mex
        depths=0;
        items={getString(message('Slvnv:reqmgt:linktype_rmi_word:ERRORGettingDetailsFromWord',Mex.message))};
        return;
    end
    switch(itemId(1))
    case '@'
        label=itemId(2:end);

        if hDoc.Bookmarks.Exists(label)
            bookmark=hDoc.Bookmarks.Item(label);
            parags=parags_in_range(hDoc,bookmark.Range);
        else
            parags=find_matching_header(hWord,hDoc,label);
        end

        if~isempty(parags)
            if length(parags)==1



                parag=parags(1);
                myLevel=get_header_level(parag);

                if myLevel<0
                    depths=-1;
                    items={strtrim(parag.Range.Text)};

                    previous=parag.Previous;
                    if isempty(previous)
                        depths=[0,depths];
                        items=[{getString(message('Slvnv:reqmgt:linktype_rmi_word:LinksToTheTop'))},items];
                    else

                        header=get_previous_header(parag);
                        if isempty(header)








                            [depths,items]=get_content_below(depths,items,parag);
                        else
                            if length(header)>100
                                header=[header(1:60),'...'];
                            end
                            depths=[0,depths];
                            items=[{getString(message('Slvnv:reqmgt:linktype_rmi_word:LinksToParagraphUnder',header))},items];
                        end
                    end

                else
                    depths=myLevel;
                    items={strtrim(parag.Range.Text)};

                    next=parag.Next;
                    if isempty(next)
                        depths=[myLevel-1,myLevel];
                        items=[{getString(message('Slvnv:reqmgt:linktype_rmi_word:NearEnd'))},items];
                    else
                        nextLevel=get_header_level(next);
                        if nextLevel<0||nextLevel>myLevel
                            [depths,items]=append_child_parags(depths,items,next,myLevel+1,detailsLevel);
                        else
                            header=get_previous_header(parag);
                            if isempty(header)
                                header=getString(message('Slvnv:reqmgt:linktype_rmi_word:LinksToFollowingParagraph'));
                            else
                                if length(header)>100
                                    header=[header(1:60),'...'];
                                end
                                header=getString(message('Slvnv:reqmgt:linktype_rmi_word:LinksToParagraphUnder',header));
                            end
                            depths=[myLevel-1,myLevel];
                            items={header,strtrim(parag.Range.Text)};
                        end
                    end
                end

            else

                top=parags(1);
                next=parags(2);
                topLevel=get_header_level(top);
                nextLevel=get_header_level(next);
                if topLevel>0&&(nextLevel<0||nextLevel>topLevel)
                    [depths,items]=append_all_parags([],{},parags);
                else
                    header=get_previous_header(top);
                    depths=0;
                    if isempty(header)
                        items{1}=getString(message('Slvnv:reqmgt:linktype_rmi_word:LinksToMultipleParagraphs'));
                    else
                        if length(header)>100
                            header=[header(1:60),'...'];
                        end
                        items{1}=getString(message('Slvnv:reqmgt:linktype_rmi_word:LinksToMultipleParagraphsUnder',header));
                    end
                    [depths,items]=append_all_parags(depths,items,parags);
                end
            end
        else
            depths=0;
            items={getString(message('Slvnv:reqmgt:linktype_rmi_word:LocationIDNotFound',itemId))};
        end
    case '#'
        depths=0;
        items={getString(message('Slvnv:reqmgt:linktype_rmi_word:DetailsNoSupportPage'))};
    case '?'
        depths=0;
        items={getString(message('Slvnv:reqmgt:linktype_rmi_word:DetailsNoSupportSearch'))};
    otherwise
        depths=0;
        items={getString(message('Slvnv:reqmgt:linktype_rmi_word:UnsupportedLocationIdentifier',itemId))};
    end

    nextLevel=max(depths)+1;
    depths(depths<0)=nextLevel;

    depths=depths-min(depths);

    depths=depths(:);
    items=items(:);
end



function[depths,items]=append_all_parags(depths,items,parags)
    my_depths=[];
    my_items={};
    for i=1:length(parags)
        parag=parags(i);
        text=strtrim(parag.Range.Text);
        my_depths(end+1)=get_header_level(parag);%#ok<*AGROW>
        my_items{end+1}=text;
    end
    [my_depths,my_items]=find_tables(my_depths,my_items,parags);
    if~isempty(my_depths)
        depths=[depths,my_depths];
        items=[items,my_items];
    end
end

function[depths,items]=append_child_parags(depths,items,parag,targetLevel,detailsLevel)%#ok<INUSD>

    thisLevel=get_header_level(parag);
    my_depths=[];
    my_items={};
    my_parags=[];
    while true
        if thisLevel>0&&thisLevel<targetLevel
            break;















        end

        my_depths=[my_depths,thisLevel];
        my_items=[my_items,{strtrim(parag.Range.Text)}];
        my_parags=[my_parags,parag];

        parag=parag.Next;
        if isempty(parag)
            break;
        else
            thisLevel=get_header_level(parag);
        end
    end
    if~isempty(my_parags)
        [my_depths,my_items]=find_tables(my_depths,my_items,my_parags);
    end
    if~isempty(my_depths)
        depths=[depths,my_depths];
        items=[items,my_items];
    end
end

function parags=parags_in_range(hDoc,hRange)
    parags=[];
    paragraphs=hDoc.Paragraphs;
    for counter=1:paragraphs.Count
        range=paragraphs.Item(counter).Range;
        if range.End<=hRange.Start||range.Start>=hRange.End
            continue;
        end
        parags=[parags,paragraphs.Item(counter)];
    end
end

function header=get_previous_header(parag)
    header='';
    myLevel=get_header_level(parag);
    parag=parag.Previous;
    while~isempty(parag)
        level=get_header_level(parag);
        if level>=0&&(myLevel<0||level<myLevel)
            header=strtrim(parag.Range.Text);
            break;
        end
        parag=parag.Previous;
    end
end

function comDocument=com_open_doc(hWord,filePath)
    comDocs=hWord.Documents;
    comDocument=comDocs.Open(filePath,[],0);
end

function allBookMarkText=com_all_bookmark_text(comWordDoc,progressStart,progressSpan)
    bmCollection=comWordDoc.Bookmarks;
    count=bmCollection.Count;
    lastIdx=count;
    allBookMarkText={};

    rmiut.progressBarFcn('set',progressStart,getString(message('Slvnv:reqmgt:linktype_rmi_word:ProcessingBookmarks')));
    for idx=1:lastIdx
        bmark=find_bookmark(bmCollection,idx,false);
        bmLabel=bmark.Name;
        allBookMarkText{end+1}=bmLabel;
        if~rem(idx,30)
            rmiut.progressBarFcn('set',progressStart+(idx/lastIdx)*progressSpan,...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:ProcessingBookmarks')));
        end
        if rmiut.progressBarFcn('isCanceled')
            break;
        end
    end
end

function[dispLabels,idLabels,levels,isProcessed]=com_find_headings(comDocument,progressStart,progressSpan)

    maxParagraphs=150000;
    maxHeaders=15000;


    prevViewMode='';
    if~strcmp(comDocument.ActiveWindow.View.Type,'wdPrintView')
        prevViewMode=comDocument.ActiveWindow.View.Type;
        comDocument.ActiveWindow.View.Type='wdPrintView';
    end

    comParagraphs=comDocument.Paragraphs;
    paraCnt=comParagraphs.Count;

    blockSize=min([5000,paraCnt]);
    dispLabels=cell(1,blockSize);
    idLabels=cell(1,blockSize);
    levels=zeros(1,blockSize);
    headIdx=0;

    if comParagraphs.Count>maxParagraphs
        errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_word:FileIsTooBigManuallyEnter')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_word:RequirementsError')),'non-modal');
        isProcessed=false;
    else
        for i=1:paraCnt
            comParagraph=comParagraphs.Item(i);
            level=get_header_level(comParagraph);

            if level>=0
                label=rmiut.filterChars(comParagraph.Range.Text,false);
                if~isempty(label)&&label(end)=='/'


                    label=regexprep(label,'/+$','');
                end
                if~isempty(prevViewMode)&&strcmp(prevViewMode,'wdMasterView')
                    comParagraph.Range.Select;
                end
                numStr=comParagraph.Range.ListFormat.ListString;
                if~isempty(numStr)
                    numStr=[numStr,' '];
                elseif isempty(label)
                    continue;
                end


                headIdx=headIdx+1;
                if headIdx>length(idLabels)
                    idLabels=[idLabels,cell(1,blockSize)];
                    dispLabels=[dispLabels,cell(1,blockSize)];
                    levels=[levels,zeros(1,blockSize)];
                end
                idLabels{headIdx}=label;
                dispLabels{headIdx}=[numStr,label];
                levels(headIdx)=level;

                if headIdx==maxHeaders
                    warndlg(getString(message('Slvnv:reqmgt:linktype_rmi_word:TooManyHeadersOnlyFirstNDisplayed',maxHeaders)),...
                    getString(message('Slvnv:reqmgt:linktype_rmi_word:GeneratingDocumentIndex')));
                    break;
                end

            end
            if rmiut.progressBarFcn('isCanceled')
                break;
            end

            if~rem(i,30)
                rmiut.progressBarFcn('set',progressStart+(i/paraCnt)*progressSpan,...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:GeneratingDocumentIndex')));
            end
        end
        isProcessed=true;
    end

    if~isempty(prevViewMode)
        if strcmp(prevViewMode,'wdMasterView')
            comDocument.ActiveWindow.Selection.Collapse(0);
        end
        comDocument.ActiveWindow.View.Type=prevViewMode;
    end


    idLabels=idLabels(1:headIdx);
    dispLabels=dispLabels(1:headIdx);
    levels=levels(1:headIdx);
end






function[hWord,myDoc]=openWordDoc(filename,check)
    if check



        word_state=rmi.mdlAdvState('word');
        if word_state==0
            hWord=rmicom.wordRpt('init');
        elseif word_state==1
            hWord=rmicom.wordRpt('get');
        else
            error(message('Slvnv:reqmgt:linktype_rmi_word:ExternalSessionDetected'));
        end
    else
        hWord=rmicom.wordApp();
    end

    if~hWord.Visible
        hWord.Visible=1;
    end


    myDoc=rmicom.wordApp('dispdoc',filename);
    rmicom.wordApp('clearselection');
end



function navigateToId(hWord,hDoc,locationStr)
    if~isempty(locationStr)
        switch(locationStr(1))
        case '#'
            pageNum=str2double(locationStr(2:end));
            range=hDoc.GoTo(1,1,pageNum);
            range.Select;
            findId=0;

        case '@'
            findNamedItem(hWord,hDoc,locationStr(2:end))
            findId=0;

        case '?'
            locationStr=locationStr(2:end);
            findId=1;

        otherwise
            findId=1;
        end

        if findId==1
            if hDoc.ReadOnly&&str2double(hWord.Version)>=15
                readOnlyNoHighlightPopup(hDoc.Name);

            else
                if str2double(hWord.Version)>=15



                    if~strcmp(hWord.ActiveWindow.View.Type,'wdPrintView')
                        hWord.ActiveWindow.View.Type='wdPrintView';
                    end
                end

                hWord.Selection.Start=1;
                hWord.Selection.End=hWord.Selection.Start;
                hWord.Selection.HomeKey;

                hWord.Selection.Find.Text=locationStr;
                success=hWord.Selection.Find.Execute;
                if~success




                    sectionNumberMatch=regexp(locationStr,'^[\d\.\-]+\s+(.+)$','tokens');
                    if~isempty(sectionNumberMatch)
                        hWord.Selection.Find.Text=sectionNumberMatch{1}{1};
                        hWord.Selection.Find.Execute;
                    end
                end
            end
        end
    end
end

function readOnlyNoHighlightPopup(docName)
    msgText=getString(message('Slvnv:reqmgt:linktype_rmi_word:ReadOnlyDocumentSearch',docName));
    msgTitle=getString(message('Slvnv:rmi:navigate:NavigationError'));
    errordlg(msgText,msgTitle,'modal');
end



function label=make_label_from_selection(hDoc)
    sel=hDoc.ActiveWindow.Selection;
    if(sel.Start==sel.End)
        selectionStr='';
    else
        selectionStr=sel.Text;
    end

    label=rmiut.filterChars(selectionStr,false);
end

function result=is_bookmark(locationStr)
    result=(~isempty(locationStr))&&(locationStr(1)=='@');
end

function findNamedItem(hWord,thisDoc,namedItem)
    found=search_bookmarks(thisDoc,namedItem);
    if~found



        aborted=false;
        if~strncmp(namedItem,'Simulink_requirement_item_',length('Simulink_requirement_item_'))

            if~(thisDoc.ReadOnly&&str2double(hWord.Version)>=15)
                [found,aborted]=search_headings(hWord,thisDoc,namedItem);
            end
        end
        if~found&&~aborted
            error(message('Slvnv:reqmgt:linktype_rmi_word:NamedItem',namedItem));
        end
    end
end

function bestMatch=find_bookmark(Bookmarks,item,doSelect)
    if reqmgt('rmiFeature','UseDotNet')
        bestMatch=Bookmarks.Item(item);
    else
        bestMatch=Bookmarks.invoke('Item',item);
    end
    if doSelect
        bestMatch.Select;
    end
end

function found=search_bookmarks(comDocument,namedItem)
    if comDocument.Bookmarks.Exists(namedItem)
        comDocument.Bookmarks.Item(namedItem).Select;
        found=true;
    else
        found=false;
    end
end

function[found,aborted]=search_headings(hWord,comDocument,namedItem)

    maxIteration=1000;
    prevViewMode='';
    if~strcmp(comDocument.ActiveWindow.View.Type,'wdPrintView')
        prevViewMode=comDocument.ActiveWindow.View.Type;
        comDocument.ActiveWindow.View.Type='wdPrintView';
    end

    aborted=false;
    found=false;


    hWord.Selection.Start=1;
    hWord.Selection.End=1;


    hWord.Selection.Find.Text=namedItem;
    if(~hWord.Selection.Find.Execute)
        return;
    end

    comParagraph=hWord.Selection.Paragraphs.Item(1);

    idx=1;
    hDiag=[];
    while true
        drawnow;
        if(idx==maxIteration)
            hDiag=msgbox(getString(message('Slvnv:reqmgt:linktype_rmi_word:Abort')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:SearchingHeadersWait')));
        end
        if(idx>maxIteration&&(isempty(hDiag)||~ishandle(hDiag)))
            if ishandle(hDiag)
                delete(hDiag);
            end
            aborted=true;
            break;
        end

        level=get_header_level(comParagraph);

        if level>=0
            comParagraph.Range.Select;
            if(ishandle(hDiag))
                delete(hDiag);
            end
            found=true;
            break;
        end

        if(~hWord.Selection.Find.Execute)
            if(ishandle(hDiag))
                delete(hDiag);
            end
            break;
        end

        comParagraph=hWord.Selection.Paragraphs.Item(1);
        idx=idx+1;
    end

    if~isempty(prevViewMode)
        comDocument.ActiveWindow.View.Type=prevViewMode;
    end
end

function parag=find_matching_header(word,doc,header)



    parag=[];
    best_level=-1;
    doc.Activate;
    word.Selection.Find.Text=header;
    if word.Selection.Find.Execute
        matched_parag=word.Selection.Paragraphs.Item(1);
        max_matches=10;
        count=0;
        while count<max_matches&&~isempty(matched_parag)
            level=get_header_level(matched_parag);
            if level>=0&&(best_level<0||best_level>level)
                best_level=level;
                parag=matched_parag;
            end
            if word.Selection.Find.Execute
                matched_parag=word.Selection.Paragraphs.Item(1);
            else
                break
            end
            count=count+1;
        end
    end
end

function level=get_header_level(paragraph)
    outlineLevel=paragraph.OutlineLevel;
    if strcmp(outlineLevel,'wdOutlineLevelBodyText')
        level=-1;
    else
        level=sscanf(outlineLevel,'wdOutlineLevel%d');
    end
end

function[depths,items]=get_content_below(depths,items,parag)
    my_font_size=get_font_size(parag.Range);
    my_depths=[];
    my_items={};
    if my_font_size<1000
        next_parag=parag.Next;
        my_parags=[];
        while~isempty(next_parag)
            next_font_size=get_font_size(next_parag.Range);
            if next_font_size<my_font_size
                my_depths(end+1)=depths(end)+my_font_size-next_font_size;
                my_items=[my_items,{strtrim(next_parag.Range.Text)}];
                my_parags=[my_parags,next_parag];
            else
                break;
            end
            next_parag=next_parag.Next;
        end
    end
    if~isempty(my_parags)
        [my_depths,my_items]=find_tables(my_depths,my_items,my_parags);
    end
    if~isempty(my_depths)
        depths=[depths,my_depths];
        items=[items,my_items];
    end
end

function[depths,items]=find_tables(depths,items,parags)




    allRange=parags(1).Range;
    allRange.End=parags(end).Range.End;
    rangeSize=allRange.End-allRange.Start;
    tables=allRange.Tables;
    totalTables=tables.Count;
    if totalTables==0
        return;
    end

    tableStarts=zeros(totalTables,1);
    tableEnds=zeros(totalTables,1);
    for i=1:totalTables
        thisTableRange=tables.Item(i).Range;
        tableStarts(i)=thisTableRange.Start;
        tableEnds(i)=thisTableRange.End;


        if tableStarts(i)<allRange.Start-2*rangeSize
            tableEnds(i)=tableStarts(i);
        elseif tableEnds(i)>allRange.End+2*rangeSize
            tableStarts(i)=tableEnds(i);
        end
    end
    tableForPar=zeros(length(parags),1);
    for i=1:length(parags)
        parStart=parags(i).Range.Start;
        parEnd=parags(i).Range.End;
        parIsInTable=(tableStarts<=parStart)&(tableEnds>=parEnd);
        if any(parIsInTable)
            tableForPar(i)=find(parIsInTable);
        end
    end
    collapseItems=false(length(parags),1);
    for i=1:totalTables
        thisTable=find(tableForPar==i);
        if isempty(thisTable)
            continue;
        end
        myTable=tables.Item(i);
        numRows=myTable.Rows.Count;
        numCols=myTable.Columns.Count;

        tableArray=cell(numRows,numCols);
        for currRow=1:numRows
            myRow=myTable.Rows.Item(currRow);
            myCount=myRow.Cells.Count;
            for currCol=1:min(numCols,myCount)
                myCellText='';
                myParags=myRow.Cells.Item(currCol).Range.Paragraphs;
                for currParag=1:myParags.Count
                    myParagText=rmiut.filterChars(myParags.Item(currParag).Range.Text,false);
                    if~isempty(myParagText)
                        myCellText=[myCellText,myParagText,' '];
                    end
                end
                tableArray{currRow,currCol}=myCellText;
            end
        end

        items{thisTable(1)}=tableArray;

        collapseItems(thisTable(2:end))=true;
    end

    if any(collapseItems)
        items(collapseItems)=[];
        depths(collapseItems)=[];
    end
end


function font_size=get_font_size(range)
    font_size=range.Font.Size;
    if font_size>1000
        words=range.Words;
        if words.Count>0
            font_size=words.Item(1).Font.Size;
        end
    end
    font_size=floor(font_size);
end


function reqstruct=SelectionLinkFcn(objH,make2way)
    reqstruct=[];


    if~isempty(objH)
        srcFolderPath=rmiut.srcToPath(objH);
        if isempty(srcFolderPath)
            errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_word:ModelMustBeSavedPriorToLinks')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:LinkingError')));
            return;
        end
    end


    thisDoc=get_active_doc();
    if isempty(thisDoc)
        return;
    end


    if reqmgt('rmiFeature','UseDotNet')
        docPath=thisDoc.FullName.char;
    else
        docPath=thisDoc.FullName;
    end
    [fpath,~,fext]=fileparts(docPath);
    if isempty(fpath)
        errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_word:DocMustBeSavedPriorToLinks')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_word:LinkingError')));
        return;
    end

    if isempty(objH)&&~make2way



        reqstruct=rmi('createempty');
        reqstruct.reqsys='linktype_rmi_word';
        reqstruct.doc=docPath;
        selectionStr=getSelectedText(thisDoc);
        if~isempty(selectionStr)
            reqstruct.id=['?',selectionStr];
        end
        return;
    end




    is_docblock=false;
    if strcmp(fext,'.rtf')
        blkH=docblock('filename2blockhandle',docPath);
        if~isempty(blkH)
            SID=Simulink.ID.getSID(blkH);
            docPath=[SID,'.rtf'];
            is_docblock=true;
        end
    end


    selectionStr=getSelectedText(thisDoc);




    trailing=count_whitespace_tail(selectionStr);
    if trailing>0
        thisDoc.ActiveWindow.Selection.MoveEnd(1,-trailing);
    end
    leading=count_whitespace_head(selectionStr);
    if leading>0
        thisDoc.ActiveWindow.Selection.MoveStart(1,leading);
    end


    selectionStr=rmiut.filterChars(selectionStr,false);

    if isempty(selectionStr)




        if~thisDoc.Parent.Visible
            thisDoc.Parent.Visible=1;
        end
        if(strcmpi(thisDoc.Parent.WindowState,'wdWindowStateMinimize'))
            thisDoc.Parent.WindowState='wdWindowStateNormal';
        end
        thisDoc.Parent.Activate;
        thisDoc.Activate;

        errmsg={getString(message('Slvnv:reqmgt:linktype_rmi_word:NoTextIsSelected_more')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_word:TheCurrentDocIs',docPath)),...
        getString(message('Slvnv:reqmgt:linktype_rmi_word:PleaseSelectText'))};
        errordlg(errmsg,getString(message('Slvnv:reqmgt:linktype_rmi_word:NoTextIsSelected')));
        return;
    end


    bookmarkCount=thisDoc.ActiveWindow.Selection.Bookmarks.Count;
    if bookmarkCount==0
        bookmarkStr='';
    else
        bmark=get_best_bookmark(thisDoc.ActiveWindow.Selection.Bookmarks);
        bookmarkStr=bmark.Name;
        if reqmgt('rmiFeature','UseDotNet')
            bookmarkStr=bookmarkStr.char;
        end
    end

    function bestMatch=get_best_bookmark(Bookmarks)
        best=1;


        bestStart=Bookmarks.Item(1).Start;
        for i=2:Bookmarks.Count
            if Bookmarks.Item(i).Start>bestStart
                best=i;
                bestStart=Bookmarks.Item(i).Start;
            end
        end
        bestMatch=find_bookmark(Bookmarks,best,true);
    end


    if isempty(bookmarkStr)

        if thisDoc.ReadOnly
            errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_word:ReadOnlyDocument',thisDoc.Name)),...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:LinkingError')));
            return;
        else
            bookmarkStr=next_bookmark_str(thisDoc);
            thisDoc.ActiveWindow.Selection.Bookmarks.Add(bookmarkStr);
        end
    end


    pastPaths=rmi.settings_mgr('get','wordSelHist');
    pastIdx=find(strcmp(pastPaths,docPath));
    if isempty(pastIdx)
        pastPaths=[{docPath},pastPaths];
        rmi.settings_mgr('set','wordSelHist',pastPaths);
    elseif pastIdx(1)>1
        pastPaths(pastIdx)=[];
        pastPaths=[{docPath},pastPaths];
        rmi.settings_mgr('set','wordSelHist',pastPaths);
    end


    reqstruct=rmi('createempty');
    reqstruct.reqsys='linktype_rmi_word';
    reqstruct.linked=true;
    reqstruct.doc=docPath;
    reqstruct.description=selectionStr;
    reqstruct.id=['@',bookmarkStr];
    tag=rmi.settings_mgr('get','selectTag');
    if~isempty(tag)
        reqstruct.keywords=tag;
    end

    if make2way

        srcType=rmiut.resolveType(objH);


        if strcmp(srcType,'simulink')&&~ischar(objH)
            [source,canceled]=rmi.canlink2way(objH);
            if canceled||length(source)<length(objH)
                reqstruct=[];
                return;
            end
        end

        linkSettings=rmi.settings_mgr('get','linkSettings');


        [navcmd,dispstr,bitmap]=rmiut.targetInfo(objH,srcType);


        thisSelection=thisDoc.ActiveWindow.Selection;
        thisSelection.InsertAfter(' ');
        thisSelection.Collapse(0);

        if(~linkSettings.useActiveX&&rmiut.matlabConnectorOn())...
            ||reqmgt('rmiFeature','UseDotNet')

            navUrl=rmiut.cmdToUrl(navcmd);
            if~isempty(navUrl)
                rmiref.WordUtil.insertHyperlink(thisDoc,thisSelection,bitmap,navUrl,dispstr);
            end
        else

            slRefButton='SLRefButtonA';
            [actxOk,actxId]=rmicom.actx_installed(slRefButton);
            if actxOk
                try
                    rmiref.WordUtil.insertActxButton(thisDoc,thisSelection,actxId,bitmap,navcmd,dispstr);
                catch Mex
                    errordlg({...
                    getString(message('Slvnv:reqmgt:linktype_rmi_word:ActxFailedToInsert')),...
                    Mex.message,...
                    getString(message('Slvnv:reqmgt:linktype_rmi_word:ActxProblem'))},...
                    getString(message('Slvnv:reqmgt:linktype_rmi_word:LinkProblem')));
                end
            else
                warning(message('Slvnv:reqmgt:linktype_rmi_word:ActiveXControlUnavailble',slRefButton));
            end
        end
    end






    if is_docblock
        thisDoc.Save();
    end



    function str=next_bookmark_str(comWordDoc)
        bookmarkPrefix='Simulink_requirement_item_';
        prefixL=length(bookmarkPrefix);
        bmCollection=comWordDoc.Bookmarks;
        count=bmCollection.Count;
        lastNum=0;
        usingDotNet=reqmgt('rmiFeature','UseDotNet');
        for idx=1:count
            oneBookmark=find_bookmark(bmCollection,idx,false);
            bmLabel=oneBookmark.Name;
            if usingDotNet
                bmLabel=bmLabel.char;
            end
            if strncmp(bmLabel,bookmarkPrefix,prefixL)
                num=str2double(bmLabel((prefixL+1):end));
                if num>lastNum
                    lastNum=num;
                end
            end
        end
        str=[bookmarkPrefix,num2str(lastNum+1)];
    end

    function doc=get_active_doc
        doc=[];
        loaded=0;

        while(~loaded)
            if rmicom.wordApp('exists')
                hWord=rmicom.wordApp();
                try
                    doc=hWord.ActiveDocument;
                    loaded=1;
                catch Mex
                    loaded=0;
                end
            else
                loaded=0;
            end

            if(~loaded)
                response=questdlg(getString(message('Slvnv:reqmgt:linktype_rmi_word:OpenWordDocumentIsRequired')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:NoActiveWordDocument')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_pdf:Retry')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_pdf:Cancel')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_pdf:Retry')));
                if(isempty(response))
                    response=getString(message('Slvnv:reqmgt:linktype_rmi_pdf:Cancel'));
                end
                if strcmp(response,getString(message('Slvnv:reqmgt:linktype_rmi_pdf:Cancel')))
                    loaded=1;
                end
            end
        end
    end

    function str=getSelectedText(doc)
        sel=doc.ActiveWindow.Selection;
        if(sel.Start==sel.End)
            str='';
        else
            str=sel.Text;
            if reqmgt('rmiFeature','UseDotNet')
                str=str.char;
            end
        end
    end

    function cnt=count_whitespace_head(str)
        tmp1=sprintf('%sx',str);
        tmp2=strtrim(tmp1);
        cnt=length(tmp1)-length(tmp2);
    end
    function cnt=count_whitespace_tail(str)
        tmp1=sprintf('x%s',str);
        tmp2=strtrim(tmp1);
        cnt=length(tmp1)-length(tmp2);
    end

end

function html=HtmlViewFcn(doc,id)
    html='';
    if isempty(id)
        return;
    end
    html=rmiref.WordUtil.itemToHtml(doc,id);
end



function[tf,linkTargetInfo]=BacklinkCheckFcn(mwSourceArtifact,mwItemId,reqDoc,reqId)
    tf=false;
    linkTargetInfo='';




    if isempty(reqId)||reqId(1)~='@'


        tf=true;
        return;
    else
        bookmarkId=reqId(2:end);
    end

    fullPathToDoc=slreq.uri.ResourcePathHandler.getFullPath(reqDoc,mwSourceArtifact);
    utilObj=rmidotnet.docUtilObj(fullPathToDoc);
    if isempty(utilObj)
        return;
    end

    bookmarkInfo=utilObj.findBookmarks(bookmarkId);
    if isempty(bookmarkInfo)
        return;
    end

    backlinksInfo=utilObj.findBacklinks();

    if~isempty(backlinksInfo)
        matchedIdx=find(strcmp({backlinksInfo.mwId},mwItemId));
        if~isempty(matchedIdx)
            matchedBacklinks=backlinksInfo(matchedIdx);
            for i=1:length(matchedBacklinks)
                oneBacklink=matchedBacklinks(i);
                if contains(mwSourceArtifact,oneBacklink.mwSource)
                    if isMatchedRange(oneBacklink.range,bookmarkInfo.range)
                        tf=true;
                        break;
                    end
                end
            end
        end
    end



    navCmd=['rmi.navigate(''linktype_rmi_word'',''',reqDoc,''',''',reqId,''');'];
    navLink=makeHyperlink(navCmd,reqId);
    shortName=slreq.uri.getShortNameExt(reqDoc);
    linkTargetInfo=sprintf('%s in %s',navLink,shortName);
end

function tf=isMatchedRange(backlinkRange,bookmarkRange)


    allowedDistanceToAnchor=slreq.backlinks.WordDocChecker.MAX_DISTANCE_TO_ANCHOR;


    if bookmarkRange(1)<backlinkRange(1)
        if bookmarkRange(2)>backlinkRange(2)
            tf=true;
        elseif bookmarkRange(2)+allowedDistanceToAnchor>backlinkRange(2)
            tf=true;
        else
            tf=false;
        end
    else
        tf=false;
    end
end

function hyperlink=makeHyperlink(matlabCmd,label)
    hyperlink=['<a href="matlab:',matlabCmd,'">',label,'</a>'];
end

function[navcmd,dispstr]=BacklinkInsertFcn(reqDoc,reqId,mwSourceArtifact,mwItemId,mwDomain)


    if isempty(fileparts(mwSourceArtifact))

        pathToMwArtifact=which(mwSourceArtifact);
        if~isempty(pathToMwArtifact)
            mwSourceArtifact=pathToMwArtifact;
        end
    end

    if nargin<5
        mwDomain=slreq.backlinks.getSrcDomainLabel(mwSourceArtifact);
    end


    [navcmd,dispstr,bitmap]=slreq.backlinks.getBacklinkAttributes(mwSourceArtifact,mwItemId,mwDomain);
    navUrl=rmiut.cmdToUrl(navcmd);
    if isempty(navUrl)
        navcmd='';
        return;
    end



    if~rmiut.isCompletePath(reqDoc)
        refDir=fileparts(mwSourceArtifact);
        if isempty(refDir)
            refDir=pwd;
        end
        reqDoc=slreq.uri.ResourcePathHandler.getFullPath(reqDoc,refDir);
    end
    NavigateFcn(reqDoc,reqId);

    try


        utilObj=rmidotnet.docUtilObj(reqDoc);


        hWord=rmicom.wordApp();
        actxDoc=hWord.ActiveDocument;
        currentSelection=actxDoc.ActiveWindow.Selection;
        currentSelection.InsertAfter(' ');
        currentSelection.Collapse(0);
        rmiref.WordUtil.insertHyperlink(actxDoc,currentSelection,bitmap,navUrl,dispstr);




        utilObj.saveDocCacheTimestamp();
    catch Mex
        warning(message('Slvnv:rmiref:insertRefs:LocateIDFailed',reqId,reqDoc,mwItemId,Mex.message));
        navcmd='';
    end

end

function success=BacklinkDeleteFcn(reqDoc,reqId,mwSourceArtifact,mwItemId)






    if nargin<4

        [mwSourceArtifact,mwItemId]=slreq.utils.getExternalLinkArgs(mwSourceArtifact);
    end
    success=false;


    docPath=slreq.uri.ResourcePathHandler.getFullPath(reqDoc,mwSourceArtifact);
    docUtilObj=rmidotnet.docUtilObj(docPath);
    bookmarkName=reqId(2:end);
    bookmark=docUtilObj.findBookmarks(bookmarkName);
    if isempty(bookmark)
        return;
    end


    hyperlinks=docUtilObj.hDoc.Hyperlinks;

    mwShortName=slreq.uri.getShortNameExt(mwSourceArtifact);
    matchMwName=[mwShortName,'%22'];
    matchMwId=['%22',mwItemId,'%22'];
    for j=hyperlinks.Count
        oneHyperlink=hyperlinks.Item(j);
        address=oneHyperlink.Address;
        if isempty(address)||~contains(address,matchMwName)||~contains(address,matchMwId)
            continue;
        end
        if strcmp(char(oneHyperlink.Type),'msoHyperlinkShape')

            range=getShapeRange(oneHyperlink.Shape);
            if isMatchedRange(range,bookmark.range)
                oneHyperlink.Shape.Delete;
                success=true;
                break;
            end
        else

            range=oneHyperlink.Range;
            if isMatchedRange(range,bookmark.range)
                oneHyperlink.Delete;
                success=true;
                break;
            end
        end
    end

    function srange=getShapeRange(shape)
        anchor=shape.Anchor;
        srange=[anchor.Range.Start,anchor.Range.End];
    end
end

function[countRemoved,countChecked]=BacklinksCleanupFcn(reqDoc,mwSourceArtifact,mwLinksDataMap,saveBeforeCleanup)
    pathToDoc=slreq.uri.ResourcePathHandler.getFullPath(reqDoc,mwSourceArtifact);
    checker=slreq.backlinks.WordDocChecker(pathToDoc);
    if nargin>3&&saveBeforeCleanup
        checker.initialize();
    end
    checker.registerMwLinks(mwSourceArtifact,mwLinksDataMap);
    [countUnmatched,countChecked]=checker.countUnmatchedLinks();
    countRemoved=0;
    if countUnmatched>0
        if slreq.backlinks.confirmCleanup(slreq.uri.getShortNameExt(reqDoc),mwSourceArtifact,countUnmatched)
            countRemoved=checker.deleteUnmatchedLinks();
            if countRemoved~=countUnmatched
                rmiut.warnNoBacktrace('Slvnv:slreq_backlinks:SomethingWentWrong',num2str(countUnmatched-countRemoved));
            end
        end
    end
end
