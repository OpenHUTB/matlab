function services=codeTraceServiceFactory(reportViewer)



    services={codergui.internal.ReportCodeTraceService(reportViewer,'c')};

    if coder.internal.gui.Features.FixedPointTraceability.Enabled
        services{end+1}=codergui.internal.ReportCodeTraceService(reportViewer,'f2f');
    end

end

