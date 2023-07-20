


classdef slcoderPublishCodeDlg<rtw.report.ReportDlg
    methods
        function dlg=slcoderPublishCodeDlg(sys)
            dlg=dlg@rtw.report.ReportDlg(sys);
        end

        function out=getActionTag(~)
            out='createPrintableReportButton';
        end
        function out=getActionName(~)
            out=DAStudio.message('RTW:report:btnPublishCode');
        end
        function out=getActionMethod(~)
            out='createPrintableReport';
        end
        function out=getTitle(obj)
            out=DAStudio.message('RTW:report:titlePublishCode',obj.sys);
        end

        function helpReport(obj)%#ok<MANU>
            try
                helpview(fullfile(docroot,'rtw','helptargets.map'),'publish_generated_code');
            catch ME
                errordlg(ME.message);
            end
        end

        function createPrintableReport(obj)
            rptInfo=obj.loadRptInfo(obj.reportFolder);
            if~isempty(rptInfo)

                try

                    model=bdroot(obj.sys);
                    aStdRpt=StdRptDlg.RTW(model).getCfg;
                    coder.report.internal.slcoderPublishCode.publish(aStdRpt,rptInfo);
                    delete(obj);

                catch ME

                    errordlg(ME.message);
                end
            end
        end
    end
    methods(Static=true)
        function publish(sys)
            model=bdroot(sys);
            try
                coder.report.publish(sys);
            catch ME
                switch ME.identifier
                case{'RTW:report:BuildFolderNotExist'
                    'RTW:report:relativeBuildFolderNotFound'}

                    dialogSrc=coder.report.internal.slcoderPublishCodeDlg(model);
                    if~isempty(dialogSrc)
                        dlgBox=DAStudio.Dialog(dialogSrc);
                        dlgBox.show;
                        dlgBox.setFocus('openrpt_ReportFolder');
                    end
                case 'RTW:report:txtWarningReport'
                    errordlg(ME.message);
                otherwise
                    errordlg(ME.message);
                end
            end
        end
    end
end

