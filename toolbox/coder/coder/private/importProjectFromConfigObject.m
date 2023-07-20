



function importProjectFromConfigObject(project,variableName)
    c=evalin('base',variableName);
    copyConfigObjectToProject(c,project);
end
