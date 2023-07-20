function ret=getBrowserDialog(varargin)
    mlock;
    persistent dlg
    ret=[];

    if rtw.report.ReportInfo.featureReportV2


        dlgs=DAStudio.ToolRoot.getOpenDialogs;
        keyStr='RTW:report:DocumentTitle';
        expectedStr=DAStudio.message(keyStr,'');
        for k=1:numel(dlgs)
            dlgTemp=dlgs(k);
            src=dlgTemp.getSource;
            if isa(src,'rtw.report.Web')||isa(src,'Simulink.document')
                if contains(src.Title,expectedStr)

                    dlg=dlgTemp;
                    ret=dlg;
                    return;
                end
            end
        end
    end

    if isa(dlg,'DAStudio.Dialog')
        ret=dlg;
    elseif nargin>0
        hSrc=varargin{1};
        if isa(hSrc,'Simulink.document')
            dlg=DAStudio.Dialog(hSrc);
            dlg.position=[50,50,950,700];
        end
        ret=dlg;
    end
end
