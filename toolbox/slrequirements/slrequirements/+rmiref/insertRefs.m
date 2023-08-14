function[totalLinks,totalMatched,refsInserted]=insertRefs(model,doctype)



























    if nargin<2
        error(message('Slvnv:rmiref:insertRefs:InvalidUsage'));
    end

    model=convertStringsToChars(model);
    doctype=convertStringsToChars(doctype);

    modelH=rmisl.getmodelh(model);
    if isempty(modelH)
        if~ischar(model)
            model=num2str(model);
        end
        error(message('Slvnv:rmiref:insertRefs:InvalidModel',model));
    end


    rmiref.cachedSettings('reset');

    switch lower(doctype)
    case 'word'
        [totalLinks,totalMatched,refsInserted]=word_insert_refs(modelH);
    case 'excel'
        [totalLinks,totalMatched,refsInserted]=excel_insert_refs(modelH);
    otherwise
        error(message('Slvnv:rmiref:insertRefs:InvalidDoctype',doctype));
    end
end

function[totalLinks,totalMatched,refsInserted]=excel_insert_refs(modelH)
    [currentDoc,hExcel,hDoc]=rmiref.ExcelUtil.getCurrentDoc();
    currentDoc=standard_path(currentDoc);
    allHs=rmisl.getObjWithReqs(modelH);
    totalObjects=length(allHs);
    totalLinks=0;
    totalMatched=0;
    refsInserted=0;
    rmiref.ExcelUtil.insertions('reset');
    for i=1:totalObjects
        myReqs=rmi('get',allHs(i));
        myCount=length(myReqs);
        totalLinks=totalLinks+myCount;
        for j=1:myCount
            req=myReqs(j);
            linktype=rmi.linktype_mgr('resolveByFileExt',req.doc);
            if~isempty(linktype)&&strcmp(linktype.Registration,'linktype_rmi_excel')
                doc=rmisl.locateFile(req.doc,modelH);
                if~isempty(doc)
                    doc=standard_path(doc);
                    doc=rmiut.simplifypath(doc,'/');
                    if strcmp(doc,currentDoc)
                        totalMatched=totalMatched+1;
                        refsInserted=refsInserted+excel_insert_ref(hExcel,hDoc,req.id,allHs(i));
                    end
                end
            end
        end
    end
end

function[totalLinks,totalMatched,refsInserted]=word_insert_refs(modelH)
    [currentDoc,hWord,hDoc]=rmiref.WordUtil.getCurrentDoc();
    currentDoc=standard_path(currentDoc);
    allHs=rmisl.getObjWithReqs(modelH);
    totalObjects=length(allHs);
    totalLinks=0;
    totalMatched=0;
    refsInserted=0;
    for i=1:totalObjects
        myReqs=rmi('get',allHs(i));
        myCount=length(myReqs);
        totalLinks=totalLinks+myCount;
        for j=1:myCount
            req=myReqs(j);
            linktype=rmi.linktype_mgr('resolveByFileExt',req.doc);
            if~isempty(linktype)&&strcmp(linktype.Registration,'linktype_rmi_word')
                doc=rmisl.locateFile(req.doc,modelH);
                if~isempty(doc)
                    doc=standard_path(doc);
                    doc=rmiut.simplifypath(doc,'/');
                    if strcmp(doc,currentDoc)
                        totalMatched=totalMatched+1;
                        refsInserted=refsInserted+word_insert_ref(hWord,hDoc,req.id,allHs(i));
                    end
                end
            end
        end
    end
end

function myPath=standard_path(myPath)
    myPath=lower(myPath);
    myPath=strrep(myPath,'\','/');
end

function inserted=word_insert_ref(hWord,hDoc,id,objH)
    if isempty(id)

        hRange=hDoc.Paragraphs.Item(1).Range;
        hRange.Select;
    else
        try
            rmiref.WordUtil.selectRange(hWord,hDoc,id);
        catch Mex
            warning(message('Slvnv:rmiref:insertRefs:LocateIDFailed',id,hDoc.FullName,strrep(get_name(objH),char(10),' '),Mex.message));
            inserted=false;
            return;
        end
    end
    hSelection=hDoc.ActiveWindow.Selection;
    hRange=hSelection.Range;
    if hRange.Start==hRange.End
        inserted=0;
        if id(1)=='?'||id(1)=='@'
            id(1)=[];
        end
        disp(getString(message('Slvnv:rmiref:insertRefs:LocationNotFound',id)));
    else
        if strcmp(hSelection.Text,' ')&&hRange.Start==0
            disp(getString(message('Slvnv:rmiref:insertRefs:InsertingAtTheTop')));
        else
            disp(getString(message('Slvnv:rmiref:insertRefs:InsertingAfter',hSelection.Text,num2str(hRange.Start),num2str(hRange.End))));
        end
        hDoc.Activate();
        hWord.Activate();
        inserted=word_insert_ref_after(hDoc,hSelection,objH);
    end
end

function name=get_name(obj)
    [isSf,objH,errMsg]=rmi.resolveobj(obj);
    if isempty(errMsg)
        if isSf
            name=sf('get',objH,'.name');
        else
            name=get_param(objH,'Name');
        end
    else
        name=getString(message('Slvnv:rmiref:insertRefs:SimulinkOrStateflowObject'));
    end
end

function inserted=excel_insert_ref(hExcel,hDoc,id,objH)
    try
        rmiref.ExcelUtil.selectCell(hExcel,hDoc,id);
    catch Mex
        warning(message('Slvnv:rmiref:insertRefs:LocateIDInExcelFailed',id,hDoc.FullName,strrep(get_name(objH),char(10),' '),Mex.message));
        inserted=false;
        return;
    end
    activeCell=hExcel.ActiveCell;
    if isempty(activeCell)
        inserted=false;
    else
        disp(getString(message('Slvnv:rmiref:insertRefs:InsertingIntoCell',num2str(activeCell.Row),num2str(activeCell.Column))));
        inserted=rmiref.ExcelUtil.insertInCell(hDoc,activeCell,objH);
    end
end

function success=word_insert_ref_after(thisDoc,thisSelection,obj)


    thisSelection.InsertAfter(' ');
    thisSelection.Collapse(0);

    [useMatlabConnector,actXprogId,customBitmap]=rmiref.cachedSettings('get');

    [navcmd,dispstr]=rmi.objinfo(obj);

    if useMatlabConnector
        try
            rmiref.WordUtil.insertHyperlink(thisDoc,thisSelection,customBitmap,rmiut.cmdToUrl(navcmd),dispstr);
            success=1;
        catch Mex
            errordlg({...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:HyperlinkFailedToInsert')),...
            Mex.message},...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:LinkProblem')));
            success=0;
        end
    else
        if~isempty(actXprogId)
            try
                rmiref.WordUtil.insertActxButton(thisDoc,thisSelection,actXprogId,customBitmap,navcmd,dispstr);
                success=1;
            catch Mex
                errordlg({...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:ActxFailedToInsert')),...
                Mex.message,...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:ActxProblem'))},...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:LinkProblem')));
                success=0;
            end
        else
            warning(message('Slvnv:rmiref:insertRefs:ActiveXControlUnavailable','SLRefButton'));
            success=0;
        end
    end
end




