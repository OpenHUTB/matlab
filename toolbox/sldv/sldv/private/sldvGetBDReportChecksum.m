function[checksum,errorMsg]=sldvGetBDReportChecksum(modelH,blockH)





    checksumMode=Sldv.ChecksumMode.SLDV_CHECKSUM_REPORT;

    checksumCalculator=Sldv.Compatibility.ChecksumCalculator(modelH,blockH,checksumMode);
    [checksum,errorMsg]=checksumCalculator.compute();
end