function initIndustryStandardMode(this,modelName,snn)


    codingStdOptions=this.getParameter('HDLCodingStandardCustomizations');



    if this.isIndustryStandardMode()&&~this.isCodeGenSuccessful()

        hdlcodingstd.Report.initReport(snn,modelName);
        this.updateIndustryStandardParams(modelName);
        coding_std_mode='Industry';
    else
        coding_std_mode='None';
    end


    if(isempty(codingStdOptions))
        codingStdOptions=hdlcoder.CodingStandard(coding_std_mode);

        this.setParameter('HDLCodingStandardCustomizations',codingStdOptions);
    end

end
