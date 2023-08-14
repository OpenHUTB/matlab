function group=getClockGroup(this,tag,enableGroup)





    src=this.FPGAProperties;
    curRow=0;


    supportedDevice=1;

    if isclockmodulesupported&&strcmpi(src.FPGAWorkflow,'Project generation')
        showGroup=true;



        enableClkGen=supportedDevice;
        if~supportedDevice&&strcmpi(src.GenClockModule,'on')
            src.GenClockModule='off';
        end



        enableInClk=strcmpi(src.GenClockModule,'on');
        enableSysClk=strcmpi(src.GenClockModule,'on');

    else
        showGroup=false;
        enableClkGen=false;
        enableInClk=false;
        enableSysClk=false;
    end


    curRow=curRow+1;

    prop='GenClockModule';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='checkbox';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,4];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=enableClkGen;
    GenClockModule=widget;

    curRow=curRow+1;


    prop='FPGAInputClockPeriod';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,1];
    widget.Enabled=enableInClk;
    ClkInLabel=widget;

    widget=[];
    widget.Type='edit';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[2,2];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.Enabled=enableInClk;
    ClkIn=widget;
    ClkInLabel.Buddy=ClkIn.Tag;


    prop='FPGASystemClockPeriod';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[3,3];
    widget.Enabled=enableSysClk;
    ClkOutLabel=widget;

    widget=[];
    widget.Type='edit';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[4,4];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.Enabled=enableSysClk;
    ClkOut=widget;
    ClkOutLabel.Buddy=ClkOut.Tag;


    gname='ClockGroup';

    group.Name=l_GetUIString(gname);
    group.Type='group';
    group.LayoutGrid=[curRow,4];
    group.Tag=[tag,gname];
    group.Visible=showGroup;
    group.Enabled=enableGroup;
    group.Items={GenClockModule,ClkInLabel,ClkIn,ClkOutLabel,ClkOut};


    function str=l_GetUIString(key,postfix)
        if nargin<2
            postfix='_Name';
        end
        str=DAStudio.message(['EDALink:FPGAUI:',key,postfix]);


