function[srcFiles,srcFilesNoExt]=getFilesMatchingExtension(src_exts,folder)





    d=dir(folder);
    files={d.name};
    filesNoExt=cell(size(files));
    matchIdx=false(length(src_exts),length(files));
    for i=1:length(src_exts)
        src_ext=src_exts{i};


        src_ext=regexprep(src_ext,'^\*','','once');



        expr=[regexptranslate('wildcard',src_ext),'$'];
        tmpMatchIdx=cellfun(@(x)(~isempty(x)),regexp(files,expr,'once'));
        matchIdx(i,:)=tmpMatchIdx;


        filesNoExt(tmpMatchIdx)=regexprep(files(tmpMatchIdx),expr,'','once');
    end

    srcFiles=files(any(matchIdx,1));
    srcFilesNoExt=filesNoExt(any(matchIdx,1));



