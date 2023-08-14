function dlgstruct=getDialogSchema(this,name)%#ok





    entryselect.Name=DAStudio.message('RTW:tfldesigner:EntrySelectionText');
    entryselect.Type='radiobutton';
    entryselect.OrientHorizontal=false;
    entryselect.RowSpan=[1,6];
    entryselect.ColSpan=[1,5];
    selectableEntries={'Math Operation',...
    'Function',...
    'Blas Operation (Fortran)',...
    'CBlas Operation (Atlas)',...
    'Fixed Point Net Slope Operation',...
    'Semaphore/Mutex Entry'};
    if feature('CrtoolShowCustomization')>0
        selectableEntries{end+1}='Customization';
    end

    entryselect.Entries=selectableEntries;
    entryselect.Tag='Tfldesigner_EntrySelection';
    entryselect.Value=0;


    dlgstruct.DialogTitle=DAStudio.message('RTW:tfldesigner:FileNewEntryToolTip');
    dlgstruct.Sticky=true;
    dlgstruct.PreApplyMethod='applyproperties';
    dlgstruct.PreApplyArgsDT={'handle'};
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.StandaloneButtonSet={'OK','Cancel'};
    dlgstruct.Items={entryselect};



