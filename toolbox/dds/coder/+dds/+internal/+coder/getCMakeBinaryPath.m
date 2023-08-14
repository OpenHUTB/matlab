function[aPath,version]=getCMakeBinaryPath(minVer)










    cmdmap=containers.Map({'win64','maci64','glnxa64'},...
    {'where cmake',...
    'which cmake',...
    'which cmake'});...
    cmd=cmdmap(computer('arch'));
    [status,result]=system(cmd);
    if status~=0
        exemap=containers.Map({'win64','maci64','glnxa64'},...
        {'cmake.exe',...
        'cmake',...
        'cmake'});...
        shippingCmake=fullfile(matlabroot,'bin',computer('arch'),'cmake','bin',exemap(computer('arch')));
        if isfile(shippingCmake)
            result=shippingCmake;
        else
            error(message('dds:util:CMakeNotFound',minVer));
        end
    end
    aPath=strsplit(strtrim(result),'\n');
    aPath=['"',aPath{1},'"'];
    [status,result]=system([aPath,' --version']);
    if status~=0
        error(message('dds:util:CMakeNotFound',minVer));
    end



    cmakeVerTextIndx=strfind(lower(result),'cmake version');

    trimmedVersionText=result(cmakeVerTextIndx:end);
    resSplit=strsplit(trimmedVersionText);
    version=dds.internal.coder.getVersionVal(resSplit{3});
    reqVersion=dds.internal.coder.getVersionVal(minVer);
    if version<reqVersion
        error(message('dds:util:CMakeNotFound',minVer));
    end
end