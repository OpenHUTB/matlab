function out=getMathWorksPrereleaseLicense




    f=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources','prerelease_license.txt');
    out=fileread(f);
end

