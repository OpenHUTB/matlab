function bldDir=emcGetBuildDirectory(buildInfo,bldMode,replaceMatlabroot)





    switch bldMode
    case coder.internal.BuildMode.Normal
        groups={'BuildDir','StartDir'};
    case coder.internal.BuildMode.Example
        groups={'ExampleBuildDir'};
    end
    if nargin<3
        replaceMatlabroot=true;
    end
    for i=1:numel(groups)
        buildDirs=buildInfo.getSourcePaths(replaceMatlabroot,groups(i));
        if~isempty(buildDirs)
            break;
        end
    end
    if isempty(buildDirs)
        error(message('Coder:buildProcess:directoryNotSpecified'));
    end
    bldDir=buildDirs{1};
end
