function[releaseName,mlRoot,version]=getReleaseInfo()




    verInfo=ver('matlab');
    releaseName=verInfo.Release;
    releaseName=stm.internal.util.trimReleaseName(releaseName);
    mlRoot=matlabroot;
    version=verInfo.Version;
end
