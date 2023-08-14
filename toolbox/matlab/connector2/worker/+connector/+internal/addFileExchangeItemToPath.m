function addFileExchangeItemToPath(fxid,forceFlag)








    if nargin<2
        forceFlag=false;
    end

    tmp=tempdir;
    fx='fx';
    localroot=fullfile(tmp,fx);

    newdir=num2str(fxid);
    dirname=fullfile(localroot,newdir);

    try
        if~exist(localroot,'dir')
            [success,msg]=mkdir(tmp,fx);
        end

        if~exist(dirname,'dir')||forceFlag

            [success,msg]=mkdir(localroot,newdir);

            fxurl=strcat('http://www.mathworks.com/matlabcentral/fileexchange/',fxid,'?controller=file_infos&download=true');
            unzip(fxurl,dirname);
            addpath(genpath(dirname));
        end
    catch err
        error('MATLAB:inet:experimental',err.message);
    end
