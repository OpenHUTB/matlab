function status=matchPlatformStr(platform,platformStr)




















    platform=lower(platform);
    platformStr=lower(platformStr);
    validPlatforms={'pcwin','pcwin64','glnxa64','maci64','all'};

    platformList=strsplit(platformStr,',');

    if~ismember(platform,validPlatforms)
        status=-2;
    elseif~all(ismember(platformList,validPlatforms))
        status=-1;
    else
        status=double(any(ismember(platformList,{platform,'all'})));
    end
