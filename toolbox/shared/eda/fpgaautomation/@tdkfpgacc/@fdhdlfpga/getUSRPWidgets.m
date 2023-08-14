function group=getUSRPWidgets(this,tag,enableWidget)





    src=this.FPGAProperties;
    curRow=0;


    curRow=curRow+1;

    prop='USRPFPGASourceFolder';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,1];
    USRPFPGASourceFolderLabel=widget;

    widget=[];
    widget.Type='edit';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[2,2];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    USRPFPGASourceFolder=widget;

    USRPFPGASourceFolderLabel.Buddy=USRPFPGASourceFolder.Tag;






    widget=[];
    widget.Name=l_GetUIString('BrowseButton');
    widget.Type='pushbutton';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[3,3];
    widget.Source=this;

    widget.Tag=[tag,'browseForUsrpSource'];
    widget.DialogRefresh=true;
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',tag,widget.Tag};
    widget.ArgDataTypes={'handle','string','string'};
    browseForUsrpSource=widget;



    group.Type='panel';
    group.LayoutGrid=[curRow,3];
    group.ColStretch=[0,1,0];
    group.Tag=[tag,'USRPWidgets'];
    group.Enabled=enableWidget;
    group.Items={USRPFPGASourceFolderLabel,USRPFPGASourceFolder,...
    browseForUsrpSource};


    function str=l_GetUIString(key,postfix)
        if nargin<2
            postfix='_Name';
        end
        str=DAStudio.message(['EDALink:FPGAUI:',key,postfix]);

