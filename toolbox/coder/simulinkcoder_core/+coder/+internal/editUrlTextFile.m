function editUrlTextFile(url)










    file=Simulink.document.parseFileURL(url);
    if exist(file,'file')
        edit(file);
    end
