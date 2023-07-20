function out=emitHTML(rpt)
    rpt.init;
    rpt.Doc.setTitle(rpt.getTitle());
    rpt.addHeadItems;
    rpt.addTitle;
    rpt.Doc.addItem(rpt.Introduction);
    rpt.Doc.addItem(rpt.Toc);
    rpt.execute;
    rpt.createIntroduction;
    rpt.createToc;
    out=rpt.Doc.emitHTML;
end
