function[tests,data]=cvload(fileName,varargin)

































    try
        [tests,data]=SlCov.CoverageAPI.loadCoverage(fileName,varargin{:});
    catch Me
        throwAsCaller(Me);
    end
