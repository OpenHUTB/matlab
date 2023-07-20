function linktype=linktype_rmi_excel







    linktype=ReqMgr.LinkType;
    linktype.Registration=mfilename;


    linktype.Label=getString(message('Slvnv:reqmgt:linktype_rmi_excel:MicrosoftExcel'));


    linktype.IsFile=1;
    linktype.Extensions={'.xls','.csv','.xlsx','.xlsm','.xlsb'};


    linktype.LocDelimiters='?@$';
    linktype.Version='';


    linktype.NavigateFcn=@NavigateFcn;
    linktype.IsValidIdFcn=@IsValidIdFcn;
    linktype.IsValidDescFcn=@IsValidDescFcn;
    linktype.DetailsFcn=@DetailsFcn;
    linktype.CreateURLFcn=@CreateURLFcn;
    linktype.UrlLabelFcn=@UrlLabelFcn;
    linktype.DocDateFcn=@DocDateFcn;
    linktype.HtmlViewFcn=@HtmlViewFcn;


    linktype.SelectionLinkLabel=getString(message('Slvnv:rmisl:menus_rmi_object:LinkToSelectionInExcel'));
    linktype.SelectionLinkFcn=@SelectionLinkFcn;


    linktype.LinkedIdToImportedIdFcn=@LinkedIdToImportedIdFcn;


    linktype.BacklinkCheckFcn=@BacklinkCheckFcn;
    linktype.BacklinkInsertFcn=@BacklinkInsertFcn;
    linktype.BacklinkDeleteFcn=@BacklinkDeleteFcn;
    linktype.BacklinksCleanupFcn=@BacklinksCleanupFcn;

end

function NavigateFcn(filename,locationStr)
    if~ispc
        errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_excel:ExcelNotSupportedOnUnix')),getString(message('Slvnv:reqmgt:linktype_rmi_excel:Error')),'modal');
        return;
    end
    [~,hDoc]=openExcelDoc(filename,false);
    navigateToId(hDoc,locationStr);

    [~,fName,fExt]=fileparts(filename);
    reqmgt('winFocus',[fName,fExt]);
end

function success=IsValidIdFcn(filename,locationStr)
    if~ispc
        error getString(message('Slvnv:reqmgt:linktype_rmi_excel:ExcelNotSupportedOnUnix'));
    end
    [~,hDoc]=openExcelDoc(filename,true);
    try
        navigateToId(hDoc,locationStr);
        success=true;
    catch Mex
        warning(message('Slvnv:reqmgt:linktype_rmi_excel:IsValidIdFcn',locationStr,Mex.message));
        success=false;
    end
end

function[success,new_description]=IsValidDescFcn(filename,locationStr,currDesc)
    [hExcel,hDoc]=openExcelDoc(filename,true);
    if is_bookmark(locationStr)
        navigateToId(hDoc,locationStr)
        new_desc=hExcel.ActiveCell.Text;
        new_desc=rmiut.filterChars(new_desc,true);
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

function[hExcel,hWorkbook]=openExcelDoc(filename,check)
    if check



        excel_state=rmi.mdlAdvState('excel');
        if excel_state==0
            hExcel=rmicom.excelRpt('init');
        elseif excel_state==1
            hExcel=rmicom.excelRpt('get');
        else
            error(message('Slvnv:reqmgt:linktype_rmi_excel:openExcelDoc'));
        end
        hWorkbook=rmicom.excelApp('loaddoc',filename);
    else
        hExcel=rmicom.excelApp();
        hWorkbook=rmicom.excelApp('dispdoc',filename);
    end
end

function url=CreateURLFcn(docPath,refSrc,locationStr)

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


