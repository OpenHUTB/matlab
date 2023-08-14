function lst=getLinkerOptions(ProjectBuildInfo)



    flags=ProjectBuildInfo.mBuildInfo.getLinkFlags();

    lst='';

    for i=1:length(flags)
        if~isempty(flags(i))
            lst=[lst,' ',flags{i},' '];%#ok<AGROW>
        end
    end