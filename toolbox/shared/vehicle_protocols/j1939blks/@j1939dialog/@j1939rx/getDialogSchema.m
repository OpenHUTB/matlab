function dlgStruct=getDialogSchema(obj,~)













    rowSpan=[1,1];
    colSpan=[1,20];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);



    paramPane=j1939.internal.createBlockPane(obj);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'j1939.j1939slcbpreapply','closeCallback');


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if(isLibrary&&isLocked)||any(strcmp(obj.Root.SimulationStatus,{'running','paused','external'}))
        dlgStruct.DisableDialog=true;
    end
end
