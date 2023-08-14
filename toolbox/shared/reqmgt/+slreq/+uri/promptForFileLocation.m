function chosenPath=promptForFileLocation(suggestedFilePath)



    [~,~,fExt]=fileparts(suggestedFilePath);
    if isempty(fExt)
        typeOption='*.*';
        dlgTitle=getString(message('Slvnv:slreq_import:FileToUpdateFrom',''));
    else
        typeOption=['*',fExt];
        dlgTitle=getString(message('Slvnv:slreq_import:FileToUpdateFrom',fExt));
    end

    [filename,pathname]=uigetfile(typeOption,dlgTitle,suggestedFilePath);
    if isequal(filename,0)

        chosenPath='';
    else

        chosenPath=fullfile(pathname,filename);
    end
end
