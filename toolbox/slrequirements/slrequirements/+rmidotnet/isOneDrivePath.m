function tf=isOneDrivePath(docPath)
    tf=contains(docPath,[getenv('USERNAME'),filesep,'OneDrive']);
end
