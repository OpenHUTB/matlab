function buildInfo=emcLoadPreviousBuildInfo(bldDirectory)



    buildInfo=[];
    buildInfoFile=fullfile(bldDirectory,'buildInfo.mat');
    if isfile(buildInfoFile)
        try
            load(buildInfoFile,'buildInfo');
            if~isa(buildInfo,'RTW.BuildInfo')
                buildInfo=[];
            end
        catch
        end
    end
end
