function res=isSLCovInstalled()




    res=~isempty(which('cvsim'))&&license('test',SlCov.CoverageAPI.getLicenseName);
end

