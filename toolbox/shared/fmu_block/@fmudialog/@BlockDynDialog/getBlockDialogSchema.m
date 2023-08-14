function dlgstruct=getBlockDialogSchema(this)




    block=this.getBlock();




    block_description.Name=DAStudio.message('FMUBlock:FMU:FMUIntrinsicBlockDescription');
    block_description.Type='text';

    description_group.Name=block.BlockType;
    description_group.Type='group';
    description_group.LayoutGrid=[1,1];
    description_group.Items={block_description};
    description_group.RowSpan=[1,1];
    description_group.ColSpan=[1,1];




    fmu_prompt.Name=block.IntrinsicDialogParameters.FMUName.Prompt;
    fmu_prompt.Type='text';
    fmu_prompt.WordWrap=true;
    fmu_prompt.RowSpan=[1,1];
    fmu_prompt.ColSpan=[1,1];

    fmu_path_edit.Type='edit';
    fmu_path_edit.Tag='FMUName';
    fmu_path_edit.Value=block.FMUName;
    fmu_path_edit.RowSpan=[2,2];
    fmu_path_edit.ColSpan=[1,9];
    fmu_path_edit.Enabled=~(Simulink.harness.internal.isHarnessCUT(block.Handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(block.Handle));

    fmu_browse.Type='pushbutton';
    fmu_browse.Tag='FMUBrowseButton';
    fmu_browse.ObjectMethod='onBrowseFMU';
    fmu_browse.FilePath=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','Open_16.png');
    fmu_browse.MethodArgs={'%dialog',fmu_path_edit.Tag};
    fmu_browse.ArgDataTypes={'handle','string'};
    fmu_browse.ToolTip=DAStudio.message('FMUBlock:FMU:BrowseFMUFile');
    fmu_browse.ColSpan=[10,10];
    fmu_browse.RowSpan=[2,2];
    fmu_browse.Enabled=~(Simulink.harness.internal.isHarnessCUT(block.Handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(block.Handle));


    fmu_path_group.Name='';
    fmu_path_group.Type='group';
    fmu_path_group.LayoutGrid=[2,10];
    fmu_path_group.Items={fmu_prompt,fmu_path_edit,fmu_browse};
    fmu_path_group.RowSpan=[2,2];
    fmu_path_group.ColSpan=[1,1];







    dlgstruct.Items={description_group,fmu_path_group};
    dlgstruct.LayoutGrid=[2,1];


    dlgstruct.PreApplyMethod='preApplyCallback';
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.PreApplyArgsDT={'handle'};


    dlgstruct.CloseMethod='closeCallback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};
