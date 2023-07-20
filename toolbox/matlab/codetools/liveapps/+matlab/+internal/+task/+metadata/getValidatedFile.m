function validatedFullFileName=getValidatedFile(inputFile,fileExtension)



















    if~ischar(inputFile)&&~(isstring(inputFile)&&isscalar(inputFile))
        error(message('rich_text_component:liveApps:InvalidInput'));
    end
    inputFile=char(inputFile);

    [filepath,file,ext]=fileparts(inputFile);


    if iskeyword(file)
        error(message('rich_text_component:liveApps:FileNameIsKeyword'));
    end


    if~isvarname(file)
        error(message('rich_text_component:liveApps:FileNameIsVarName',file));
    end



    if isempty(ext)
        ext=fileExtension;
    elseif~strcmp(ext,fileExtension)
        error(message('rich_text_component:liveApps:InvalidGeneralFileExtension',inputFile,fileExtension));
    end



    if isempty(filepath)
        filepath=cd;
    elseif~isfolder(filepath)
        error(message(('rich_text_component:liveApps:InvalidFilePath')));
    end


    validatedFullFileName=fullfile(filepath,[file,ext]);
end