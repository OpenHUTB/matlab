function out=getSystemTargetFile(dictionary,platform)









    out='';
    if dictionary~=""
        helper=coder.internal.CoderDataStaticAPI.getHelper;
        platforms=helper.openDD(dictionary).owner.SoftwarePlatforms;
        for k=1:platforms.Size
            if strcmp(platforms.at(k).Name,platform)
                out=platforms.at(k).SystemTargetFile;
                break
            end
        end
    end