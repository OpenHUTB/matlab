function varargout=attrDlg_mgr(varargin)




    persistent dlgObj;


    caller=[];
    docType=[];
    srcDoc='';
    option=[];


    if nargin>0
        switch varargin{1}
        case 'get'

            varargout{1}=dlgObj;
            return;
        case 'clear'
            try
                dlgObj.delete();
            catch ME %#ok<NASGU>
            end
            dlgObj=[];
            return;
        case 'show'
            caller=varargin{2};
            docType=varargin{3};
            srcDoc=varargin{4};
            if nargin>4
                option=varargin{5};
            end
        otherwise
            error('unsupported use case in slreq.import.ui.attrDlg_mgr()');
        end
    end


    makeNew=true;

    if~isempty(dlgObj)
        try
            dlgObj.getSource.caller=caller;
            dlgObj.getSource.docType=docType;
            dlgObj.getSource.srcDoc=srcDoc;
            switch docType
            case 2
                dlgObj.getsource.subDoc=option;
            case 4
                dlgObj.getsource.attributeMap=slreq.import.doorsAttribMap(srcDoc);
            case 5
                dlgObj.getsource.projectURI=option.uri;
                dlgObj.getsource.queryString='';
            otherwise
                error('unexpected document type in attrDlg_mgr(): %d',docType);
            end
            dlgObj.refresh();
            dlgObj.show();
            makeNew=false;
        catch Mex %#ok<NASGU>
        end
    end

    if makeNew
        switch docType
        case 2
            dlgSrc=slreq.import.ui.XlsMappingDlg();
            dlgSrc.subDoc=option;
        case 4
            dlgSrc=slreq.import.ui.DoorsMappingDlg();
            dlgSrc.attributeMap=slreq.import.doorsAttribMap(srcDoc);
        case 5
            dlgSrc=slreq.import.ui.OSLCQueryBuilderDlg();
            dlgSrc.serverLoginInfo=option;
        otherwise
            error('unexpected document type in attrDlg_mgr(): %d',docType);
        end
        dlgSrc.caller=caller;
        dlgSrc.srcDoc=srcDoc;
        dlgObj=DAStudio.Dialog(dlgSrc);
    end

    if nargout>0
        varargout{1}=dlgObj;
    end

end



