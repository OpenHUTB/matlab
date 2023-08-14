






function checksum=getFileChecksum(file)

    try
        checksum=Simulink.getFileChecksum(file);
    catch E


        DAStudio.error('Slci:slci:ERROR_GETFILECHECKSUM',file);
    end

end
