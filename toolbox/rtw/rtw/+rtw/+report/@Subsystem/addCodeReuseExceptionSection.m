function addCodeReuseExceptionSection(obj)

    summary=Advisor.Paragraph;
    summary.addItem([message('RTW:report:ReuseExceptionIntro').getString,'<br />']);
    l=Advisor.List;
    l.setType('Bulleted');
    l.addItem(message('RTW:report:ReuseExceptionBullet1').getString);
    l.addItem(message('RTW:report:ReuseExceptionBullet2').getString);
    l.addItem(message('RTW:report:ReuseExceptionBullet3').getString);
    summary.addItem(l);
    summary.addItem(['<b>',message('RTW:report:Note').getString,':</b>',message('RTW:report:ReuseExceptionNote').getString]);
    reuseExceptions=obj.getReuseExceptions;
    if isempty(reuseExceptions)
        contents=['<br /><b>',message('RTW:report:ReuseExceptionNone').getString,'</b>'];
    else
        obj.addAdditionalInformation(message('RTW:report:SummarySubsystemAdditionalInformationTitle').getString,...
        ['<a href="',obj.ModelName,'_',obj.getDefaultReportFileName(),'">',message('RTW:report:SummarySubsystemAdditionalInformationText').getString,'</a>']);
        contents=sprintf('%s\n',reuseExceptions{:});
    end
    obj.addSection('sec_reuse_exception',message('RTW:report:ReuseExceptionTitle').getString,summary,contents);
end


