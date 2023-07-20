
function[isexist,path]=which(inFileName)











    isexist=false;
    path='';



    [filePath,~,fileExt]=fileparts(inFileName);
    if isempty(fileExt)&&ispc
        inFileName=[inFileName,'.exe'];
    end


    if~isempty(filePath)
        if exist(inFileName,'file');
            isexist=true;
            path=filePath;
        end
        return;
    end


    envPath=getenv('PATH');
    envPathSep=regexp(envPath,['\s*',pathsep,'\s*'],'split');


    for ii=1:length(envPathSep)
        aPath=envPathSep{ii};

        if exist(aPath,'dir')
            searchStr=fullfile(aPath,inFileName);
            if exist(searchStr,'file');
                isexist=true;
                path=aPath;
                return;
            end
        end
    end
end


