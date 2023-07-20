function filename=generateReportName(baseName,extName)




    if nargin<2
        if ispc&&slreq.report.utils.checkApp('.docx')
            extName='.docx';
        else
            extName='.pdf';
        end
    end

    filename=slreq.report.utils.generateFileName(baseName,extName);
end