function varargout=rmi_settings_dlg(varargin)




    persistent rmisettingdlg;

    if nargin>0
        switch varargin{1}
        case 'get'

            varargout{1}=rmisettingdlg;
        case 'clear'
            rmisettingdlg=[];
        otherwise
            error('Invalid argument: %s',varargin{1});
        end
    else


        makeNew=true;
        if~isempty(rmisettingdlg)
            try
                rmisettingdlg.show();
                makeNew=false;
            catch Mex %#ok<NASGU>
            end
        end
        if makeNew
            dlgSrc=ReqMgr.ReqmgtSettings;
            rmisettingdlg=DAStudio.Dialog(dlgSrc);
        end

        if nargout>0
            varargout{1}=rmisettingdlg;
        end

    end
end

