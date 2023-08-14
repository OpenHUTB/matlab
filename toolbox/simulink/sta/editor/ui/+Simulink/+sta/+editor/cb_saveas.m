function[gotExported,errMsg]=cb_saveas(sigIDs,fileToSave,isAppend,appInstanceID)




    [gotExported,errMsg]=Simulink.sta.exportdialog.exportToFile(sigIDs,fileToSave,isAppend);

    if gotExported

        [~,fileName,ext]=fileparts(fileToSave);

        theFullFile=fileToSave;


        if isempty(ext)
            ext='.mat';
            theFullFile=[fileToSave,ext];
        end

        theFile=[fileName,ext];
        updateSignalSource(sigIDs,theFile,theFullFile,appInstanceID,'staeditor');
    end


