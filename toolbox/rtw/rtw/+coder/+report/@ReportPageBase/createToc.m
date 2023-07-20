function createToc(rpt)
    if~rpt.AddSectionToToc||isempty(rpt.TocItems.Items)
        return
    end
    tocTitle=Advisor.Element;
    tocTitle.setContent(rpt.getMessage('TableOfContents'));
    tocTitle.setTag('h3');
    if rpt.AddSectionNumber
        rpt.TocItems.setType('Numbered');
    end
    rpt.Toc.setContent([tocTitle.emitHTML,rpt.TocItems.emitHTML]);
end
