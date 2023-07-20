




classdef ProgressDialog<handle
    properties
WaitBarH
    end
    methods
        function this=ProgressDialog(hFig,progressDlgTitle,progressMsg)
            if isWebFigure
                this.WaitBarH=uiprogressdlg(hFig,'Title',progressDlgTitle,...
                'Indeterminate','on','Message',progressMsg);
            else
                this.WaitBarH=waitbar(0,progressMsg,'Name',...
                progressDlgTitle);
            end
        end

        function setParams(this,v,msg)
            if isa(this.WaitBarH,'matlab.ui.dialog.ProgressDialog')
                this.WaitBarH.Value=v;
                this.WaitBarH.Message=msg;
            else
                waitbar(v,this.WaitBarH,msg);
            end
        end
        function close(this)
            close(this.WaitBarH);
        end
    end
end

function tf=isWebFigure()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
