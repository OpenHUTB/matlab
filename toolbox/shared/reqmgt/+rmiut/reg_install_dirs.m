function[names,dirs]=reg_install_dirs(masterKey,subKey,varargin)

    if isempty(varargin)
        names={};
        dirs={};
    else
        names=varargin{1};
        dirs=varargin{2};
    end
    try
        versions=reqmgt('regSubkeys',masterKey,subKey);
    catch Ex %#ok<*NASGU>
        return;
    end
    for i=1:length(versions)
        version=versions{i};
        try
            dir=reqmgt('regValue',masterKey,[subKey,'\',version],'InstallationDirectory');
        catch Mex
            dir=[];
        end
        if~isempty(dir)
            names{end+1}=version;%#ok<*AGROW>
            dirs{end+1}=dir;
        end
    end
end

