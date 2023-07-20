function closeDialog(varargin)
    narginchk(0,1);
    hDlg=Simulink.report.ReportInfo.getBrowserDialog();
    if~isa(hDlg,'DAStudio.Dialog')
        return
    end
    if nargin==1
        model=varargin{1};
        if~ischar(model)
            model=getfullname(model);
        end
        hSrc=hDlg.getDialogSource;
        if isa(hSrc,'Simulink.document')&&~isempty(hSrc.Model)&&~strcmp(hSrc.ModelName,model)
            return
        end
    end
    hDlg.delete;
end
