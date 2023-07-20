function checkMATLABInstallDir()


    try
rtw_checkdir
    catch ME
        except=MException("Simulink:Compiler:InvalidWorkingDirectory",...
        message("RTW:buildProcess:buildDirInMatlabDir",pwd));
        except.addCause(ME);
        throw(except);
    end
end

