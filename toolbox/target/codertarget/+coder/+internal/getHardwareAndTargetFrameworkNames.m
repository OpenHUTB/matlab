function[ret,targetNames,targetFrameworkNames]=getHardwareAndTargetFrameworkNames






    targetNames=coder.internal.getHardwareNames();


    targetFrameworkNames={};
    try
        tfHardware=codertarget.utils.getTargetFrameworkBoardEntries();
        for k=1:numel(tfHardware)
            targetFrameworkNames{end+1}=tfHardware(k).str;%#ok<AGROW>
        end
    catch
    end

    ret=unique([targetNames,targetFrameworkNames]);
