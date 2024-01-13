% 获得以索引数字结尾的唯一目录
function[dirName,existingDir]=genUniqueDirName(dirName)

    rootDir=dirName;
    existingDir='';
    index=0;

    % windows 下如果以 \ 开头则表示是相对路径，前面需要补充当前路径
    if ispc&&startsWith(rootDir,filesep)
        rootDir=fullfile(pwd,rootDir);
    end

    % 后面添加表示第几个文件的数字，如果存在则索引+1
    while exist(rootDir,'dir')==7
        existingDir=rootDir;
        index=index+1;
        rootDir=sprintf('%s_%d',dirName,index);
    end

    dirName=rootDir;
