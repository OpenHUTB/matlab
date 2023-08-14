function location=selectShortcutFile()



    selectionTitle=i_getMessage("MATLAB:project:view_file:ShortcutFileSelectionTitle");
    p=currentProject;
    [name,path]=uigetfile(p.RootFolder,selectionTitle);

    if isnumeric(name)
        location="";
        return;
    end


    files=p.Files;
    isInProject=ismember(fullfile(path,name),[files.Path]);
    if~isInProject
        error(i_getMessage("MATLAB:project:view_file:ShortcutInvalidFile"));
    end

    relativePath=strip(extractAfter(string(path),p.RootFolder),filesep);


    location=[fullfile(path,name);fullfile(relativePath,name)];
end

function value=i_getMessage(resource,varargin)
    value=string(message(resource,varargin{:}));
end
