function saveGrp=getSchema_saveGrp(hUI)



    filepath=hUI.RegFileInfo{1};
    filename=hUI.RegFileInfo{2};
    fileext=hUI.RegFileInfo{3};
    filelong=[filepath,filesep,filename,fileext];





    tmpLoc=LocalPathBrief(filepath,50);

    fileLoc.Name=DAStudio.message('Simulink:dialog:CSCUILocation',tmpLoc);
    fileLoc.ToolTip=DAStudio.message('Simulink:dialog:CSCUIToolTipPathSave',filelong);
    fileLoc.Type='text';
    fileLoc.Tag='tLocationText';
    fileLoc.Mode=1;
    fileLoc.DialogRefresh=1;





    saveButton.Name=DAStudio.message('Simulink:dialog:CSCUISaveDefns');
    saveButton.Type='pushbutton';
    saveButton.Tag='tSaveButton';
    saveButton.ObjectMethod='saveCurrPackage';
    saveButton.Mode=1;
    saveButton.DialogRefresh=1;


    isRegFileReadOnly=hUI.isCSCRegFileReadOnly;
    saveButton.Enabled=~isRegFileReadOnly;






    saveGrp.Name=DAStudio.message('Simulink:dialog:CSCUIFileName',filename,fileext);
    saveGrp.Type='group';
    saveGrp.Tag='tSaveGroup';
    saveGrp.LayoutGrid=[1,3];

    fileLoc.RowSpan=[1,1];
    fileLoc.ColSpan=[1,2];
    saveButton.RowSpan=[1,1];
    saveButton.ColSpan=[3,3];

    saveGrp.Items={fileLoc,saveButton};
    saveGrp.ColStretch=[0,1,0];





    function rtn=LocalPathBrief(orig_path,brief_len)
        if(length(orig_path)<=brief_len)
            rtn=orig_path;
        else
            keep_len=brief_len-3;
            rtn=[orig_path(1:keep_len),'...'];
        end




