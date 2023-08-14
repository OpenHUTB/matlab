function generateRTMX()
    import slreq.report.internal.rtmx.*
    rtmx=ReqRTMX.getInstance();
    rtmx.createTableStr();
    rtmx.createHTMLFile();
    rtmx.show;
end