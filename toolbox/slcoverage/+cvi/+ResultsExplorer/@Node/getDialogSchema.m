
function dlg=getDialogSchema(obj,~)




    if isCum(obj)
        info.Type='text';
        info.RowSpan=[1,1];
        info.ColSpan=[1,1];
        info.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:CollectionHelp'));
        dlg.DialogTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageDataCollection'));
        dlg.Sticky=true;
        dlg.LayoutGrid=[2,1];
        dlg.RowStretch=[0,1];
        dlg.Items={info};

    else
        dlg=getNodeDialogSchema(obj,true);
    end
    dlg.DialogTag='Node_dialog';
    dlg.HelpArgs={dlg.DialogTag};
    dlg.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';
end
