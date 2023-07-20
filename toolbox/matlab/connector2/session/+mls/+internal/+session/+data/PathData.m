classdef PathData<handle




    properties
session
    end

    methods

        function this=PathData(session)
            this.session=session;
        end

        function data=get(this)
            data=getPathData(this.session);
        end

        function set(this,data)
            setupPath(this.session,data);
        end

        function reset(this)
            setupDefaultPath(this.session)
        end

    end

end




function setupPath(session,props)
    if~exist(session.userDir,'dir')
        return;
    end


    cd(session.userDir);

    if isfield(props,'relativeUserPath')
        userPathEntries=props.relativeUserPath;
    else
        userDirectory=session.getOldUserDirectory();
        userPathEntries=session.extractRelativePath(props.path,userDirectory);
    end

    userPath='';

    for i=1:numel(userPathEntries)
        userPath=[userPath,fullfile(session.userDir,userPathEntries{i}),pathsep];
    end

    addOnsPath='';

    if isfield(props,'relativeAddOnsPath')
        addOnsPathEntries=props.relativeAddOnsPath;
        for i=1:numel(addOnsPathEntries)
            addOnsPath=[addOnsPath,fullfile(session.addonsDir,addOnsPathEntries{i}),pathsep];
        end
    end

    path([session.userDir,pathsep,userPath,pathsep,path,pathsep,addOnsPath]);
end


function setupDefaultPath(session)
    if~exist(session.userDir,'dir')
        return;
    end


    cd(session.userDir);

    userSessionDir=fullfile(session.userDir,'.session');
    sharedDir=fullfile(session.userDir,'Shared');

    userPathEntries=regexp(genpath(session.userDir),pathsep,'split');
    userPath='';
    for i=1:numel(userPathEntries)
        if~strcmp(userPathEntries{i}(1:min(numel(userPathEntries{i}),numel(sharedDir))),sharedDir)&&...
            ~strcmp(userPathEntries{i}(1:min(numel(userPathEntries{i}),numel(userSessionDir))),userSessionDir)
            userPath=[userPath,userPathEntries{i},pathsep];%#ok<AGROW>
        end
    end

    addonsPathEntries=regexp(genpath(session.addonsDir),pathsep,'split');
    addonsPath='';
    for i=1:numel(addonsPathEntries)
        addonsPath=[addonsPath,addonsPathEntries{i},pathsep];%#ok<AGROW>
    end

    path([userPath,pathsep,path,pathsep,addonsPath]);
end


function p=getPathData(session)

    p.relativeUserPath=extractRelativePath(path,session.userDir);
    p.relativeAddOnsPath=extractRelativePath(path,session.addonsDir);
    p.path=path;
    p.matlabversion=version('-release');
end


function relativePathEntries=extractRelativePath(path,baseDirectory)
    relativePathEntries={};
    if~isempty(baseDirectory)

        pathEntries=strsplit(path,pathsep);
        relativePathEntryIndices=startsWith(pathEntries,baseDirectory);
        absolutePathEntries=pathEntries(relativePathEntryIndices);


        for i=1:numel(absolutePathEntries)
            absolutePathEntry=absolutePathEntries{i};
            relativePath=absolutePathEntry(numel(baseDirectory)+2:end);
            relativePathEntries=[relativePathEntries,relativePath];
        end
    end
end
