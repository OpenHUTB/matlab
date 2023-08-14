function out=generateErrorReportPage(rpt,exception)
    d=Advisor.Document;
    d.addHeadItem(rpt.getMetaTag);
    icon='hilite_warning.png';
    rpt.copyResource(icon,'');
    img=Advisor.Image;
    img.setImageSource(icon);
    d.addItem(img);
    msg=rpt.getErrorMessage(exception);
    d.addItem(msg);
    if rpt.AddDetailedErrorMessage
        msg=Advisor.Element;
        msg.setTag('pre');
        msg.setContent(exception.getReport);
        d.addItem(msg);
    end
    out=d.emitHTML;
end
