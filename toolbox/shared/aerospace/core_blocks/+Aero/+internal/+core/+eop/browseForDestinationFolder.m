function browseForDestinationFolder(dlgHandle)








    folder=uigetdir;



    if folder~=0

        imd=DAStudio.imDialog.getIMWidgets(dlgHandle);

        tag=getString(message('aerospace:eop:fileTag'));
        fileDestination=imd.find('Tag',tag);
        fileDestination.text=folder;
    end
