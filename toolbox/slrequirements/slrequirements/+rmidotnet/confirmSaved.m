function isSaved=confirmSaved(hDoc)



    if~hDoc.Saved


        action=questdlg(getString(message('Slvnv:slreq_import:DocUnsavedChanges',hDoc.Name.char)),...
        getString(message('Slvnv:slreq_import:ImportingUnsavedDocument')),...
        getString(message('Slvnv:slreq_import:ImportingUnsavedDocumentRetry')),...
        getString(message('Slvnv:slreq_import:ImportingUnsavedDocumentSaveContinue')),...
        getString(message('Slvnv:slreq_import:Cancel')),...
        getString(message('Slvnv:slreq_import:ImportingUnsavedDocumentRetry')));
        if isempty(action)
            action=getString(message('Slvnv:slreq_import:ImportingUnsavedDocumentIgnoreContinue'));
        end












        if strcmp(action,getString(message('Slvnv:slreq_import:ImportingUnsavedDocumentSaveContinue')))
            hDoc.Save();
            pause(0.5);
            isSaved=true;
        elseif strcmp(action,getString(message('Slvnv:slreq_import:ImportingUnsavedDocumentRetry')))
            isSaved=rmidotnet.confirmSaved(hDoc);
        else
            isSaved=false;
        end
    else
        isSaved=true;
    end
end
