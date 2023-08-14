function out=getSourceFileNames(names)




    out={};

    for k=1:length(names)
        [pathName,fileName,fileExt]=fileparts(names{k});
        if ismember(fileExt,{'.c','.cpp','.h','.hpp'})
            out=[out;names{k}];
        end
    end