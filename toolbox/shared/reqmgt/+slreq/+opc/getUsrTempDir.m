function usrTempDir=getUsrTempDir()
    usrTempDir=fullfile(tempdir,'RMI');


    if exist(usrTempDir,'file')~=7
        mkdir(usrTempDir);
    end


    if ispc
        usrTempDir=strrep(usrTempDir,filesep,'/');
    end
end