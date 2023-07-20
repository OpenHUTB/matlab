function str=get_help_str()




    helpFile=fullfile(matlabroot,'toolbox','shared','cgxe','cgxe','+CGXE','+Debug','cgxe_debug_help.txt');

    fd=fopen(helpFile,'r');
    F=fread(fd);
    fclose(fd);

    str=char(F');
end
