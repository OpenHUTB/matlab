function docroot = getDocroot
% 获得文档所在的目录
    docroot = getDocrootFromSetting;
    if isempty(docroot)
        docroot = getDefaultDocroot;
    end
end

function docroot = getDocrootFromSetting
    s = settings;
    docrootSetting = s.matlab.help.DocRoot;
    docroot = docrootSetting.ActiveValue; 
end

function docroot = getDefaultDocroot
    persistent defaultDocroot;
    if isempty(defaultDocroot)
        defaultDocroot = fullfile(matlabroot, 'help', '');
    end
    docroot = defaultDocroot;
end