







function checkRunningProcesses(exlcudeProcesses)
mlock
    persistent PROCESSESHASHVAL
    commandToRun="ps -U $USER -o comm";
    if nargin==1
        commandToRun=commandToRun+"| grep -vE '"+exlcudeProcesses+"'";
    end

    [~,cmdout]=system(commandToRun+" | sort | uniq -u | md5sum | cut -b-32");

    if isempty(PROCESSESHASHVAL)
        PROCESSESHASHVAL=cmdout;
        return
    end

    if strcmp(PROCESSESHASHVAL,cmdout)
        return
    else
        [~,cmdout]=system(commandToRun);
        error("one or more processes has been created or terminated:"+cmdout)
    end
end