function exportDomainToMLDATX(fname,runID,domain)

    Simulink.sdi.recordToMldatxForRapidAccel(fname,runID,domain);
end
