classdef STMReportLicense < mlreportgen.dom.LockedDocument    
%
% Class for report generation license.

% Copyright 2014 The MathWorks, Inc.
%           
    
    methods
        function this = STMReportLicense(ofile,docType,templateFile)            
            this@mlreportgen.dom.LockedDocument(ofile, docType, templateFile);
            key = stm.internal.report.getDOMLicenseKey();            
            this.open(key);
        end
    end    
end




