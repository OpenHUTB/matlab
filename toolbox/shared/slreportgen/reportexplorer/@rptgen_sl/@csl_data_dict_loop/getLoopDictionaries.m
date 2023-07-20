function hList=getLoopDictionaries(this,varargin)






    if strcmp(this.LoopType,'list')
        hList=locNormalizeDictionaryList(this);
    else
        hList=locFindDictionaries;
    end

    hList=transpose(hList);


end

function dictList=locFindDictionaries()




    pSep=pathsep;



    if isempty(strfind(lower(path),[lower(pwd),pSep]));
        pathString=[pSep,pwd,pSep,path,pSep];
    else
        pathString=[pSep,path,pSep];
    end

    breakIndex=strfind(pathString,pSep);

    lastIndex=length(breakIndex)-1;
    dirIdx=1;


    searchTerm=[filesep,'*','.sldd'];

    dictList={};
    while dirIdx<=lastIndex
        myDir=pathString(breakIndex(dirIdx)+1:breakIndex(dirIdx+1)-1);
        fileList=dir([myDir,searchTerm]);
        if~isempty(fileList)
            for fileIdx=1:length(fileList)
                fileName=fileList(fileIdx).name;
                dictList=[dictList,{fullfile(myDir,fileName)}];%#ok<AGROW>
            end
        end
        dirIdx=dirIdx+1;
    end

end

function dictList=locNormalizeDictionaryList(this)

    dictList={};
    nDicts=numel(this.DictionariesList);
    for i=1:nDicts
        dictPath=rptgen.parseExpressionText(this.DictionariesList{i});
        [folder,name,ext]=fileparts(dictPath);

        if isempty(ext)
            ext='.sldd';
        else
            if~strcmpi(ext,'.sldd')
                error(msg(this,'errorInvalidDictPath',dictPath));
            end
            ext=lower(ext);
        end

        dictPath=[name,ext];

        if isempty(folder)
            dictPathTemp=which(dictPath);
            if isempty(dictPathTemp)
                error(msg(this,'errorDictNotFound',dictPath));
            end
            dictPath=dictPathTemp;
        else
            dictPath=fullfile(folder,dictPath);
        end

        dictList=[dictList,{dictPath}];%#ok<AGROW>

    end

end





