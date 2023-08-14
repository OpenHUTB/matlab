function fullPath=get_report_file_name(modelName,varargin)







    reproduce=0;
    fileDir=pwd;
    for k=1:2:numel(varargin)
        switch lower(varargin{k})
        case 'filedir'
            if~isempty(varargin{k+1})
                fileDir=varargin{k+1};
            end
        case 'reproduce'
            reproduce=varargin{k+1};
        end
    end

    fileName=[modelName,'_cov.html'];

    fullPath=fullfile(fileDir,fileName);
    if exist(fullPath,'file')
        [succ,userWrite]=cvi.ReportUtils.checkUserWrite(fullPath);
        if succ&&~userWrite
            baseName=[modelName,'_cov'];
            fullPath=unique_file_name_using_numbers(fileDir,baseName,'.html',reproduce);
        end
    end

    function fullPath=unique_file_name_using_numbers(path,baseName,ext,reproduce)

        origBaseName=strtok(baseName,'.');

        if(any(origBaseName(end)=='0123456789'))
            baseName=[origBaseName,'_'];
        end
        charIdx=length(baseName)+1;
        existFiles=dir(fullfile(path,[baseName,'*',ext]));

        number=1;

        if~isempty(existFiles)
            for fileIdx=1:length(existFiles)
                [cPath,cName,cExt]=fileparts(existFiles(fileIdx).name);%#ok
                suffix=cName(charIdx:end);
                numValue=str2num(suffix);%#ok
                if~isempty(numValue)&&numValue>=number
                    number=numValue+1;
                end
            end
        end
        if reproduce
            if number>1
                fileName=[baseName,num2str(number-1),ext];
            else
                fileName=[origBaseName,ext];
            end
        else
            fileName=[baseName,num2str(number),ext];
        end
        fullPath=fullfile(path,fileName);

