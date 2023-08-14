function cb_browse(dlgHandle)




    titleString=getString(message('MATLAB:uistring:uiopen:DialogOpen'));

    filterArray={'*.mat',getString(message('sl_sta_editor_block:message:MATFileFilter'))};


    [filename,pathname]=uigetfile(filterArray,titleString);


    if(filename~=0)
        fullfilename=fullfile(pathname,filename);

        imd=DAStudio.imDialog.getIMWidgets(dlgHandle);
        tag='FileName';
        fileName=imd.find('Tag',tag);
        fileName.text=Simulink.signaleditorblock.FileUtil.getConciseFileNameForFile(fullfilename);
        Simulink.signaleditorblock.cb_signalPropertiesChanged(dlgHandle);
        dlgHandle.refresh();
    end

end
