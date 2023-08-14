function checkWindowsUprojectAssociation()
    if~strcmp(computer('arch'),"win64")
        return
    end

    expectedAssociation="Unreal.ProjectFile";

    [~,assoc]=system("assoc .uproject");
    uprojectAssociation=strsplit(strtrim(assoc),"=");

    if strcmp(uprojectAssociation{2},expectedAssociation)
        return;
    end

    exception=MException(...
    "Sim3d:InvalidUprojectAssociation",...
    sprintf(...
    "Expected '%s' for win64 .uproject association but found '%s'",...
    expectedAssociation,...
    uprojectAssociation{2}...
    )...
    );
    throw(exception);
end