function dlgStruct=getDialogSchema(this,dummy)%#ok<INUSD>





    dlgStruct.DialogTitle='Auto Timescale';
    dlgStruct.StandaloneButtonSet={'OK','Help'};
    dlgStruct.DialogTag=this.dialogTag;

    dlgStruct.HelpMethod='helpview';
    dlgStruct.HelpArgs={fullfile(docroot,'toolbox','hdlverifier','helptargets.map'),'edalinklibhdlcosimulation'};

    mainC.Type='panel';
    mainC.Tag='mainC';
    mainC.LayoutGrid=[3,2];
    mainC.RowStretch=[1,0,1];
    mainC.ColStretch=[0,1];
    mainC.RowSpan=[1,1];
    mainC.ColSpan=[1,1];





    iconW.Type='image';
    iconW.FilePath=l_GetIconFile(this.msgType);
    iconW.RowSpan=[1,1];
    iconW.ColSpan=[1,1];


    msgC.Type='group';
    msgC.Name=[this.msgType,' Message'];
    msgC.Tag='msgC';
    msgC.RowSpan=[1,1];
    msgC.ColSpan=[2,2];
    msgC.Items={l_CreateMsgWidget(this)};


    btnC.Type='panel';

    btnC.Tag='btnC';
    btnC.RowSpan=[2,2];
    btnC.ColSpan=[1,2];
    btnC.Visible=this.showShowBtn;
    showBtn=l_CreateShowHideBtn('Show Details...',this.showBtnTag,true);
    hideBtn=l_CreateShowHideBtn('Hide Details...',this.hideBtnTag,false);
    btnC.Items={showBtn,hideBtn};


    dmsgC.Type='group';
    dmsgC.Name='Details';
    dmsgC.Tag=this.dmsgTag;
    dmsgC.RowSpan=[3,3];
    dmsgC.ColSpan=[1,2];
    dmsgC.Items={l_CreateDMsgWidget(this)};
    dmsgC.Visible=false;

    mainC.Items={iconW,msgC,btnC,dmsgC};
    dlgStruct.Items={mainC};

end




function iconFile=l_GetIconFile(msgType)
    basePath=fullfile(matlabroot,'toolbox','edalink','foundation','hdllink');
    switch(msgType)
    case 'Error'
        iconFile=fullfile(basePath,'edalink_error_icon.png');
    case 'Info'
        iconFile=fullfile(basePath,'edalink_help_icon.png');
    case 'Warning'
        iconFile=fullfile(basePath,'edalink_warning_icon.png');
    end
end

function msgItem=l_CreateMsgWidget(this)
    msgItem.Type='text';
    msgItem.Name=this.msg;
    msgItem.Tag='msg';
    msgItem.WordWrap=1;
end

function msgItem=l_CreateDMsgWidget(this)
    msgItem.Type='text';
    msgItem.Name=this.dmsg;
    msgItem.Tag='dmsg';
    msgItem.WordWrap=1;
end

function btn=l_CreateShowHideBtn(name,tag,vis)
    btn.Type='pushbutton';
    btn.Name=name;
    btn.Tag=tag;
    btn.ObjectMethod='ShowHideBtnCb';
    btn.MethodArgs={'%dialog'};
    btn.ArgDataTypes={'handle'};
    btn.Alignment=6;
    btn.Visible=vis;
end


