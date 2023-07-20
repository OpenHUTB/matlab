
function dlg=getDialogSchema(~,~)




    info.Type='text';
    info.RowSpan=[1,1];
    info.ColSpan=[1,1];
    info.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:RootHelp'));
    info1.Type='text';
    info1.RowSpan=[2,2];
    info1.ColSpan=[1,1];
    info1.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:RootHelp1'));

    dlg.Sticky=true;
    dlg.LayoutGrid=[3,1];
    dlg.RowStretch=[0,0,1];
    dlg.Items={info,info1};
    dlg.DialogTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:Root'));
    dlg.DialogTag='Root_dialog';
    dlg.HelpArgs={dlg.DialogTag};
    dlg.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';

end
