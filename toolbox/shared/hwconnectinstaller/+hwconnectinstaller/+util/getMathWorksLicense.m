function out=getMathWorksLicense




    f=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources','license.txt');
    out=fileread(f);
end

