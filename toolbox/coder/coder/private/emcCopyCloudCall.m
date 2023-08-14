function out=emcCopyCloudCall(targetDir)


    baseName='cloudCall';
    datafile='getData';

    src=fullfile(matlabroot,'toolbox','coder','coder','rtw','c','src',[baseName,'.h']);
    copyfile(src,fullfile(targetDir,[baseName,'.h']),'f');

    src=fullfile(matlabroot,'toolbox','coder','coder','rtw','c','src',[baseName,'.c']);
    copyfile(src,fullfile(targetDir,[baseName,'.c']),'f');

    src=fullfile(matlabroot,'toolbox','coder','coder','rtw','c','src',[datafile,'.c']);
    copyfile(src,fullfile(targetDir,[datafile,'.c']),'f');

    out=0;
end
