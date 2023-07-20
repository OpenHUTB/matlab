function cvsave(fileName,varargin)
















    try
        SlCov.CoverageAPI.saveCoverage(fileName,varargin{:});
    catch Me
        throwAsCaller(Me);
    end
