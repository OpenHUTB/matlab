function prefix=syncTestPrefix(modelH)

    prefix='';
    [~,dirName]=rmisync.syncTestMode();

    modelName=get_param(modelH,'Name');
    fileName=fullfile(dirName,[modelName,'_prefix.txt']);
    if exist(fileName,'file')
        fid=fopen(fileName,'r');
        prefix=fgetl(fid);
        fclose(fid);
    end
