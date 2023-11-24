classdef OptionDlg<handle

    properties(Access=private)
        ReqSets;
        SupportedTypes={'.docx','.pdf','.html'};

        ReqSetListMap=containers.Map();
    end

    properties(Access=private)
        ReportFullPath;
        IncludedInReport=struct('rationale',true,...
        'keywords',true,...
        'customAttributes',true,...
        'links',true,...
        'changeInformation',true,...
        'revision',false,...
        'comments',true,...
        'implementationStatus',true,...
        'verificationStatus',true,...
        'emptySection',false,...
        'toc',true,...
        'groupLinksBy','Artifact');
        Title=getString(message('Slvnv:slreq:ReportGenDefaultTitle'));


        Authors=getSysUserName();

        UseCustomTitle=false;

        UseCustomReportName=false;


        ReportDir;
        ReportName;
        ReportNameWithExt;
        ReportType;

    end

    properties(Dependent=true,GetAccess=private)


        SupportedFileExtList;
    end


    properties(Hidden)
        OpenReport=true;
    end

    methods

        function out=get.ReportNameWithExt(this)
            out=[this.ReportName,this.ReportType];
        end


        function out=get.ReportFullPath(this)
            out=fullfile(this.ReportDir,[this.ReportName,this.ReportType]);
        end



        function out=get.SupportedFileExtList(this)

            allList=this.getAllFormatList;
            fullPath=allList(:,1);
            allTypes=allList(:,2);
            allTypes2=strcat('*',allTypes);

            [status,loc]=ismember(this.ReportType,allTypes);
            if status
                fullPath([1,loc])=fullPath([loc,1]);
                allTypes2([1,loc])=allTypes2([loc,1]);

            end
            out=[allTypes2,fullPath];
        end
    end


    methods(Access=public)

        function dlgstruct=getDialogSchema(this)





            titlePageOption=getTitleOptionSchema(this);




            exportOption=getReportExportOptionSchema(this);




            reportPageOption=getReportOptionSchema(this);




            setSelect=getReqSetListSchema(this);




            bottomPart=getReportOptionBottemPart(this);





            dlgstruct.DialogTitle=getString(message('Slvnv:slreq:ReportOPTGUITitle'));
            dlgstruct.StandaloneButtonSet={''};

            dlgstruct.LayoutGrid=[5,1];




            dlgstruct.RowStretch=[0,0,1,0,0];
            dlgstruct.DialogTag='slreqrpt_configmain';
            dlgstruct.CloseMethod='callBackCancelButton';
            dlgstruct.CloseMethodArgs={'%dialog'};
            dlgstruct.CloseMethodArgsDT={'handle'};
            dlgstruct.Sticky=true;
            dlgstruct.Items={titlePageOption,exportOption,...
            setSelect,reportPageOption,bottomPart};
        end


        function show(this,preSelect)
            dlg=findDDGByTag('slreqrpt_configmain');



            if ishandle(dlg)
                dlg.show;
            else
                dlg=DAStudio.Dialog(this);
                if this.UseCustomTitle
                    dlg.setWidgetValue('reqrptopt_edit_title',this.Title);
                else
                    if numel(preSelect)==1
                        dlg.setWidgetValue('reqrptopt_edit_title',preSelect.Name);
                        this.Title=preSelect.Name;
                    end
                end

                dlg.setWidgetValue('reqrptopt_text_reportdircontent',this.ReportDir);
                dlg.setWidgetValue('reqrptopt_text_reportnamecontent',this.ReportNameWithExt);

                dlg.clearWidgetDirtyFlag('reqrptopt_edit_title');
                this.selectReqSetInTable(dlg,preSelect);
            end
        end
    end

    methods(Static)

        function this=getOptionDlg(type,reqSets,preSelect)
            if nargin<3
                preSelect=[];
            end
            this=[];
            persistent optionDlg;

            switch type
            case 'get'
                if isempty(optionDlg)||~isvalid(optionDlg)
                    this=[];
                else
                    this=optionDlg;
                end
            case 'clear'
                dlg=findDDGByTag('slreqrpt_configmain');
                if~isempty(dlg)
                    dlg.delete;
                end
                clear optionDlg;
                return;
            case 'create'
                if isempty(optionDlg)||~isvalid(optionDlg)
                    optionDlg=slreq.report.OptionDlg();
                end
                this=optionDlg;
                this.ReqSets=reqSets;
                this.setReportFullPath(preSelect);
            end

        end
    end

    methods(Access=private)


        function this=OptionDlg()
            if reqmgt('rmiFeature','TraceabilityTable')
                this.IncludedInReport.traceabilityTables=true;
                this.IncludedInReport.traceabilityTablesLinkTypes='Confirm.Derive.Implement.Refine.Relate.Verify';
                this.IncludedInReport.groupTraceabilityTablesBy='ReqSets';
            end
        end


        function setReportFullPath(this,selectedReqSet)
            if this.UseCustomReportName&&~isempty(this.ReportName)
                newReportFullPath=slreq.report.utils.generateReportName(this.ReportFullPath);
            else
                if length(selectedReqSet)==1
                    expFullPath=fullfile(this.ReportDir,[selectedReqSet.Name,this.ReportType]);
                else
                    expFullPath=fullfile(this.ReportDir,['slreqrpt_',datestr(now,'YYYYmmDD'),this.ReportType]);
                end
                newReportFullPath=slreq.report.utils.generateReportName(expFullPath);
            end
            [this.ReportDir,this.ReportName,this.ReportType]=fileparts(newReportFullPath);

            this.ReportDir=[this.ReportDir,filesep];
        end


        function titlePageOption=getTitleOptionSchema(this)

            maxCol=2;
            currentRow=1;

            title.Name=getString(message('Slvnv:slreq:ReportOPTGUIReportTitleName'));
            title.Tag='reqrptopt_text_title';
            title.Type='text';
            title.RowSpan=[currentRow,currentRow];
            title.ColSpan=[1,1];
            title.Buddy='reqrptopt_edit_title';

            titleContent.Name='';
            if numel(this.ReqSets)==1
                titleContent.Value=this.ReqSets(1).name;
            else
                titleContent.Value=this.Title;
            end
            titleContent.Tag='reqrptopt_edit_title';
            titleContent.Type='edit';
            titleContent.RowSpan=[currentRow,currentRow];
            titleContent.ColSpan=[2,maxCol];
            titleContent.ToolTip=getString(message('Slvnv:slreq:ReportOPTGUIReportTitleToolTip'));
            titleContent.ObjectMethod='onTitleChange';
            titleContent.MethodArgs={'%value'};
            titleContent.ArgDataTypes={'mxArray'};

            currentRow=currentRow+1;
            authors.Name=getString(message('Slvnv:slreq:ReportOPTGUIReportAuthorNames'));
            authors.Type='text';
            authors.Tag='reqrptopt_text_authors';
            authors.RowSpan=[currentRow,currentRow];
            authors.ColSpan=[1,1];
            authors.Buddy='reqrptopt_edit_authors';

            authorsContent.Name='';
            authorsContent.Type='edit';
            authorsContent.Value=this.Authors;
            authorsContent.Tag='reqrptopt_edit_authors';
            authorsContent.RowSpan=[currentRow,currentRow];
            authorsContent.ColSpan=[2,maxCol];
            authorsContent.ToolTip=getString(message('Slvnv:slreq:ReportOPTGUIReportAuthorToolTip'));
            authorsContent.ObjectMethod='onAuthorsChange';
            authorsContent.MethodArgs={'%value'};
            authorsContent.ArgDataTypes={'mxArray'};


            titleOptions={title,titleContent,authors,authorsContent};

            titlePageOption.Type='group';
            titlePageOption.Tag='reqrptopt_group_titlepage';
            titlePageOption.Name=getString(message('Slvnv:slreq:ReportOPTGUITitleOptName'));
            titlePageOption.LayoutGrid=[2,2];
            titlePageOption.Items=titleOptions;
            titlePageOption.Enabled=true;
        end


        function reportExportOptions=getReportExportOptionSchema(this)

            maxCol=3;
            currentRow=1;

            reportDir.Name=getString(message('Slvnv:slreq:FolderColon'));
            reportDir.Tag='reqrptopt_text_reportdir';
            reportDir.Type='text';
            reportDir.RowSpan=[currentRow,currentRow];
            reportDir.ColSpan=[1,1];

            reportDirContent.Name=this.ReportDir;
            reportDirContent.ToolTip=this.ReportDir;
            reportDirContent.Tag='reqrptopt_text_reportdircontent';
            reportDirContent.Type='text';
            reportDirContent.RowSpan=[currentRow,currentRow];
            reportDirContent.ColSpan=[2,maxCol];
            reportDirContent.Value=this.ReportDir;
            reportDirContent.Elide=true;
            reportDirContent.PreferredSize=[400,-1];

            currentRow=currentRow+1;

            reportName.Name=getString(message('Slvnv:slreq:FileNameColon'));
            reportName.Tag='reqrptopt_text_reportname';
            reportName.Type='text';
            reportName.RowSpan=[currentRow,currentRow];
            reportName.ColSpan=[1,1];

            reportNameStr.Name=this.ReportNameWithExt;
            reportNameStr.Tag='reqrptopt_text_reportnamecontent';
            reportNameStr.Type='text';
            reportNameStr.RowSpan=[currentRow,currentRow];
            reportNameStr.ColSpan=[2,2];

            buttonBrowseReportFile.Name=getString(message('Slvnv:slreq:ReportOPTGUIBtnExportAs'));
            buttonBrowseReportFile.Type='pushbutton';
            buttonBrowseReportFile.Tag='reqrptopt_pushbutton_exportas';
            buttonBrowseReportFile.RowSpan=[currentRow,currentRow];
            buttonBrowseReportFile.ColSpan=[3,maxCol];
            buttonBrowseReportFile.ObjectMethod='callBackExportReportAs';
            buttonBrowseReportFile.MethodArgs={'%dialog'};
            buttonBrowseReportFile.ArgDataTypes={'handle'};

            reportExportOptionItems={reportDir,reportDirContent,...
            reportName,reportNameStr,...
            buttonBrowseReportFile};

            reportExportOptions.Type='group';
            reportExportOptions.Tag='reqrptopt_group_exportoption';
            reportExportOptions.Name=getString(message('Slvnv:slreq:File'));
            reportExportOptions.LayoutGrid=[currentRow,maxCol];
            reportExportOptions.ColStretch=[0,1,0];
            reportExportOptions.Items=reportExportOptionItems;
            reportExportOptions.Enabled=true;
        end


        function reportPageOption=getReportOptionSchema(this)


            maxCol=4;
            currentRow=1;

            checkBoxIncludeTOC.Name=getString(message('Slvnv:slreq:ReportOPTGUIIncludeTOC'));
            checkBoxIncludeTOC.Tag='reqrptopt_checkbox_includetoc';
            checkBoxIncludeTOC.Type='checkbox';
            checkBoxIncludeTOC.Value=this.IncludedInReport.toc;
            checkBoxIncludeTOC.RowSpan=[currentRow,currentRow];
            checkBoxIncludeTOC.ColSpan=[1,2];
            checkBoxIncludeTOC.DialogRefresh=0;
            checkBoxIncludeTOC.ObjectMethod='callBackCheckBoxIncludeTOC';
            checkBoxIncludeTOC.MethodArgs={'%value'};
            checkBoxIncludeTOC.ArgDataTypes={'mxArray'};

            checkBoxIncludeImplementationStatus.Name=getString(message('Slvnv:slreq:ImplementationStatus'));
            checkBoxIncludeImplementationStatus.Tag='reqrptopt_checkbox_includeimplementationstatus';
            checkBoxIncludeImplementationStatus.Type='checkbox';
            checkBoxIncludeImplementationStatus.Value=this.IncludedInReport.implementationStatus;
            checkBoxIncludeImplementationStatus.RowSpan=[currentRow,currentRow];
            checkBoxIncludeImplementationStatus.ColSpan=[3,maxCol];
            checkBoxIncludeImplementationStatus.ObjectMethod='callBackCheckBoxIncludeImplementationStatus';
            checkBoxIncludeImplementationStatus.MethodArgs={'%value'};
            checkBoxIncludeImplementationStatus.ArgDataTypes={'mxArray'};

            currentRow=currentRow+1;

            checkBoxRationale.Name=getString(message('Slvnv:slreq:Rationale'));
            checkBoxRationale.Tag='reqrptopt_checkbox_includerationale';
            checkBoxRationale.Type='checkbox';
            checkBoxRationale.Value=this.IncludedInReport.rationale;
            checkBoxRationale.RowSpan=[currentRow,currentRow];
            checkBoxRationale.ColSpan=[1,2];
            checkBoxRationale.ObjectMethod='callBackCheckBoxIncludeRationale';
            checkBoxRationale.MethodArgs={'%value'};
            checkBoxRationale.ArgDataTypes={'mxArray'};

            checkBoxIncludeVerificationStatus.Name=getString(message('Slvnv:slreq:VerificationStatus'));
            checkBoxIncludeVerificationStatus.Tag='reqrptopt_checkbox_includeverificationstatus';
            checkBoxIncludeVerificationStatus.Type='checkbox';
            checkBoxIncludeVerificationStatus.Value=this.IncludedInReport.verificationStatus;
            checkBoxIncludeVerificationStatus.RowSpan=[currentRow,currentRow];
            checkBoxIncludeVerificationStatus.ColSpan=[3,maxCol];
            checkBoxIncludeVerificationStatus.ObjectMethod='callBackCheckBoxIncludeVerificationStatus';
            checkBoxIncludeVerificationStatus.MethodArgs={'%value'};
            checkBoxIncludeVerificationStatus.ArgDataTypes={'mxArray'};


            currentRow=currentRow+1;
            checkBoxKeywords.Name=getString(message('Slvnv:slreq:Keywords'));
            checkBoxKeywords.Tag='reqrptopt_checkbox_includekeywords';
            checkBoxKeywords.Type='checkbox';
            checkBoxKeywords.Value=this.IncludedInReport.keywords;
            checkBoxKeywords.RowSpan=[currentRow,currentRow];
            checkBoxKeywords.ColSpan=[1,2];
            checkBoxKeywords.ObjectMethod='callBackCheckBoxIncludeKeywords';
            checkBoxKeywords.MethodArgs={'%value'};
            checkBoxKeywords.ArgDataTypes={'mxArray'};

            checkBoxLinks.Name=getString(message('Slvnv:slreq:Links'));
            checkBoxLinks.Tag='reqrptopt_checkbox_includelinks';
            checkBoxLinks.Type='checkbox';
            checkBoxLinks.Value=this.IncludedInReport.links;
            checkBoxLinks.RowSpan=[currentRow,currentRow];
            checkBoxLinks.ColSpan=[3,maxCol];
            checkBoxLinks.ObjectMethod='callBackCheckBoxIncludeLinks';
            checkBoxLinks.MethodArgs={'%dialog','%value'};
            checkBoxLinks.ArgDataTypes={'handle','mxArray'};


            currentRow=currentRow+1;
            checkBoxCustomAttributes.Name=getString(message('Slvnv:slreq:CustomAttributes'));
            checkBoxCustomAttributes.Tag='reqrptopt_checkbox_includecustomattributes';
            checkBoxCustomAttributes.Type='checkbox';
            checkBoxCustomAttributes.Value=this.IncludedInReport.customAttributes;
            checkBoxCustomAttributes.RowSpan=[currentRow,currentRow];
            checkBoxCustomAttributes.ColSpan=[1,2];
            checkBoxCustomAttributes.ObjectMethod='callBackCheckBoxIncludeCustomAttributes';
            checkBoxCustomAttributes.MethodArgs={'%value'};
            checkBoxCustomAttributes.ArgDataTypes={'mxArray'};


            radioLinkGroup.Name=getString(message('Slvnv:slreq:ReportOPTGUIGroupLinks'));
            radioLinkGroup.Tag='reqrptopt_radiobutton_grouplinks';
            radioLinkGroup.Type='radiobutton';

            if strcmp(this.IncludedInReport.groupLinksBy,'Artifact')
                radioLinkGroup.Value=0;
            else
                radioLinkGroup.Value=1;
            end
            radioLinkGroup.OrientHorizontal=true;
            radioLinkGroup.Entries={getString(message('Slvnv:slreq:ReportOPTGUIGroupLinksByArtifact')),...
            getString(message('Slvnv:slreq:ReportOPTGUIGroupLinksByType'))};
            radioLinkGroup.ObjectMethod='callBackRadioButtonGroupLinks';
            radioLinkGroup.MethodArgs={'%value'};
            radioLinkGroup.ArgDataTypes={'mxArray'};
            radioLinkGroup.RowSpan=[currentRow,currentRow+1];
            radioLinkGroup.ColSpan=[3,maxCol];
            radioLinkGroup.Enabled=this.IncludedInReport.links;

            currentRow=currentRow+1;
            checkBoxRevision.Name=getString(message('Slvnv:slreq:RevisionInfo'));
            checkBoxRevision.Tag='reqrptopt_checkbox_includerivison';
            checkBoxRevision.Type='checkbox';
            checkBoxRevision.Value=this.IncludedInReport.revision;
            checkBoxRevision.RowSpan=[currentRow,currentRow];
            checkBoxRevision.ColSpan=[1,2];
            checkBoxRevision.ObjectMethod='callBackCheckBoxIncludeRevision';
            checkBoxRevision.MethodArgs={'%value'};
            checkBoxRevision.ArgDataTypes={'mxArray'};


            currentRow=currentRow+1;
            checkBoxComments.Name=getString(message('Slvnv:slreq:Comments'));
            checkBoxComments.Tag='reqrptopt_checkbox_includecomments';
            checkBoxComments.Type='checkbox';
            checkBoxComments.WidgetId='reqrptopt_checkbox_includecomments';
            checkBoxComments.Value=this.IncludedInReport.comments;
            checkBoxComments.RowSpan=[currentRow,currentRow];
            checkBoxComments.ColSpan=[1,2];
            checkBoxComments.ObjectMethod='callBackCheckBoxIncludeComments';
            checkBoxComments.MethodArgs={'%value'};
            checkBoxComments.ArgDataTypes={'mxArray'};

            checkBoxChangeInfo.Name=getString(message('Slvnv:slreq:ReportOPTGUIIncludeChangeInformation'));
            checkBoxChangeInfo.Tag='reqrptopt_checkbox_includechangeinfo';
            checkBoxChangeInfo.Type='checkbox';
            checkBoxChangeInfo.Value=this.IncludedInReport.changeInformation;
            checkBoxChangeInfo.Enabled=this.IncludedInReport.links;
            checkBoxChangeInfo.RowSpan=[currentRow,currentRow];
            checkBoxChangeInfo.ColSpan=[3,maxCol];
            checkBoxChangeInfo.ObjectMethod='callBackCheckBoxIncludeChangeInfo';
            checkBoxChangeInfo.MethodArgs={'%value'};
            checkBoxChangeInfo.ArgDataTypes={'mxArray'};


            currentRow=currentRow+1;
            checkBoxExcludeEmpty.Name=getString(message('Slvnv:slreq:ReportOPTGUIIncludeEmptySections'));
            checkBoxExcludeEmpty.Tag='reqrptopt_checkbox_excludeempty';
            checkBoxExcludeEmpty.Type='checkbox';
            checkBoxExcludeEmpty.Value=this.IncludedInReport.emptySection;
            checkBoxExcludeEmpty.RowSpan=[currentRow,currentRow];
            checkBoxExcludeEmpty.ColSpan=[1,2];
            checkBoxExcludeEmpty.ObjectMethod='callBackCheckBoxIncludeEmptySection';
            checkBoxExcludeEmpty.MethodArgs={'%value'};
            checkBoxExcludeEmpty.ArgDataTypes={'mxArray'};

            if reqmgt('rmiFeature','TraceabilityTable')
                checkBoxTraceabilityTables.Name=getString(message('Slvnv:slreq:TraceabilityTables'));
                checkBoxTraceabilityTables.Tag='reqrptopt_checkbox_includetraceabilitytables';
                checkBoxTraceabilityTables.Type='checkbox';
                checkBoxTraceabilityTables.Value=this.IncludedInReport.traceabilityTables;
                checkBoxTraceabilityTables.RowSpan=[currentRow,currentRow];
                checkBoxTraceabilityTables.ColSpan=[3,maxCol];
                checkBoxTraceabilityTables.ObjectMethod='callBackCheckBoxIncludeTraceabilityTables';
                checkBoxTraceabilityTables.MethodArgs={'%dialog','%value'};
                checkBoxTraceabilityTables.ArgDataTypes={'handle','mxArray'};

                currentRow=currentRow+1;
                radioTraceabilityTablesGroup.Name=getString(message('Slvnv:slreq:ReportOPTGUIGroupTraceabilityTables'));
                radioTraceabilityTablesGroup.Tag='reqrptopt_radiobutton_grouptraceabilitytables';
                radioTraceabilityTablesGroup.Type='radiobutton';

                if strcmp(this.IncludedInReport.groupTraceabilityTablesBy,'ReqSets')
                    radioTraceabilityTablesGroup.Value=0;
                else
                    radioTraceabilityTablesGroup.Value=1;
                end
                radioTraceabilityTablesGroup.OrientHorizontal=true;
                radioTraceabilityTablesGroup.Entries={getString(message('Slvnv:slreq:ReportOPTGUIGroupTraceabilityTablesByReqSets')),...
                getString(message('Slvnv:slreq:ReportOPTGUIGroupTraceabilityTablesBySrcAndDst'))};
                radioTraceabilityTablesGroup.ObjectMethod='callBackRadioButtonGroupTraceabilityTables';
                radioTraceabilityTablesGroup.MethodArgs={'%value'};
                radioTraceabilityTablesGroup.ArgDataTypes={'mxArray'};
                radioTraceabilityTablesGroup.RowSpan=[currentRow,currentRow+1];
                radioTraceabilityTablesGroup.ColSpan=[3,maxCol];
                radioTraceabilityTablesGroup.Enabled=this.IncludedInReport.traceabilityTables;

                currentRow=currentRow+2;
                initialToggleState=true;
                panelTraceabilityTablesLinkTypes.Name=getString(message('Slvnv:slreq:ReportOPTGUIGroupTraceabilityTablesLinkTypes'));
                panelTraceabilityTablesLinkTypes.Tag='reqrptopt_panel_traceabilitytableslinktypes';
                panelTraceabilityTablesLinkTypes.Type='togglepanel';
                panelTraceabilityTablesLinkTypes.Expand=...
                slreq.gui.togglePanelHandler('get',panelTraceabilityTablesLinkTypes.Tag,initialToggleState);
                panelTraceabilityTablesLinkTypes.ExpandCallback=@slreq.gui.togglePanelHandler;
                panelTraceabilityTablesLinkTypes.RowSpan=[currentRow,currentRow+1];
                panelTraceabilityTablesLinkTypes.ColSpan=[3,maxCol];

                panelTraceabilityTablesLinkTypes.Items={};
                reqData=slreq.data.ReqData.getInstance();
                linkTypes=reqData.getAllLinkTypes();
                for i=1:numel(linkTypes)
                    linkTypeName=linkTypes(i).typeName;

                    checkBoxWidget.Name=slreq.app.LinkTypeManager.getForwardName(linkTypes(i).typeName);
                    checkBoxWidget.Tag=['reqrptopt_checkbox_includetraceabilitytableslinktype_',linkTypeName];
                    checkBoxWidget.Type='checkbox';
                    checkBoxWidget.Value=true;
                    checkBoxWidget.RowSpan=[i,i+1];
                    checkBoxWidget.ColSpan=[1,2];
                    checkBoxWidget.ObjectMethod='callBackCheckBoxIncludeTraceabilityTablesLinkType';
                    checkBoxWidget.MethodArgs={'%dialog','%value'};
                    checkBoxWidget.ArgDataTypes={'handle','mxArray'};
                    panelTraceabilityTablesLinkTypes.Items{end+1}=checkBoxWidget;
                end
            end

            if reqmgt('rmiFeature','TraceabilityTable')
                reportOptions={checkBoxRationale,...
                checkBoxKeywords,...
                checkBoxCustomAttributes,...
                checkBoxIncludeTOC,...
                checkBoxRevision,...
                checkBoxLinks,...
                radioLinkGroup,...
                checkBoxComments,...
                checkBoxIncludeImplementationStatus,...
                checkBoxIncludeVerificationStatus,...
                checkBoxChangeInfo,...
                checkBoxExcludeEmpty,...
                checkBoxTraceabilityTables,...
                radioTraceabilityTablesGroup,...
                panelTraceabilityTablesLinkTypes};
            else
                reportOptions={checkBoxRationale,...
                checkBoxKeywords,...
                checkBoxCustomAttributes,...
                checkBoxIncludeTOC,...
                checkBoxRevision,...
                checkBoxLinks,...
                radioLinkGroup,...
                checkBoxComments,...
                checkBoxIncludeImplementationStatus,...
                checkBoxIncludeVerificationStatus,...
                checkBoxChangeInfo,...
                checkBoxExcludeEmpty};
            end

            reportPageOption.Type='group';
            reportPageOption.Tag='reqrptopt_group_repotpageoptions';
            reportPageOption.Name=getString(message('Slvnv:slreq:ReportOPTGUIReportContentOpt'));
            reportPageOption.LayoutGrid=[currentRow,maxCol];
            reportPageOption.Items=reportOptions;
            reportPageOption.Enabled=true;
        end


        function setSelect=getReqSetListSchema(this)


            currentRow=1;
            reqlistCheckBox.Type='checkbox';
            reqlistCheckBox.Name=' ';
            reqlistCheckBox.Value=true;
            reqlistCheckBox.Enabled=true;
            reqlistCheckBox.ObjectMethod='callBackCheckBoxReqList';
            reqlistCheckBox.MethodArgs={'%tag','%value'};
            reqlistCheckBox.ArgDataTypes={'string','mxArray'};

            headers={' ',...
            getString(message('Slvnv:slreq:ReportOPTGUIReqSetListName')),...
            getString(message('Slvnv:slreq:ReportOPTGUIReqSetListPath'))};
            names={this.ReqSets.name};

            criterCnt=numel(names);
            tableData=cell(criterCnt,2);
            for idx=1:criterCnt
                reqlistCheckBox.Tag=['checkbox_reqset',num2str(idx)];
                tableData{idx,1}=reqlistCheckBox;
                tableData{idx,2}=getTextWidget(this.ReqSets(idx).name);
                tableData{idx,3}=getTextWidget(this.ReqSets(idx).filepath);
                this.ReqSetListMap(this.ReqSets(idx).name)=idx-1;
            end

            reqlist.Name='';
            reqlist.Type='table';
            reqlist.HeaderVisibility=[0,1];
            reqlist.LastColumnStretchable=1;
            reqlist.SelectionBehavior='Row';
            reqlist.Editable=true;
            reqlist.Tag='reqrpt_table_reqsetlist';
            reqlist.MultiSelect=false;
            reqlist.RowSpan=[currentRow,currentRow];
            reqlist.ColHeader=headers;
            reqlist.ItemDoubleClickedCallback=@this.callBackReqListItem;
            reqlist.ValueChangedCallback=@(dlg,row,col,val)this.tableValueChange(dlg,...
            row,col,val);
            reqlist.Data=tableData;
            reqlist.Size=[criterCnt,3];
            reqlist.ColSpan=[1,3];

            currentRow=currentRow+1;
            buttonSelectAll.Name=getString(message('Slvnv:slreq:ReportOPTGUIBtnSelectAll'));
            buttonSelectAll.Type='pushbutton';
            buttonSelectAll.Tag='reqrptopt_pushbutton_selectall';
            buttonSelectAll.RowSpan=[currentRow,currentRow];
            buttonSelectAll.ColSpan=[3,3];
            buttonSelectAll.ObjectMethod='callBackSelectAllButton';
            buttonSelectAll.MethodArgs={'%dialog'};
            buttonSelectAll.ArgDataTypes={'handle'};
            buttonSelectAll.Visible=true;

            buttonUnselectAll.Name=getString(message('Slvnv:slreq:ReportOPTGUIBtnUnselectAll'));
            buttonUnselectAll.Type='pushbutton';
            buttonUnselectAll.Tag='reqrptopt_pushbutton_unselectall';
            buttonUnselectAll.RowSpan=[currentRow,currentRow];
            buttonUnselectAll.ColSpan=[3,3];
            buttonUnselectAll.ObjectMethod='callBackUnselectAllButton';
            buttonUnselectAll.MethodArgs={'%dialog'};
            buttonUnselectAll.ArgDataTypes={'handle'};
            buttonUnselectAll.Visible=false;

            setSelect.Type='group';
            setSelect.Tag='reqrptopt_group_reqsetlist';
            setSelect.Name=getString(message('Slvnv:slreq:ReportOPTGUIReqSetListTip'));
            setSelect.Items={reqlist,buttonSelectAll,buttonUnselectAll};
            setSelect.Enabled=true;
            setSelect.LayoutGrid=[currentRow,3];
        end


        function bottomPart=getReportOptionBottemPart(this)
            statusText.Type='text';
            statusText.Tag='reqrptopt_text_status';
            statusText.Name='';
            statusText.Enabled=true;
            statusText.Visible=true;
            statusText.WordWrap=true;
            statusText.RowSpan=[1,1];
            statusText.ColSpan=[1,1];

            generateReportButton.Name=getString(message('Slvnv:slreq:GenerateReport'));
            generateReportButton.Tag='reqrptopt_pushbutton_generatereport';
            generateReportButton.Type='pushbutton';
            generateReportButton.RowSpan=[1,1];
            generateReportButton.ColSpan=[2,2];
            generateReportButton.ObjectMethod='callBackGenerateReportButton';
            generateReportButton.MethodArgs={'%dialog'};
            generateReportButton.ArgDataTypes={'handle'};
            generateReportButton.ToolTip='';

            cancelButton.Name=getString(message('Slvnv:slreq:Cancel'));
            cancelButton.Tag='reqrptopt_pushbutton_canceldialog';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[3,3];
            cancelButton.ObjectMethod='callBackCancelButton';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.ToolTip='ddd';

            helpButton.Name=getString(message('Slvnv:slreq:Help'));
            helpButton.Tag='reqrptopt_help';
            helpButton.Type='pushbutton';
            helpButton.RowSpan=[1,1];
            helpButton.ColSpan=[4,4];
            helpButton.ObjectMethod='callBackHelpButton';
            helpButton.MethodArgs={'%tag'};
            helpButton.ArgDataTypes={'handle'};

            bottomPart.Tag='reqrptopt_panel_standalongbuttons';
            bottomPart.LayoutGrid=[1,4];
            bottomPart.Name='';
            bottomPart.Type='panel';
            bottomPart.ColStretch=[1,0,0,0];
            bottomPart.Items={statusText,generateReportButton,cancelButton,helpButton};
            bottomPart.Enabled=true;
        end
    end

    methods(Static,Access=private)

        function out=setStandaloneButton()

            generateReportButton.Name=getString(message('Slvnv:slreq:GenerateReport'));
            generateReportButton.Tag='reqrptopt_pushbutton_generatereport';
            generateReportButton.Type='pushbutton';
            generateReportButton.RowSpan=[1,1];
            generateReportButton.ColSpan=[2,2];
            generateReportButton.ObjectMethod='callBackGenerateReportButton';
            generateReportButton.MethodArgs={'%dialog'};
            generateReportButton.ArgDataTypes={'handle'};
            generateReportButton.ToolTip='';

            cancelButton.Name=getString(message('Slvnv:slreq:Cancel'));
            cancelButton.Tag='reqrptopt_pushbutton_canceldialog';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[3,3];
            cancelButton.ObjectMethod='callBackCancelButton';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};

            helpButton.Name=getString(message('Slvnv:slreq:Help'));
            helpButton.Tag='reqrptopt_help';
            helpButton.Type='pushbutton';
            helpButton.RowSpan=[1,1];
            helpButton.ColSpan=[4,4];
            helpButton.ObjectMethod='callBackHelpButton';
            helpButton.MethodArgs={'%tag'};
            helpButton.ArgDataTypes={'handle'};


            out.Tag='reqrptopt_panel_standalongbuttons';
            out.LayoutGrid=[1,4];
            out.Name='';
            out.Type='panel';
            out.Items={generateReportButton,cancelButton,helpButton};
            out.Enabled=true;
        end
    end

    methods(Access=public,Hidden=true)





        function callBackCancelButton(~,dlg)
            dlg.delete();
        end


        function callBackHelpButton(~,tag)

            helpview(fullfile(docroot,'slrequirements','helptargets.map'),'requirementsReportDialogBoxID',tag)
        end


        function callBackGenerateReportButton(this,dlg)

            templatePath=slreq.report.utils.getDefaultTemplatePath(this.ReportType(2:end));
            allreqsets=this.getAllSelectedReqSets(dlg);

            opts=slreq.report.utils.getDefaultOptions();
            opts.reportPath=this.ReportFullPath;
            opts.templatePath=templatePath;
            opts.titleText=this.Title;
            opts.authors=this.Authors;
            opts.includes.toc=this.IncludedInReport.toc;
            opts.includes.revision=this.IncludedInReport.revision;
            opts.includes.links=this.IncludedInReport.links;
            opts.includes.changeInformation=this.IncludedInReport.changeInformation;
            opts.includes.comments=this.IncludedInReport.comments;
            opts.includes.implementationStatus=this.IncludedInReport.implementationStatus;
            opts.includes.verificationStatus=this.IncludedInReport.verificationStatus;
            opts.includes.rationale=this.IncludedInReport.rationale;
            opts.includes.customAttributes=this.IncludedInReport.customAttributes;
            opts.includes.emptySections=this.IncludedInReport.emptySection;
            opts.includes.keywords=this.IncludedInReport.keywords;
            opts.includes.groupLinksBy=this.IncludedInReport.groupLinksBy;

            if reqmgt('rmiFeature','TraceabilityTable')
                opts.includes.traceabilityTables=this.IncludedInReport.traceabilityTables;

                opts.includes.groupTraceabilityTablesBy=this.IncludedInReport.groupTraceabilityTablesBy;
                this.setSelectedTraceabilityTablesLinkTypes(dlg);

                opts.includes.traceabilityTablesLinkTypes=this.IncludedInReport.traceabilityTablesLinkTypes;
            end

            opts.openReport=this.OpenReport;
            dlg.delete();
            try
                slreq.report.utils.generateReport(allreqsets,...
                'ReportOptions',opts,...
                'ShowUI',true);
            catch ex
                debugging=exist(fullfile(matlabroot,'toolbox',...
                'slrequirements','slrequirements','+slreq',...
                '+report','OptionDlg.m'),'file');
                if debugging

                    fprintf(2,'%s',ex.message);
                    for k=1:length(ex.stack)
                        [filepath,filename,fileext]=fileparts(ex.stack(k).file);
                        if strcmp(fileext,'.p')
                            fileext='.m';
                        end
                        filefullpath=[filepath,filesep,filename,fileext];
                        hyperlinkinfo=...
                        ['<a href="matlab:opentoline(''',filefullpath,''', ',num2str(ex.stack(k).line),');">',filename,fileext,'</a>'];
                        fprintf('[%d] %s:%d\n',k,hyperlinkinfo,ex.stack(k).line);
                    end
                end
                errordlg(ex.message,getString(message('Slvnv:slreq:ReportGenErrorDLGDefaultTitle')),'modal');
            end


        end


        function onAuthorsChange(this,value)
            this.Authors=value;
        end


        function onTitleChange(this,value)
            this.UseCustomTitle=true;
            this.Title=value;
        end


        function callBackExportReportAs(this,dlg)
            filedir=this.ReportDir;
            filename=this.ReportName;
            fileext=this.ReportType;

            if~exist(filedir,'dir')
                filedir=pwd;
            end



            alllist=this.SupportedFileExtList;
            [saveasfileName,pathname,filterIndex]=uiputfile(alllist,...
            getString(message('Slvnv:slreq:ReportOPTGUIDlgBrowseReportDir')),...
            fullfile(filedir,[filename,fileext]));


            if isempty(saveasfileName)||~ischar(saveasfileName)
                return;
            end

            [~,~,extName]=fileparts(saveasfileName);
            selectedFileExt=alllist{filterIndex,1};

            if~strcmpi(extName,selectedFileExt(2:end))
                saveasfileName=[saveasfileName,selectedFileExt(2:end)];
            end


            [~,newName,~]=fileparts(saveasfileName);
            if isFileRenamed(filename,newName)


                this.UseCustomReportName=true;
            end


            this.ReportDir=pathname;
            this.ReportName=newName;
            this.ReportType=extName;

            dlg.setWidgetValue('reqrptopt_text_reportdircontent',pathname);
            dlg.setWidgetValue('reqrptopt_text_reportnamecontent',saveasfileName);
        end


        function callBackCheckBoxIncludeTOC(this,value)
            this.IncludedInReport.toc=value;
        end


        function callBackCheckBoxIncludeRationale(this,value)
            this.IncludedInReport.rationale=value;
        end

        function callBackCheckBoxIncludeKeywords(this,value)
            this.IncludedInReport.keywords=value;
        end


        function callBackCheckBoxIncludeRevision(this,value)
            this.IncludedInReport.revision=value;
        end


        function callBackCheckBoxIncludeLinks(this,dlg,value)
            this.IncludedInReport.links=value;
            dlg.setEnabled('reqrptopt_radiobutton_grouplinks',value);
            dlg.setEnabled('reqrptopt_checkbox_includechangeinfo',value);
        end


        function callBackRadioButtonGroupLinks(this,value)
            if value==0
                this.IncludedInReport.groupLinksBy='Artifact';
            elseif value==1
                this.IncludedInReport.groupLinksBy='Type';
            end
        end


        function callBackCheckBoxIncludeComments(this,value)
            this.IncludedInReport.comments=value;
        end


        function callBackCheckBoxIncludeImplementationStatus(this,value)
            this.IncludedInReport.implementationStatus=value;
        end


        function callBackCheckBoxIncludeVerificationStatus(this,value)
            this.IncludedInReport.verificationStatus=value;
        end


        function callBackCheckBoxIncludeEmptySection(this,value)
            this.IncludedInReport.emptySection=value;
        end


        function callBackCheckBoxIncludeChangeInfo(this,value)
            this.IncludedInReport.changeInformation=value;
        end



        function callBackCheckBoxIncludeCustomAttributes(this,value)
            this.IncludedInReport.customAttributes=value;
        end


        function callBackSelectAllButton(this,dlg)
            for index=1:length(this.ReqSets)
                dlg.setTableItemValue('reqrpt_table_reqsetlist',index-1,0,'1');
            end
            dlg.setVisible('reqrptopt_pushbutton_selectall',false);
            dlg.setVisible('reqrptopt_pushbutton_unselectall',true);
            this.toggleGenerateReportButton(dlg,true,'');
        end


        function callBackUnselectAllButton(this,dlg)
            for index=1:length(this.ReqSets)
                dlg.setTableItemValue('reqrpt_table_reqsetlist',index-1,0,'0');
            end
            dlg.setVisible('reqrptopt_pushbutton_selectall',true);
            dlg.setVisible('reqrptopt_pushbutton_unselectall',false);
            this.toggleGenerateReportButton(dlg,false,'ReportOPTGUINoReqSelected');
        end


        function callBackCheckBoxIncludeTraceabilityTables(this,dlg,value)
            this.IncludedInReport.traceabilityTables=value;
            dlg.setEnabled('reqrptopt_radiobutton_grouptraceabilitytables',value);

            reqData=slreq.data.ReqData.getInstance()
            linkTypes=reqData.getAllLinkTypes();
            for i=1:numel(linkTypes)
                linkTypeName=linkTypes(i).typeName;
                dlg.setEnabled(['reqrptopt_checkbox_includetraceabilitytableslinktype_',linkTypeName],value);
            end
        end


        function callBackRadioButtonGroupTraceabilityTables(this,value)
            if value==0

                this.IncludedInReport.groupTraceabilityTablesBy='ReqSets';
            elseif value==1

                this.IncludedInReport.groupTraceabilityTablesBy='Reduced Number of Tables';
            end
        end


        function callBackCheckBoxIncludeTraceabilityTablesLinkType(this,dlg,value)

        end
    end

    methods(Access=private)

        function callBackReqListItem(this,~,rowNum,~,~)
            mgr=slreq.app.MainManager.getInstance;
            editor=mgr.requirementsEditor;
            editor.open;
            reqSet=this.ReqSets(rowNum+1);
            editor.selectObjectByUuid(reqSet.getUuid);
        end


        function selectReqSetInTable(this,dlg,reqData)




            allnames={reqData.Name};
            if~isempty(allnames)
                allValue=values(this.ReqSetListMap,allnames);
                allValue=[allValue{:}];
                for index=1:length(this.ReqSets)
                    if any(index-1==allValue)
                        dlg.setTableItemValue('reqrpt_table_reqsetlist',index-1,0,'1');
                    else
                        dlg.setTableItemValue('reqrpt_table_reqsetlist',index-1,0,'0');
                    end
                end
                if this.isAllSelected(dlg)
                    dlg.setVisible('reqrptopt_pushbutton_selectall',false);
                    dlg.setVisible('reqrptopt_pushbutton_unselectall',true);
                elseif this.isAllUnselected(dlg)
                    dlg.setVisible('reqrptopt_pushbutton_selectall',true);
                    dlg.setVisible('reqrptopt_pushbutton_unselectall',false);
                end
            else
                this.toggleGenerateReportButton(dlg,false,'ReportOPTGUINoReqSelected')
                dlg.setVisible('reqrptopt_pushbutton_selectall',true);
                dlg.setEnabled('reqrptopt_pushbutton_selectall',false);
                dlg.setVisible('reqrptopt_pushbutton_unselectall',false);
            end
        end


        function toggleGenerateReportButton(this,dlg,trueorfalse,reasonID)
            dlg.setEnabled('reqrptopt_pushbutton_generatereport',trueorfalse);
            if isempty(reasonID)
                dlg.setWidgetValue('reqrptopt_text_status','');
            else
                dlg.setWidgetValue('reqrptopt_text_status',getString(message(['Slvnv:slreq:',reasonID])));
            end
        end

        function out=getAllFormatList(this)
            out={};
            for index=1:length(this.SupportedTypes)
                switch lower(this.SupportedTypes{index})
                case '.docx'
                    fileformat=getString(message('Slvnv:slreq:ReportOPTGUISupportedFormatDocx'));
                case '.htmx'
                    fileformat=getString(message('Slvnv:slreq:ReportOPTGUISupportedFormatHTMX'));
                case '.html'
                    fileformat=getString(message('Slvnv:slreq:ReportOPTGUISupportedFormatHTML'));
                case '.pdf'
                    fileformat=getString(message('Slvnv:slreq:ReportOPTGUISupportedFormatPDF'));
                case '.xslx'
                    fileformat=getString(message('Slvnv:slreq:ReportOPTGUISupportedFormatXlsx'));
                end
                out{end+1,1}=fileformat;
                out{end,2}=this.SupportedTypes{index};
            end
        end


        function out=ErrorInvalidFileFormat(this)
















            allfilelist=this.getAllFormatList;
            sepchar=sprintf('\n\t');
            allfilelist=strjoin(allfilelist,sepchar);
            out=getString(message('Slvnv:slreq:ReportOPTGUIUnSupportMsg',allfilelist));
        end


        function out=getAllSelectedReqSets(this,dlg)
            selectedRows=[];
            for index=1:length(this.ReqSets)
                if strcmp(dlg.getTableItemValue('reqrpt_table_reqsetlist',index-1,0),'1')
                    selectedRows(end+1)=index;%#ok<AGROW>
                end
            end
            out=this.ReqSets(selectedRows);
        end


        function tableValueChange(this,dlg,~,col,value)
            if col==0
                if value&&this.isAllSelected(dlg)
                    dlg.setVisible('reqrptopt_pushbutton_selectall',false);
                    dlg.setVisible('reqrptopt_pushbutton_unselectall',true);
                    this.toggleGenerateReportButton(dlg,true,'');
                elseif~value&&this.isAllUnselected(dlg)
                    dlg.setVisible('reqrptopt_pushbutton_selectall',true);
                    dlg.setVisible('reqrptopt_pushbutton_unselectall',false);
                    this.toggleGenerateReportButton(dlg,false,'ReportOPTGUINoReqSelected')
                else
                    this.toggleGenerateReportButton(dlg,true,'');
                end
            end

        end


        function out=isAllSelected(this,dlg)
            out=true;
            for index=1:length(this.ReqSets)
                if strcmp(dlg.getTableItemValue('reqrpt_table_reqsetlist',index-1,0),'0')
                    out=false;
                    return;
                end
            end
        end


        function out=isAllUnselected(this,dlg)
            out=true;
            if isempty(this.ReqSets)
                out=false;
                return;
            end
            for index=1:length(this.ReqSets)
                if strcmp(dlg.getTableItemValue('reqrpt_table_reqsetlist',index-1,0),'1')
                    out=false;
                    return;
                end
            end
        end


        function setSelectedTraceabilityTablesLinkTypes(this,dlg)
            this.IncludedInReport.traceabilityTablesLinkTypes='';
            reqData=slreq.data.ReqData.getInstance();
            linkTypes=reqData.getAllLinkTypes();
            for i=1:numel(linkTypes)
                linkTypeName=linkTypes(i).typeName;
                if dlg.getWidgetValue(['reqrptopt_checkbox_includetraceabilitytableslinktype_',linkTypeName])
                    if strcmp(this.IncludedInReport.traceabilityTablesLinkTypes,'')
                        this.IncludedInReport.traceabilityTablesLinkTypes=linkTypeName;
                    else
                        this.IncludedInReport.traceabilityTablesLinkTypes=[this.IncludedInReport.traceabilityTablesLinkTypes,'.',linkTypeName];
                    end
                end
            end
        end
    end
end


function out=getSysUserName()
    if ispc
        out=getenv('USERNAME');
    else
        out=getenv('USER');
    end
end


function out=getTextWidget(content)
    out.Type='text';
    out.Name=content;
    out.ToolTip=content;
end


function tf=isFileRenamed(oldName,newName)



    oldNameWithoutIndex=regexp(oldName,'(.*?)\(\d+\)$','tokens');
    newNameWithoutIndex=regexp(newName,'(.*?)\(\d+\)$','tokens');
    if isempty(oldNameWithoutIndex)
        oldNameWithoutIndex=oldName;
    else
        oldNameWithoutIndex=oldNameWithoutIndex{1}{1};
    end

    if isempty(newNameWithoutIndex)
        newNameWithoutIndex=newName;
    else
        newNameWithoutIndex=newNameWithoutIndex{1}{1};
    end

    tf=~strcmpi(oldNameWithoutIndex,newNameWithoutIndex);
end