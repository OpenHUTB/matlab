function regeneratePCode(file,source)

    cwd=pwd;
    cleanup=onCleanup(@()cd(cwd));
    folder=fileparts(file);

    cd(folder);
    pcode(source);

end

