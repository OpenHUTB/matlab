function[files,resolved,includepaths]=...
    resolveCustomCode(modelFile,userIncludePaths,userSrcFiles,userLibFiles,customCodeString)










    modelPath=fileparts(modelFile);



    if~isempty(userIncludePaths)
        includepaths=CGXE.Utils.tokenize(modelPath,userIncludePaths,'',{});
        if~isempty(modelPath)
            searchpath=[includepaths,{modelPath}];
        else
            searchpath=includepaths;
        end
    else
        includepaths={};
        searchpath={};
    end
    searchpath=do_ordered_unique_paths(searchpath);



    mlPath=strsplit(path,pathsep);
    filter=strncmp(mlPath,matlabroot,length(matlabroot));
    mlPath(filter)=[];
    searchpath=[searchpath,mlPath];
    searchpath=do_ordered_unique_paths(searchpath);



    pattern='"[^"]+"|[^\n\t\f ;,]+';
    userSrcFiles=regexp(userSrcFiles,pattern,'match');
    userSrcResolved=false(size(userSrcFiles));


    for i=1:numel(userSrcFiles)
        [userSrcFiles{i},userSrcResolved(i)]=i_resolve_file(...
        userSrcFiles{i},modelPath,searchpath);
    end


    userLibFiles=regexp(userLibFiles,pattern,'match');
    userLibResolved=false(size(userLibFiles));
    for i=1:numel(userLibFiles)
        [userLibFiles{i},userLibResolved(i)]=i_resolve_file(...
        userLibFiles{i},modelPath,searchpath);
    end

    [custcodefiles,custcoderesolved]=i_parse_includestatements(...
    customCodeString,modelPath,searchpath);

    files=[userSrcFiles,userLibFiles,custcodefiles];
    resolved=[userSrcResolved,userLibResolved,custcoderesolved];

end


function[resolvedfile,isresolved]=i_resolve_file(filename,directory,searchpath)

    [resolvedfile,errmsg]=CGXE.Utils.tokenize(...
    directory,filename,'',searchpath);
    if~isempty(errmsg)

        resolvedfile=filename;
        isresolved=false;
    else
        resolvedfile=resolvedfile{1};
        isresolved=true;
    end
end


function orderedList=do_ordered_unique_paths(orderedList)

    if ispc
        orderedList=RTW.unique(orderedList,...
        'ignorecase','removetrailingfilesep');
    else
        orderedList=RTW.unique(orderedList);
    end
end


function[files,isresolved]=i_parse_includestatements(customCodeString,...
    rootDirectory,searchDirectories)




    [s,e]=regexp(customCodeString,'#include\s*\"[^\"\n]+\"');

    files=cell(size(s));
    isresolved=false(size(s));

    for jj=1:length(s)
        includeStr=customCodeString(s(jj):e(jj));
        [s1,e1]=regexp(includeStr,'\"[^\"]+\"','once');
        files{jj}=includeStr(s1+1:e1-1);

        [foundFile,errorStr]=CGXE.Utils.tokenize(rootDirectory,...
        files{jj},'include file',searchDirectories);

        if isempty(errorStr)

            files{jj}=foundFile{1};
            isresolved(jj)=true;
        end
    end
    keep=~cellfun('isempty',files);
    files=files(keep);
    isresolved=isresolved(keep);
end
