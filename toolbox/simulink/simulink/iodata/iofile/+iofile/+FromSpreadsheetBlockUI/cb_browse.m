function cb_browse(dlgHandle)




    titleString=getString(message('MATLAB:uistring:uiopen:DialogOpen'));

    filterArray={'*.xls; *.xlsx',getString(message('sl_iofile:excelfile:Spreadsheet'))};

    if ispc
        filterArray{2,1}='*.csv';
        filterArray{2,2}=getString(message('sl_iofile:excelfile:TextFiles'));

    end


    [filename,pathname]=uigetfile(filterArray,titleString);


    if(filename~=0)
        fullfilename=fullfile(pathname,filename);

        imd=DAStudio.imDialog.getIMWidgets(dlgHandle);
        tag='File name:';
        fileName=imd.find('Tag',tag);


        pathnameCmp=pathname(1:end-1);
        currentdir=pwd;

        if strcmp(pathnameCmp,currentdir)||~isempty(strfind(path,pathnameCmp))
            fileName.text=filename;
        else
            fileName.text=fullfilename;
        end
    end

end

