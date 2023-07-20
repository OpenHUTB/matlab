function createIERSFile(dlgHandle)






    imd=DAStudio.imDialog.getIMWidgets(dlgHandle);


    tag=getString(message('aerospace:eop:fileTag'));
    fileDestination=imd.find('Tag',tag);
    if strcmpi(fileDestination.text,'current folder')||...
        strcmpi(fileDestination.text,'pwd')
        fileDest=pwd;
    else
        fileDest=fileDestination.text;
    end


    tag=getString(message('aerospace:eop:urlTag'));
    dataFileLocation=imd.find('Tag',tag);


    fileStr=aeroReadIERSData(fileDest,'url',dataFileLocation.text);


    tag=getString(message('aerospace:eop:sourceFile'));
    file=imd.find('Tag',tag);


    file.text=fileStr;
