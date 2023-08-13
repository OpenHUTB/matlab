function normlizedfullFileName=normalizeFullFileName(fullFileName,expectedExtension)

    [filePath,file,ext]=fileparts(fullFileName);
    passedInFileName=[file,ext];


    mFileNames=dir(fullfile(filePath,['*',expectedExtension]));

    if~any(strcmp(passedInFileName,{mFileNames.name}))



        idx=cellfun(@(name)strcmpi(name,passedInFileName),{mFileNames.name});

        if any(idx)

            normlizedfullFileName=fullfile(filePath,mFileNames(idx).name);
        else
            error(message('rich_text_component:liveApps:InvalidFileName',fullFileName));
        end
    else
        normlizedfullFileName=fullFileName;
    end
end

