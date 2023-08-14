function out=getMathWorksUSRPLicense




    f=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources','usrp_license.txt');
    out=fileread(f);
end

