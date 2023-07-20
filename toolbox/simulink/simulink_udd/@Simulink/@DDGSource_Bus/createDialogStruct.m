function[dlgStruct]=createDialogStruct(source,block,descriptionGroup,parameterGroup)



    locked=get_param(bdroot(block.Handle),'Lock');
    linkStatus=get_param(block.Handle,'LinkStatus');
    isLibraryLink=~strcmp(locked,'on')&&...
    (strcmp(linkStatus,'implicit')||strcmp(linkStatus,'resolved'));

    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',...
    strrep(block.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag=source.getBlock.BlockType;
    dlgStruct.Items={descriptionGroup,parameterGroup};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.DisableDialog=block.isHierarchySimulating||isLibraryLink;
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={block.Handle};

    dlgStruct.PreApplyMethod='PreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='CloseCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

end

