function dlgStruct=constructDlgStruct(this,items,numRows,rStrech)




    block=this.getBlock;


    descText.Name=block.BlockDescription;
    descText.Type='text';
    descText.WordWrap=true;
    descText.RowSpan=[1,1];
    descText.ColSpan=[1,1];

    descGroup.Name=block.BlockType;
    descGroup.Type='group';
    descGroup.Items={descText};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,1];
    descGroup.LayoutGrid=[1,1];
    descGroup.RowStretch=0;
    descGroup.ColStretch=1;


    paramGroup.Name=DAStudio.message('Simulink:blkprm_prompts:AssignSelectParameters');
    paramGroup.Type='group';
    paramGroup.Items=items;
    paramGroup.LayoutGrid=[numRows,1];
    paramGroup.RowStretch=rStrech;
    paramGroup.ColStretch=ones(1,1);
    paramGroup.RowSpan=[2,2];
    paramGroup.ColSpan=[1,1];
    paramGroup.Source=block;




    dlgStruct.DialogTitle=DAStudio.message('Simulink:blkprm_prompts:BlockParameterDlg',block.Name);
    dlgStruct.Items={descGroup,paramGroup};


    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.ColStretch=[1];
    dlgStruct.ShowGrid=false;
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={block.Handle};

    dlgStruct.PreApplyMethod='PreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='CloseCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [isLib,isLocked]=this.isLibraryBlock(block);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end
