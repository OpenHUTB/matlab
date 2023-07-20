function dlg=getDialogSchema(this,~)





    if isempty(this.fSigSelWid)
        this.createSignalSelector();
    end


    sigviewgroup=getDialogSchema(this.fSigSelWid,'');

    sigviewgroup.Items{5}.ExpandTree=true;
    sigviewgroup.Items{5}.TreeSelectItems={1};

    grpDescription=struct;
    grpDescription.Name='';
    grpDescription.Type='group';
    grpDescription.Items={sigviewgroup};
    grpDescription.RowSpan=[1,1];
    grpDescription.ColSpan=[1,3];
    grpDescription.Source=this.fSigSelWid;



    if get_param(this.fmodel,'ModelSlicerActive')
        slicerAddStartButton=struct;
        slicerAddStartButton.Name='Add Starting Point';
        slicerAddStartButton.Tag='add';
        slicerAddStartButton.Type='pushbutton';
        slicerAddStartButton.RowSpan=[2,2];
        slicerAddStartButton.ColSpan=[2,2];
        slicerAddStartButton.MatlabMethod=...
        'slslicer.internal.addBusElementFromSignalHierarchy';
        slicerAddStartButton.MatlabArgs={'%dialog'};


        if~slslicer.internal.MenuSlicerUtils().checkUIOpenModel(this.fmodel)
            slicerAddStartButton.Visible=false;
        end
    else

        buttonSrc=struct;
        buttonSrc.Name='SOURCE';
        buttonSrc.Tag='source';
        buttonSrc.Type='pushbutton';
        buttonSrc.RowSpan=[2,2];
        buttonSrc.ColSpan=[2,2];
        buttonSrc.MatlabMethod='traceBus';
        buttonSrc.MatlabArgs={'%tag','%dialog'};

        buttonDst=struct;
        buttonDst.Name='DESTINATION';
        buttonDst.Tag='destination';
        buttonDst.Type='pushbutton';
        buttonDst.RowSpan=[2,2];
        buttonDst.ColSpan=[3,3];
        buttonDst.MatlabMethod='traceBus';
        buttonDst.MatlabArgs={'%tag','%dialog'};
    end


    dlg=struct;
    dlg.DialogTag='SigHierViewerDlg';


    if get_param(this.fmodel,'ModelSlicerActive')&&...
        slslicer.internal.MenuSlicerUtils.checkUIOpenModel(this.fmodel)
        dlg.DialogTitle=...
        DAStudio.message('Simulink:dialog:BusHierarchyViewerTitleSlicerMode');
    else
        dlg.DialogTitle=...
        DAStudio.message('Simulink:dialog:BusHierarchyViewerTitle',this.fModel);
    end

    if get_param(this.fmodel,'ModelSlicerActive')
        dlg.Items={grpDescription,slicerAddStartButton};
    else
        dlg.Items={grpDescription,buttonSrc,buttonDst};
    end
    dlg.LayoutGrid=[2,3];
    dlg.RowStretch=[1,0];
    dlg.ColStretch=[1,0,0];
    dlg.CloseMethod='CloseCallback';
    dlg.StandaloneButtonSet={''};
end

