
function loadSlciLibrary(slciLibName)
    if~libisloaded(getSlcifeatureLibName)
        loadlibrary(getSlcifeatureLibName,'slcifeature.h')
    end
    if isLccCompilerInstalled
        [~,~]=loadlibrary(slciLibName,'slci.h','includepath',...
        fullfile(matlabroot,'sys','lcc','include'));
    else
        [~,~]=loadlibrary(slciLibName,'slci.h');
    end
end


function installed=isLccCompilerInstalled()
    installed=false;
    c=mex.getCompilerConfigurations();
    for i=1:numel(c)
        if strcmpi(c(i).Name,'Lcc-win32')
            installed=true;
            return
        end
    end
end


function name=getSlcifeatureLibName()
    if ispc
        name='slcifeat';
    else
        name='libmwslcifeat';
    end
end
