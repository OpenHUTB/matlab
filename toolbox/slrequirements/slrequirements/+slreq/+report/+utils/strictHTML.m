function htmlDOM=strictHTML(rawText,type,rawTextOnly)
    if nargin<3
        rawTextOnly=false;
    end
    htmlDOM=slreq.report.utils.ReportHTMLProcessor.generateRPTDom(rawText,type,rawTextOnly);

end

