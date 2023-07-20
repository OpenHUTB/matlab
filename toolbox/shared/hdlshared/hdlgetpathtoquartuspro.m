
function path=hdlgetpathtoquartuspro


    try
        toolBinary='qpro';
        [status,toolDir]=downstream.AvailableToolList.simplewhich(toolBinary);
        if(status)

            exePath=fullfile(toolDir,toolBinary);
            [binPath,~]=fileparts(exePath);
            path=fullfile(strtrim(binPath),'..');
            path=strrep(path,'\','/');
            return;
        end
    catch
    end
    topSubsystem=hdlgetparameter('hdl_subsystem');
    di=downstream.integration('Model',topSubsystem,'keepCodegenDir',true);
    try
        di.set('Tool','Intel Quartus Pro');
        path=di.getToolPath;
    catch me
        rethrow(me);
    end
