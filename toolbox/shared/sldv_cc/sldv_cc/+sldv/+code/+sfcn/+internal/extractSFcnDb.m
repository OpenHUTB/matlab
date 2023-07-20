function dbFile=extractSFcnDb(sfunctionName,outputDir)



    dbData=evalin('base',sprintf('%s(''getCoverageTraceabilityDataBase'')',sfunctionName));
    dbFile=sldv.code.internal.extractDb(outputDir,dbData,sfunctionName);


