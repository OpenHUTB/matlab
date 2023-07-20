function viewCSC(h)





    fileinfo=h.cscRegFile;
    filepath=fileinfo{1};
    filename=fileinfo{2};
    fileext=fileinfo{3};

    div=filesep;
    filelong=[filepath,div,filename,fileext];

    if isempty(filepath)||isempty(filename)
        msg=DAStudio.message('Simulink:dialog:CSCUICSCRegPathEmpty');
        errordlg(msg,...
        DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        return;
    end


    edit(filelong);



