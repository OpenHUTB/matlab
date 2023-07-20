


























function out=getReportOptions()
    defaultOptions=slreq.report.utils.getDefaultOptions();
    expectOptions={'reportPath','openReport','titleText','authors',...
    'includes'};

    alloptions=fieldnames(defaultOptions);
    out=rmfield(defaultOptions,setdiff(alloptions,expectOptions));
end