function mustBeSimulinkReport(value)
    mlreportgen.report.validators.mustBeInstanceOf(...
    'slreportgen.report.internal.Report',value);
end

