function udd2mcos_convert(pkg)



    uddtoolsPath='B:\Bmain\perfect\matlab\toolbox\mwtools\mwpresubmittool';
    if~contains(path,uddtoolsPath)
        addpath(uddtoolsPath);
    end

    uddtools.convert(pkg,...
    'InClassDir',true,...
    'CaseInsensitiveProperties',true,...
    'UseAbortSet',true,...
    'DataTypeCheck','MATLABTypes',...
    'Observable','all',...
    'customization','RPT');

    rmpath(uddtoolsPath);

end

