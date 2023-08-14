function dlgstruct=getDialogSchema(this,unused)%#ok<INUSD>




























    block=this.getBlock();

    blockEscapedStr=strrep(block.getFullName(),'''','''''');

    if strcmp(block.Mask,'off')||strcmp(block.BlockParametersCall,'on')


        dlgstruct=this.getBlockDialogSchema();

        dlgstruct.HelpMethod='eval';
        dlgstruct.HelpArgs={['fmudialog.fmuHelp(''',blockEscapedStr,''', false)']};
        dlgstruct.DefaultOk=true;
    else


        dlgstruct=this.getMaskDialogSchema();

        dlgstruct.HelpMethod='eval';
        dlgstruct.HelpArgs={['fmudialog.fmuHelp(''',blockEscapedStr,''', true)']};
        dlgstruct.DefaultOk=false;
    end

    dlgstruct.DialogTitle=DAStudio.message('Simulink:blkprm_prompts:BlockParameterDlg',block.Name);
    dlgstruct.DialogTag='fmu_ddg';
    dlgstruct.ExplicitShow=true;

    [~,isLocked]=this.isLibraryBlock(block);
    if isLocked
        dlgstruct.DisableDialog=1;
    else
        dlgstruct.DisableDialog=0;
    end