function[depths,items]=DetailsFcn(document,locationStr,detailsLevel)


    if nargin>2&&detailsLevel==0
        depths=[];
        items={};
        return
    end


    if isempty(locationStr)||length(locationStr)<2
        depths=0;
        items={getString(message('Slvnv:reqmgt:linktype_rmi_excel:LocationNotEntered'))};
        return
    end

    try
        [~,hWorkbook]=openExcelDoc(document,true);
    catch Mex
        depths=0;
        items={getString(message('Slvnv:reqmgt:linktype_rmi_excel:ERRORGettingDetailsExcel',Mex.message))};
        return;
    end

    hRange=findLocation(hWorkbook,locationStr);


    if hRange.Columns.Count>1||hRange.Rows.Count>1
        depths=[0,1];
        items{1}=getString(message('Slvnv:reqmgt:linktype_rmi_excel:Num2NumRange',hRange.Rows.Count,hRange.Columns.Count,document));
        try

            items{2}=hRange.Formula;
        catch Mex
            items{2}=getString(message('Slvnv:reqmgt:linktype_rmi_excel:ErrorFailedToExtractTable',document,Mex.message));
        end
    else
        depths=0;
        items{1}=getSameRowContent(hRange);
    end
end
















function content=getSameRowContent(startFromCell)


    content=startFromCell.Text;
    myCell=startFromCell.Next;
    afterEmpty=false;
    while true
        text=myCell.Text;
        if isempty(text)
            if afterEmpty
                break
            else
                afterEmpty=true;
            end
        else
            content=[content,' | ',text];%#ok<AGROW>
            afterEmpty=false;
        end
        myCell=myCell.Next;
    end
end

function navigateToId(hWorkbook,locationStr)
    if~isempty(locationStr)

        hRange=findLocation(hWorkbook,locationStr);

        if~isempty(hRange)
            hRange.Select;
        else
            errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_excel:FailedToLocateItem',locationStr)),...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:RequirementsNavigateToMSExcel')),'modal');
        end
    end
end

function hRange=findLocation(hWorkbook,locationStr,usingDotNet)
    if nargin<3
        usingDotNet=false;
    end
    hSheets=hWorkbook.Sheets;
    if usingDotNet||reqmgt('rmiFeature','UseDotNet')
        hSheet=Microsoft.Office.Interop.Excel.Worksheet(hWorkbook.ActiveSheet);
        usingDotNet=true;
    else
        hSheet=hWorkbook.ActiveSheet;
    end
    switch(locationStr(1))
    case '$'

        [target_sheet,location]=location_to_sheet_name(locationStr(2:end));
        if~isempty(target_sheet)&&~strcmp(target_sheet,hSheet.Name)
            hSheet=hSheets.Item(target_sheet);
            hSheet.Activate;
        end
        hRange=hSheet.Range(location);

    case '@'

        try
            hName=hWorkbook.Names.Item(locationStr(2:end));
        catch Mex
            error(message('Slvnv:reqmgt:linktype_rmi_excel:NamedItem',locationStr(2:end),Mex.message));
        end
        target_sheet=item_to_sheet_name(hName,usingDotNet);
        if usingDotNet
            sName=hSheet.Name.char;
        else
            sName=hSheet.Name;
        end
        if~isempty(target_sheet)&&~strcmp(target_sheet,sName)
            hSheet=hSheets.Item(target_sheet);
            if usingDotNet
                hSheet=Microsoft.Office.Interop.Excel.Worksheet(hSheet);
            end
            hSheet.Activate;
        end
        hRange=hName.RefersToRange;

    case '?'

        [target_sheet,location]=location_to_sheet_name(locationStr(2:end));
        if~isempty(target_sheet)&&~strcmp(target_sheet,hSheet.Name)
            hSheet=hSheets.Item(target_sheet);
            hSheet.Activate;
        end
        hRange=findRangeWithMatchingText(hSheet.Range('A1:IV20000'),location,usingDotNet);

    case '!'

        target_sheet=locationStr(2:end);
        if~isempty(target_sheet)&&~strcmp(target_sheet,hSheet.Name)
            hSheet=hSheets.Item(target_sheet);
            hSheet.Activate;
        end
        hRange=hSheet.Range('A1:A1');

    otherwise
        hRange=findRangeWithMatchingText(hSheet.Range('A1:IV20000'),locationStr,usingDotNet);
    end
end

