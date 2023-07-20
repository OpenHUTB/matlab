function[group,newRow]=createInstanceInfoWidget(dlgSrc,currRow)

    group.Name='';
    group.Type='group';
    group.Tag='CodeContextInstanceInfoGroupTag';
    if~isa(dlgSrc,'Simulink.libcodegen.dialogs.codeContextViewDialog')
        group.Name=DAStudio.message('Simulink:CodeContext:InstanceInformation');
    end
    group.Items={};
    [items,currRow]=addFileNameUI(dlgSrc,currRow);
    group.Items={group.Items{:},items{:}};%#ok
    [items,newRow]=addSpecifyCUTUI(dlgSrc,currRow);
    group.Items={group.Items{:},items{:}};%#ok
end

function[items,newRow]=addFileNameUI(dlgSrc,currRow)

    if isa(dlgSrc,'Simulink.libcodegen.dialogs.codeContextViewDialog')
        specInst.Type='text';
        specInst.Name=DAStudio.message('Simulink:CodeContext:SpecifyInstance');
        specInst.Tag='CodeContextCreateInstanceCBoxTag';
    else
        specInst=Simulink.harness.internal.getCheckBoxSrc(...
        'Simulink:CodeContext:SpecifyInstance',...
        'specifyInstance',...
        'CodeContextCreateInstanceCBoxTag');
        specInst.Enabled=true;
    end

    specInst.Alignment=1;
    specInst.RowSpan=[currRow,currRow];
    specInst.ColSpan=[1,7];

    currRow=currRow+1;

    lbl.Name=DAStudio.message('Simulink:CodeContext:InstanceFileName');
    lbl.Type='text';
    lbl.Buddy='CodeContextCreateDlgFileNameLblTag';
    lbl.Alignment=1;
    lbl.RowSpan=[currRow,currRow];
    lbl.ColSpan=[1,3];

    edit.Type='edit';
    edit.ObjectProperty='instanceFileName';
    edit.Mode=true;
    edit.Tag='CodeContextCreateDlgFileNameEditTag';
    edit.RowSpan=[currRow,currRow];
    edit.ColSpan=[4,6];
    edit.DialogRefresh=true;
    edit.MatlabMethod='Simulink.libcodegen.dialogs.shared.InstanceFileNameCallback';
    edit.MatlabArgs={dlgSrc};
    edit.Enabled=dlgSrc.specifyInstance;
    edit.Graphical=true;

    btn.Type='pushbutton';
    btn.Name=DAStudio.message('Simulink:CodeContext:BrowseBtn');
    btn.Enabled=true;
    btn.MaximumSize=[80,40];
    btn.RowSpan=[currRow,currRow];
    btn.ColSpan=[7,7];
    btn.Tag='CodeContextCreateFileBrowseBtn';
    btn.Mode=true;
    btn.DialogRefresh=true;
    btn.MatlabMethod='Simulink.libcodegen.dialogs.shared.BrowseButtonCallback';
    btn.MatlabArgs={dlgSrc};
    btn.Enabled=dlgSrc.specifyInstance;

    panel.Type='panel';
    panel.LayoutGrid=[3,7];
    panel.Items={specInst,lbl,edit,btn};

    items={panel};
    newRow=currRow+1;
end

function[items,newRow]=addSpecifyCUTUI(dlgSrc,currRow)
    CUTCandidates=dlgSrc.cutCandidates';
    numCandidates=length(CUTCandidates);
    CUTVals=zeros(1,numCandidates);
    for i=1:numCandidates
        CUTVals(i)=i;
    end

    specifyCUTCBox=Simulink.harness.internal.getComboBoxSrc(...
    'Simulink:CodeContext:InstancePath',...
    'CodeContextCreateDlgNameComboBoxTag',...
    CUTCandidates,...
    CUTVals);
    specifyCUTCBox.Mode=true;
    specifyCUTCBox.ObjectProperty='cutName';
    specifyCUTCBox.Alignment=0;
    specifyCUTCBox.Enabled=true;
    specifyCUTCBox.RowSpan=[currRow,currRow];
    specifyCUTCBox.ColSpan=[1,1];
    specifyCUTCBox.Enabled=dlgSrc.specifyInstance;
    specifyCUTCBox.DialogRefresh=true;
    specifyCUTCBox.Graphical=true;

    items={specifyCUTCBox};
    newRow=currRow+1;
end
