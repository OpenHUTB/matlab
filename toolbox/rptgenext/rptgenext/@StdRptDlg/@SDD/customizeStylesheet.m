function customizeStylesheet(dlgsrc)



    id=char(dlgsrc.stylesheetIDs(dlgsrc.stylesheetIndex));
    dlgsrc.cancelReport;
    rpteditstyle(id);

end

