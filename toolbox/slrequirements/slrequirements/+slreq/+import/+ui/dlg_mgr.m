function varargout=dlg_mgr(varargin)




    persistent docImportDlg;

    reqSetName='';
    importMode=true;

    if nargin>0
        switch varargin{1}
        case 'get'

            varargout{1}=docImportDlg;
            return;
        case 'clear'
            slreq.import.ui.attrDlg_mgr('clear');
            try
                docImportDlg.delete();
            catch ME %#ok<NASGU>
            end
            docImportDlg=[];
            return;
        otherwise

            reqSet=slreq.data.ReqData.getInstance.getReqSet(varargin{1});
            if~isempty(reqSet)&&isa(reqSet,'slreq.data.RequirementSet')
                reqSetName=reqSet.filepath;
                importMode=varargin{2};
            else
                error('Invalid argument: %s',varargin{1});
            end
        end
    end


    makeNew=true;

    if~isempty(docImportDlg)
        try
            docImportDlg.show();
            docImportDlg.getSource.importMode=importMode;
            docImportDlg.getSource.destReqSet=reqSetName;
            docImportDlg.isReqsetContext=~isempty(reqSetName);
            docImportDlg.refresh();
            makeNew=false;
        catch Mex %#ok<NASGU>
        end
    end

    if makeNew
        dlg=findDDGByTag('SlreqImportDlg');



        createdAlready=false;
        try
            if ishandle(dlg)
                docImportDlg=dlg;
                dlg.show;
                createdAlready=true;
            end
        catch ex %#ok<NASGU>

            createdAlready=false;
        end

        if~createdAlready
            dlgSrc=slreq.import.ui.ImportDlg();
            dlgSrc.importMode=importMode;
            dlgSrc.destReqSet=reqSetName;
            dlgSrc.isReqsetContext=~isempty(reqSetName);
            docImportDlg=DAStudio.Dialog(dlgSrc);
        end
    end

    if nargout>0
        varargout{1}=docImportDlg;
    end

end

