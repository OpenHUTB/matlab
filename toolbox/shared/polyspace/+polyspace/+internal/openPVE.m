function openPVE(resDir)



    if nargin<1
        resDir='';
    end

    pslinkprivate('enableCOMServer');

    exeExt='';
    if ispc
        exeExt='.exe';
    end

    cmd=sprintf('%s%s -matlab %s',...
    fullfile(matlabroot,'polyspace','bin','polyspace'),...
    exeExt,matlabroot);

    if~isempty(resDir)&&exist(resDir,'dir')
        cmd=sprintf('%s -default-dir %s',cmd,resDir);
    end

    cmd=[cmd,' &'];
    system(cmd);
