function onSetSectionNumber(action)





    persistent sectionNumberDlgSrc
    if isempty(sectionNumberDlgSrc)
        sectionNumberDlgSrc=slreq.das.IndexNumberDlg();
    elseif nargin>0&&ischar(action)&&strcmp(action,'clear')

        try
            sectionNumberDlgSrc.delete();
            sectionNumberDlgSrc=[];
        catch
        end
        return;
    end

    appmgr=slreq.app.MainManager.getInstance();
    dasReq=appmgr.getCurrentViewSelections();

    if isa(dasReq,'slreq.das.Requirement')

        sectionNumberDlgSrc.setOwner(dasReq);
        DAStudio.Dialog(sectionNumberDlgSrc);
    end
end


