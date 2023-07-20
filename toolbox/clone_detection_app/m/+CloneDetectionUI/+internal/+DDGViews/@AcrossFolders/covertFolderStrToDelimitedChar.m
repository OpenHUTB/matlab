function s=covertFolderStrToDelimitedChar(obj)





    if(iscellstr(obj.selectedFolders))
        s=strjoin(obj.selectedFolders,';');
    else
        errordlg(DAStudio.message('sl_pir_cpp:creator:IllegalPath'));
    end
end
