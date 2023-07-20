









function yes=isInstall()
    persistent cached;
    if isempty(cached)
        cached=~isfile(fullfile(matlabroot,'toolbox/coder/coderapp/utils/sdk_marker.txt'));
    end
    yes=cached;
end