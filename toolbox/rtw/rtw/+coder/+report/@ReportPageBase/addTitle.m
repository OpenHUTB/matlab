function addTitle(rpt)
    title=Advisor.Element;
    title.setTag('h1');
    title.setContent(rpt.Doc.Title);
    rpt.addItem(title);
end
