



function dlgstruct=getSlimDocDDG(source,h)
    txt.Type='text';
    txt.Name=DAStudio.message('Simulink:masks:DocBlockEmbeddedCoderFlagLabel_MP');

    edit.Type='edit';
    edit.Tag='ecoderFlagEdit';
    edit.Value=get_param(source,'ECoderFlag');
    edit.MatlabMethod='slimDocDDG_cb';
    edit.MatlabArgs={'%dialog','%source','%tag','%value'};

    cmb.Type='combobox';
    cmb.Tag='docTypeCmb';
    cmb.Name=DAStudio.message('Simulink:masks:DocBlockDocTypeLabel_MP');
    cmb.Entries={'Text','RTF','HTML'};
    cmb.Value=getCurrentTypeSelection(get_param(source,'DocumentType'),cmb.Entries)-1;
    cmb.MatlabMethod='slimDocDDG_cb';
    cmb.MatlabArgs={'%dialog','%source','%tag','%value'};


    blk=source.getBlock;
    [content,format]=docblock('getContent',blk.getFullName);
    if strcmpi(format,'RTF_ZIP')
        content=docblock('uncompressRTFData',content);
    end

    filePath=docblock('getBlockFileName',blk.getFullName);

    spacer.Type='panel';
    spacer.Enabled=false;


    matlabeditor.Type='matlabeditor';
    matlabeditor.MatlabEditorFeatures={'LineNumber'};
    matlabeditor.Tag='contentEditor';
    if isempty(content)&&isa(content,'double')
        matlabeditor.Value=getString(message('SimulinkBlocks:docblock:TypeDocumentationHere'));
    else
        matlabeditor.Value=content;
    end
    matlabeditor.MatlabMethod='slimDocDDG_cb';
    matlabeditor.MatlabArgs={'%dialog','%source','%tag','%value'};


    webbrowser.Type='webbrowser';
    webbrowser.Tag='webbrowser';
    webbrowser.WebKit=true;

    if~exist(filePath,'file')...
        &&(strcmp(content,getString(message('SimulinkBlocks:docblock:TypeDocumentationHere')))...
        ||isempty(content))

        webbrowser.Visible=false;
    else
        webbrowser.HTML=content;
        webbrowser.Visible=true;
    end
    webbrowser.DisableContextMenu=true;

    htmlBtn.Type='pushbutton';
    htmlBtn.Tag='htmlBtn';
    htmlBtn.Name='Edit';
    htmlBtn.MatlabMethod='slimDocDDG_cb';
    htmlBtn.MatlabArgs={'%dialog','%source','%tag',0};

    htmlPnl.Type='panel';
    htmlPnl.Items={spacer,htmlBtn,spacer};
    htmlPnl.LayoutGrid=[1,3];
    htmlPnl.ColStretch=[1,0,1];



    rtfBtn.Type='pushbutton';
    rtfBtn.Tag='rtfBtn';
    rtfBtn.Name='Edit';
    rtfBtn.MatlabMethod='slimDocDDG_cb';
    rtfBtn.MatlabArgs={'%dialog','%source','%tag',0};

    btnPnl.Type='panel';
    btnPnl.Items={spacer,rtfBtn,spacer};
    btnPnl.LayoutGrid=[1,3];
    btnPnl.ColStretch=[1,0,1];



    dlgstruct.Items={txt,edit,cmb};
    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag='Simulink:Dialog:Parameters';
    dlgstruct.DialogMode='Slim';
    dlgstruct.CloseMethod='closeCallback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};
    dlgstruct.EmbeddedButtonSet={[]};
    dlgstruct.StandaloneButtonSet={[]};

    switch get_param(source,'DocumentType')
    case 'Text'
        dlgstruct.Items{4}=matlabeditor;
        dlgstruct.RowStretch=[0,0,0,1];
        dlgstruct.LayoutGrid=[4,1];
    case 'HTML'
        if webbrowser.Visible
            dlgstruct.Items{4}=webbrowser;
            dlgstruct.Items{5}=htmlPnl;
            dlgstruct.RowStretch=[0,0,0,1,0];
            dlgstruct.LayoutGrid=[5,1];
        else
            dlgstruct.Items{4}=htmlPnl;
            dlgstruct.Items{5}=spacer;
            dlgstruct.RowStretch=[0,0,0,0,1];
            dlgstruct.LayoutGrid=[5,1];
        end
    case 'RTF'
        dlgstruct.Items{4}=btnPnl;
        dlgstruct.RowStretch=[0,0,0,0,1];
        dlgstruct.LayoutGrid=[5,1];
    end

end


function index=getCurrentTypeSelection(format,entries)
    indexC=strfind(entries,format);
    index=find(not(cellfun('isempty',indexC)));
end
