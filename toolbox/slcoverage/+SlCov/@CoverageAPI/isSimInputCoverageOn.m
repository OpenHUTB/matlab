function res=isSimInputCoverageOn(simInput)



    res=strcmpi(simInput.get_param('CovEnable'),'on')||...
    strcmpi(simInput.get_param('RecordCoverage'),'on')||...
    ~strcmpi(simInput.get_param('CovModelRefEnable'),'off');
end
