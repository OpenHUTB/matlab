function cvd=loadCoverage(filename,mdl)



    import Coverage.*;

    if~slavteng('feature','EnhancedCoverageSlicer')||strcmp(filename(end-3:end),'.cvt')
        covData=loadCVTFile(filename,mdl);
        cvd=CovData(covData{1});
    else
        cvd=slcrxPackager.read(filename,mdl);
    end

end
