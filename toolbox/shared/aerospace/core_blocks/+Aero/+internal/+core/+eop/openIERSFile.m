function openIERSFile(dlgHandle)






    titleString=getString(message('MATLAB:uistring:uiopen:DialogOpen'));


    [filename,pathname]=uigetfile(...
    {'*.mat',getString(message('Simulink:dialog:SL_DSCPT_FROMFILE_BROWSE_FILTER'))},...
    titleString);


    if(filename~=0)
        fullfilename=fullfile(pathname,filename);

        imd=DAStudio.imDialog.getIMWidgets(dlgHandle);
        tag=getString(message('aerospace:eop:sourceFile'),matlab.internal.i18n.locale('en_US'));
        fileName=imd.find('Tag',tag);


        pathnameCmp=pathname(1:end-1);
        currentdir=pwd;

        if strcmp(pathnameCmp,currentdir)||~contains(path,pathnameCmp)
            fileName.text=filename;
        else
            fileName.text=fullfilename;
        end
    end

end
