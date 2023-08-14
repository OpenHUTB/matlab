function linkStr=getReportLink(slsfId)
    linkStr='';
    modelcovId=cv('get',slsfId,'.modelcov');
    baseReportName=cv('get',modelcovId,'.currentDisplay.baseReportName');
    if isempty(baseReportName)
        return;
    end


    linkStr=sprintf('<a href="matlab: cvi.ReportUtils.reportLinkCallBack(%d);">%s</a>',slsfId,'Show in report');
    linkStr=sprintf('<table> <tr> <td> %s </td></tr></table>',linkStr);