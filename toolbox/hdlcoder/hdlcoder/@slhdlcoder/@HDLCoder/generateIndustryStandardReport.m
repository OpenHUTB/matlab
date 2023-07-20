function generateIndustryStandardReport(this,mdlName)
    if this.isIndustryStandardMode()
        showReport=this.getParameter('ErrorCheckReport');
        codingStdOptions=this.getParameter('HDLCodingStandardCustomizations');
        hdlcodingstd.Report.generateIndustryStandardReport(mdlName,showReport,codingStdOptions);

        hdldisp(hdlcodingstd.Report.getSummary(mdlName));
    end
end
