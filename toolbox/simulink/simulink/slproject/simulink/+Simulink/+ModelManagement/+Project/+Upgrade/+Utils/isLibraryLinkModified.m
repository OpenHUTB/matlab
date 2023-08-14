function modified=isLibraryLinkModified(block)

    status=get_param(block,'LinkStatus');
    version=get_param(block,'LibraryVersion');
    modified=strcmp(status,'inactive')&&strncmp(version,'*',1);
end

