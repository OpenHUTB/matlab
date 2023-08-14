function createReport(comparison,reportLocation,format)


    if ischar(format)
        format=eval(format);
    end

    feval(format.ReportCreator,comparison,reportLocation,format);

end