function hCell=findRangeWithMatchingText(hRange,text,usingDotNet)
    hCell=hRange.Find(text);
    if usingDotNet&&~isempty(hCell)


        textLength=length(text);
        bestMatchLength=length(char(hCell.Text));
        while bestMatchLength>textLength
            rangeAfter=getRangeBelow(hCell);
            if isempty(rangeAfter)
                break;
            end
            nextMatchRange=rangeAfter.Find(text);
            if isempty(nextMatchRange)
                break;
            end
            nextMatchLength=length(char(nextMatchRange.Text));
            if nextMatchLength<bestMatchLength
                hCell=nextMatchRange;
                bestMatchLength=nextMatchLength;
            end
        end
    end
end

function rangeBelow=getRangeBelow(hCell)
    hSheet=hCell.Worksheet;
    lastRow=hSheet.UsedRange.Rows.Count;
    nextRow=hCell.Row+1;
    if nextRow>lastRow
        rangeBelow=[];
    else
        rangeBelowStringAddress=sprintf('A%d:IV%d',nextRow,lastRow);
        rangeBelow=hSheet.Range(rangeBelowStringAddress);
    end
end

function result=is_bookmark(locationStr)
    result=(~isempty(locationStr))&&(locationStr(1)=='@');
end


function sheet=item_to_sheet_name(item_name,useDotNet)
    sheet='';
    if nargin<2
        useDotNet=false;
    end
    if useDotNet||reqmgt('rmiFeature','UseDotNet')
        location=item_name.Value.char;
    else
        location=item_name.Value;
    end



    if~isempty(location)
        left_cut=strfind(location,'=');
        if~isempty(left_cut)&&left_cut(1)==1
            right_cut=strfind(location,'!');
            if~isempty(right_cut)&&right_cut(end)>left_cut+1
                sheet=location(left_cut+1:right_cut-1);
                if sheet(1)==''''&&sheet(end)==''''&&length(sheet)>2
                    sheet=sheet(2:end-1);
                end

                sheet=strrep(sheet,'''''','''');
            end
        end
    end
end

function[sheet,location]=location_to_sheet_name(location_string)
    separators=strfind(location_string,'!');
    if~isempty(separators)&&separators(end)>1&&separators(end)<length(location_string)
        sheet=location_string(1:separators(end)-1);
        location=location_string(separators(end)+1:end);
    else
        sheet='';
        location=location_string;
    end
end


function reqstruct=SelectionLinkFcn(objH,make2way)
    reqstruct=[];

    if~isempty(objH)

        srcFolderPath=rmiut.srcToPath(objH);
        if isempty(srcFolderPath)
            errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_excel:ModelMustBeSavedPriorToLinks')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:LinkingError')));
            return;
        end
    end


    activeWorkbook=get_active_workbook();
    if isempty(activeWorkbook)
        return;
    end


    docPath=activeWorkbook.FullName;
    if reqmgt('rmiFeature','UseDotNet')
        docPath=docPath.char;
    end
    [fpath,~,~]=fileparts(docPath);
    if isempty(fpath)
        errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_excel:DocumentsMustBeSavedPriorToLinks')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_excel:LinkingError')));
        return;
    end


    selectionStr=rmicom.excelApp('activetext');

    if isempty(objH)&&~make2way



        reqstruct=rmi('createempty');
        reqstruct.reqsys='linktype_rmi_excel';
        reqstruct.doc=docPath;
        if~isempty(selectionStr)
            reqstruct.id=['?',selectionStr];
        end
        return;
    end


    bookmarkStr=rmicom.excelApp('activebookmark');
    if isempty(bookmarkStr)

        if activeWorkbook.ReadOnly
            errordlg(getString(message('Slvnv:reqmgt:linktype_rmi_excel:ReadOnlyDocument',activeWorkbook.Name)),...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:LinkingError')));
            return;
        else
            bookmarkStr=next_bookmark_str(activeWorkbook);

            rmicom.excelApp('setname',bookmarkStr);
        end
    end


    pastPaths=rmi.settings_mgr('get','excelSelHist');
    pastIdx=find(strcmp(pastPaths,docPath));
    if isempty(pastIdx)
        pastPaths=[{docPath},pastPaths];
        rmi.settings_mgr('set','excelSelHist',pastPaths);
    elseif pastIdx(1)>1
        pastPaths(pastIdx)=[];
        pastPaths=[{docPath},pastPaths];
        rmi.settings_mgr('set','excelSelHist',pastPaths);
    end


    reqstruct=rmi('createempty');
    reqstruct.reqsys='linktype_rmi_excel';
    reqstruct.linked=true;
    reqstruct.doc=docPath;
    reqstruct.description=rmiut.filterChars(selectionStr,true);
    reqstruct.id=['@',bookmarkStr];
    tag=rmi.settings_mgr('get','selectTag');
    if~isempty(tag)
        reqstruct.keywords=tag;
    end

    if(make2way)

        srcType=rmiut.resolveType(objH);


        if strcmp(srcType,'simulink')&&~ischar(objH)
            [source,canceled]=rmi.canlink2way(objH);
            if canceled||length(source)<length(objH)
                reqstruct=[];
                return;
            end
        end



        ctrlWith=15;
        ctrlHeight=15;
        activeCell=rmicom.excelApp('activecell');
        ctrlLeft=activeCell.Left+activeCell.Width-ctrlWith;
        ctrlTop=activeCell.Top+activeCell.Height-ctrlHeight;


        [navcmd,dispstr,bitmap]=rmiut.targetInfo(objH,srcType);


        linkSettings=rmi.settings_mgr('get','linkSettings');
        if(~linkSettings.useActiveX&&rmiut.matlabConnectorOn())...
            ||reqmgt('rmiFeature','UseDotNet')

            navUrl=rmiut.cmdToUrl(navcmd);
            bitmap=ensureBitmapFile(bitmap);
            if~isempty(navUrl)
                newShape=activeWorkbook.ActiveSheet.Shapes.AddPicture(bitmap,0,1,ctrlLeft,ctrlTop,ctrlWith,ctrlHeight);
                activeWorkbook.ActiveSheet.Hyperlinks.Add(newShape,navUrl,'',dispstr);
            end
        else

            slRefButton='SLRefButtonA';
            [actxOk,actxId]=rmicom.actx_installed(slRefButton);
            if actxOk
                try
                    oleObject=activeWorkbook.ActiveSheet.OLEObjects.Add(actxId,...
                    '',0,0,'',0,'',...
                    ctrlLeft,ctrlTop,ctrlWith,ctrlHeight);

                    slrefobj=oleObject.object;
                    slrefobj.ToolTipString=dispstr;
                    slrefobj.MLEvalString=navcmd;

                    if strcmp(slRefButton,'SLRefButtonA')&&~isempty(bitmap)
                        rmiref.actx_picture(slrefobj,bitmap);
                    end

                    oleObject.Visible=0;
                    oleObject.Visible=1;
                catch Mex
                    errordlg({getString(message('Slvnv:reqmgt:linktype_rmi_excel:FailedToInsertActiveX')),...
                    Mex.message,...
                    getString(message('Slvnv:reqmgt:linktype_rmi_excel:MakeSureActiveX'))},...
                    getString(message('Slvnv:reqmgt:linktype_rmi_excel:LinkProblem')));
                end
            else
                warning(message('Slvnv:reqmgt:linktype_rmi_excel:ActiveXControlUnavailable',slRefButton));
            end
        end
    end

    function bitmap=ensureBitmapFile(bitmap)
        if isempty(bitmap)
            bitmap=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','mwlink.bmp');
        elseif exist(bitmap,'file')~=2
            warndlg({...
            getString(message('Slvnv:rmiref:actx_picture:MissingBitmapFile',bitmap)),...
            getString(message('Slvnv:rmiref:actx_picture:UsingDefaultImage'))},...
            getString(message('Slvnv:rmiref:actx_picture:FailedToSetPicture')));
            bitmap=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','mwlink.bmp');
        end
    end

    function str=next_bookmark_str(activeWorkbook)
        bookmarkPrefix='Simulink_requirement_item_';
        prefixL=length(bookmarkPrefix);

        nmCollection=activeWorkbook.Names;
        count=nmCollection.Count;
        usingDotNet=reqmgt('rmiFeature','UseDotNet');
        lastNum=0;
        for idx=1:count
            name=nmCollection.Item(idx);
            nameLabel=name.NameLocal;
            if usingDotNet
                nameLabel=nameLabel.char;
            end
            if strncmp(nameLabel,bookmarkPrefix,prefixL)
                num=str2double(nameLabel((prefixL+1):end));
                if num>lastNum
                    lastNum=num;
                end
            end
        end

        str=[bookmarkPrefix,num2str(lastNum+1)];
    end

    function workbook=get_active_workbook()
        workbook=rmicom.excelApp('activedoc');
        while isempty(workbook)
            response=questdlg(getString(message('Slvnv:reqmgt:linktype_rmi_excel:AnOpenExcelDocumentIsRequired')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:NoActiveExcelDocument')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:Retry')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:Cancel')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_excel:Retry')));
            if isempty(response)
                response=getString(message('Slvnv:reqmgt:linktype_rmi_excel:Cancel'));
            end
            if strcmp(response,getString(message('Slvnv:reqmgt:linktype_rmi_excel:Cancel')))
                return;
            else
                workbook=rmicom.excelApp('activedoc');
            end
        end
    end

end

function docDate=DocDateFcn(doc)
    fileinfo=dir(doc);
    if isempty(fileinfo)
        docDate=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
    else
        docDate=datestr(fileinfo.datenum,'yyyy-mm-dd HH:MM:SS');
    end
end

function html=HtmlViewFcn(doc,id)
    html='';
    if isempty(id)
        return;
    end
    html=rmiref.ExcelUtil.itemToHtml(doc,id);
end

function importedId=LinkedIdToImportedIdFcn(doc,linkedId)

























    importedId='';
    hWorkbook=rmicom.excelApp('finddoc',doc);
    if isempty(hWorkbook)
        return;
    end
    switch linkedId(1)
    case '@'

        names=hWorkbook.Names;
        for i=1:names.Count
            namedItem=names.Item(i);
            if strcmp(namedItem.Name,linkedId(2:end))
                docRange=namedItem.RefersToRange;
                firstCellText=docRange.Columns(1).Rows(1).Text;
                if~isempty(firstCellText)
                    importedId=['?',firstCellText];
                end
                return;
            end
        end
    case '$'

        [target_sheet,location]=location_to_sheet_name(linkedId(2:end));
        activeSheet=hWorkbook.ActiveSheet;
        if~isempty(target_sheet)&&~strcmp(target_sheet,activeSheet.Name)
            hSheets=hWorkbook.Sheets;
            activeSheet=hSheets.Item(target_sheet);
            activeSheet.Activate;
        end
        docRange=activeSheet.Range(location);
        firstCellText=docRange.Columns(1).Rows(1).Text;
        if~isempty(firstCellText)
            importedId=['?',firstCellText];
        end
    case '?'
        importedId=linkedId;
    otherwise
        importedId=['?',linkedId];
    end
end

function[tf,linkTargetInfo]=BacklinkCheckFcn(mwSourceArtifact,mwItemId,reqDoc,reqId)
    tf=false;
    linkTargetInfo='';





    fullPathToDoc=slreq.uri.ResourcePathHandler.getFullPath(reqDoc,mwSourceArtifact);
    utilObj=rmidotnet.docUtilObj(fullPathToDoc);
    if isempty(utilObj)
        tf=true;
        return;
    end


    if isempty(reqId)


        tf=true;
    else
        if reqId(1)=='@'

            myRange=utilObj.findNamedRange(reqId(2:end));
        else




            xlsRange=findLocation(utilObj.hDoc,reqId,true);
            myRange.label=regexprep(reqId,'^\?','');
            myRange.address=[xlsRange.Row,xlsRange.Column];
            myRange.range=[1,1];
        end
        backlinksInfo=utilObj.findBacklinks();


        if~isempty(backlinksInfo)
            matchedIdx=find(strcmp({backlinksInfo.mwId},mwItemId));
            if~isempty(matchedIdx)
                matchedBacklinks=backlinksInfo(matchedIdx);
                for i=1:length(matchedBacklinks)
                    oneBacklink=matchedBacklinks(i);
                    if contains(mwSourceArtifact,oneBacklink.mwSource)
                        if all(oneBacklink.cell==myRange.address)
                            tf=true;
                            break;
                        end
                    end
                end
            end
        end
    end


    navCmd=['rmi.navigate(''linktype_rmi_excel'',''',reqDoc,''',''',reqId,''');'];
    navLink=makeHyperlink(navCmd,reqId);
    shortName=slreq.uri.getShortNameExt(reqDoc);
    linkTargetInfo=sprintf('%s in %s',navLink,shortName);
end

function hyperlink=makeHyperlink(matlabCmd,label)
    hyperlink=['<a href="matlab:',matlabCmd,'">',label,'</a>'];
end

function[navcmd,dispstr]=BacklinkInsertFcn(reqDoc,reqId,mwSourceArtifact,mwItemId,mwDomain)




    if isempty(fileparts(mwSourceArtifact))


        onMatlabPath=which(mwSourceArtifact);
        if isempty(onMatlabPath)

            pathToMwArtifact=mwSourceArtifact;
        else
            pathToMwArtifact=onMatlabPath;
        end
    else
        pathToMwArtifact=mwSourceArtifact;
    end

    if nargin<5
        mwDomain=slreq.backlinks.getSrcDomainLabel(mwSourceArtifact);
    end


    try
        [navcmd,dispstr]=slreq.backlinks.getBacklinkAttributes(mwSourceArtifact,mwItemId,mwDomain);
    catch Mex
        throwAsCaller(Mex);
    end


    if~rmiut.isCompletePath(reqDoc)
        refDir=fileparts(pathToMwArtifact);
        if isempty(refDir)
            refDir=pwd;
        end
        reqDoc=slreq.uri.ResourcePathHandler.getFullPath(reqDoc,refDir);
    end

    inserted=false;
    try
        utilObj=rmidotnet.docUtilObj(reqDoc);
        utilObj.hDoc.Activate();
        hRange=findLocation(utilObj.hDoc,reqId,true);
        hRange.Select();



        hExcel=rmicom.excelApp();
        activeCell=hExcel.ActiveCell;
        hDoc=rmiref.ExcelUtil.activateDocument(reqDoc);
        inserted=rmiref.ExcelUtil.insertInCell(hDoc,activeCell,navcmd,dispstr,true);
    catch Mex
        warning(message('Slvnv:rmiref:insertRefs:LocateIDInExcelFailed',reqId,reqDoc,mwItemId,Mex.message));
    end

    if inserted



        utilObj.saveDocCacheTimestamp();
    else
        navcmd='';
    end
end

function success=BacklinkDeleteFcn(reqDoc,reqId,mwSourceArtifact,mwItemId)

    success=false;










end

function[countRemoved,countChecked]=BacklinksCleanupFcn(reqDoc,mwSourceArtifact,mwLinksDataMap,saveBeforeCleanup)
    pathToDoc=slreq.uri.ResourcePathHandler.getFullPath(reqDoc,mwSourceArtifact);
    checker=slreq.backlinks.ExcelDocChecker(pathToDoc);
    if nargin>3&&saveBeforeCleanup
        checker.initialize();
    end
    checker.registerMwLinks(mwSourceArtifact,mwLinksDataMap);
    [countUnmatched,countChecked]=checker.countUnmatchedLinks();
    countRemoved=0;
    if countUnmatched>0
        shortDocName=slreq.uri.getShortNameExt(reqDoc);
        shortSourceName=slreq.uri.getShortNameExt(mwSourceArtifact);
        if slreq.backlinks.confirmCleanup(shortDocName,shortSourceName,countUnmatched)
            countRemoved=checker.deleteUnmatchedLinks();
            if countRemoved~=countUnmatched
                rmiut.warnNoBacktrace('Slvnv:slreq_backlinks:SomethingWentWrong',num2str(countUnmatched-countRemoved));
            end
        end
    end
end

