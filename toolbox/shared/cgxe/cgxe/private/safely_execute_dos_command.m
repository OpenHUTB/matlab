function[cmdFailed,dosOutput]=safely_execute_dos_command(targetDirectory,dosCommand)



    currDirectory=pwd;
    try
        cd(targetDirectory);
        [cmdFailed,dosOutput]=cgxe_dos(dosCommand);
        cd(currDirectory);
    catch ME
        cd(currDirectory);
        rethrow(ME);
    end
