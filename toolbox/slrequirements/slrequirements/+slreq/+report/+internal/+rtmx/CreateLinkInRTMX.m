classdef CreateLinkInRTMX<handle



    properties(Access=private)
        linkSrc;
        linkDst;
        linkSet;
        srcDesc;
dstDesc
    end


    methods(Access=public)

        function show(this)
            dlg=findDDGByTag('slreqrtmx_createlink');



            if ishandle(dlg)
                dlg.show;
            else
                dlg=DAStudio.Dialog(this);
                dlg.show;
            end
        end


        function dlgstruct=getDialogSchema(this,~)


            srcnametext.Type='text';
            srcnametext.Name=['Source: ',this.srcDesc];
            srcnametext.RowSpan=[1,1];
            srcnametext.ColSpan=[1,3];

            typeList=struct('Type','combobox','Tag','TypeName','RowSpan',[2,2],'ColSpan',[2,2]);

            reqData=slreq.data.ReqData.getInstance;
            alltypes=reqData.getAllLinkTypes;
            dispList={alltypes.typeName};
            typeList.Entries=dispList;
            typeList.ObjectMethod='';
            typeList.MethodArgs={'%dialog','%value'};
            typeList.ArgDataTypes={'handle','mxArray'};
            typeList.Tag='rtmxcreatelink_typecombo';
            typeList.RowSpan=[2,2];
            typeList.ColSpan=[1,1];

            dstnametext.Type='text';
            dstnametext.Name=['Destination: ',this.dstDesc];
            dstnametext.RowSpan=[3,3];
            dstnametext.ColSpan=[1,3];


            createButton.Name='Create';
            createButton.Tag='slreqrtmx_create';
            createButton.Type='pushbutton';
            createButton.RowSpan=[4,4];
            createButton.ColSpan=[2,2];
            createButton.ObjectMethod='callBackCreateButton';
            createButton.MethodArgs={'%dialog'};
            createButton.ArgDataTypes={'handle'};
            createButton.ToolTip='';

            cancelButton.Name='Close';
            cancelButton.Tag='slreqrtmx_cancelcreatelink';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[4,4];
            cancelButton.ColSpan=[3,3];
            cancelButton.ObjectMethod='callBackCancelButton';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.ToolTip='ddd';


            dlgstruct.DialogTag='slreqrtmx_createlink';
            dlgstruct.DialogTitle='Create Link';
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.LayoutGrid=[1,3];
            dlgstruct.ColStretch=[0,1,1];
            dlgstruct.Items={srcnametext,typeList,dstnametext,createButton,cancelButton};

            dlgstruct.Sticky=true;
        end

        function callBackCancelButton(this,dlg)
            dlg.delete();
        end


        function callBackCreateButton(this,dlg)
            import slreq.report.internal.rtmx.*
            src=this.linkSrc;
            dst=this.linkDst;
            linktype=dlg.getComboBoxText('rtmxcreatelink_typecombo');
            linkInfo=slreq.createLink(src,dst);
            linkInfo.Type=linktype;
            dlg.delete();
            maindlg=findDDGByTag('slreq_rtmx');
            mainimd=DAStudio.imDialog.getIMWidgets(maindlg);
            browserimd=mainimd.find('Tag','RMTXDDGWeb');

            srcid=this.linkSrc.getUuid;
            dstid=this.linkDst.getUuid;
            desc=linkInfo.Description;
            [srcAdapter,srcArtifact,srcId]=this.linkSrc.getAdapter();
            src=srcAdapter.getSummaryString(srcArtifact,srcId);
            [dstAdapter,dstArtifact,dstId]=this.linkDst.getAdapter();
            dst=dstAdapter.getSummaryString(dstArtifact,dstId);

            tooltipstr=sprintf('Des: %s <br> Src: %s <br> Dst: %s ',desc,src,dst);

            tooltiphtml=createCellStr('span',tooltipstr,'class','linktooltip');
            content=[linktype(1),tooltiphtml];



            jsStr=sprintf('addLink(''%s'', ''%s'', ''%s'', ''%s'');',...
            srcid,dstid,linktype,content);

            browserimd.evalJS(jsStr);
        end

        function this=CreateLinkInRTMX(srcUuid,dstUuid)
            reqData=slreq.data.ReqData.getInstance;
            this.linkSrc=reqData.findObject(srcUuid);
            this.linkDst=reqData.findObject(dstUuid);
            [srcAdapter,srcAartifact,srcId]=this.linkSrc.getAdapter();
            this.srcDesc=srcAdapter.getSummaryString(srcAartifact,srcId);

            [dstAdapter,dstAartifact,dstId]=this.linkDst.getAdapter();
            this.dstDesc=dstAdapter.getSummaryString(dstAartifact,dstId);
        end
    end


end




