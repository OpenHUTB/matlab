function makeTitlePage(sddRpt)



















    import mlreportgen.report.*
    import slreportgen.report.*


    tp=TitlePage;


    if isempty(sddRpt.Title)

        tp.Title=...
        mlreportgen.utils.normalizeString(get_param(sddRpt.RootSystem,"Name"));
    else

        tp.Title=sddRpt.Title;
    end


    if isempty(sddRpt.Subtitle)

        tp.Subtitle=getString(message("slreportgen:StdRpt:SDD:titlePageSubtitle"));
    else

        tp.Subtitle=sddRpt.Subtitle;
    end


    if~isempty(sddRpt.Author)
        tp.Author=sddRpt.Author;
    end


    if isempty(sddRpt.TitlePageImage)

        tp.Image=Diagram(sddRpt.RootSystem);
        tp.Image.Scaling="custom";
        tp.Image.Height="2in";
        tp.Image.Width="3in";
    else

        tp.Image=sddRpt.TitlePageImage;
    end


    tp.PubDate=datestr(now,sddRpt.TimeFormat);


    append(sddRpt,tp);
end