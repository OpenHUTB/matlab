function[result,msg]=testCoverageLicense(param)
    msg='';
    result=license(param,SlCov.CoverageAPI.getLicenseName)&&exist('cvsim','file')~=0;
end