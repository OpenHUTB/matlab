function openReport(reportName,showUI)










    [~,~,filetype]=fileparts(reportName);

    if slreq.report.utils.checkApp(filetype)

        slreq.utils.updateProgress(showUI,...
        'update',...
        getString(message('Slvnv:slreq:ReportGenProgressBarOpenReport')));
        if ispc&&ismember(filetype,{'.docx'})


            try
                rmicom.wordApp('updatedoc',reportName);
            catch ex %#ok<NASGU>

                open(reportName);
            end
        elseif ispc

            try
                open(reportName);
            catch ex %#ok<NASGU>

                msgbox(getString(message('Slvnv:slreq:ReportIsGenerated',reportName)));
            end
        else
            if showUI

                msgbox(getString(message('Slvnv:slreq:ReportIsGenerated',reportName)));
            end
        end
        slreq.utils.updateProgress(showUI,...
        'update',...
        getString(message('Slvnv:slreq:ReportGenProgressBarFinishFill')));
    end
end
