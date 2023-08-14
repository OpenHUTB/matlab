classdef ImportDlg<handle











    properties(Access=private)


        srcType=0;
        current={};
        srcDoc='';
        docObj=[];
        errorText='';


        style=0;
        mapping=0;
        bookmarks=true;
        pattern='';


        childDlg=[];


        ignoreOutlineNumbers=false;


        subDoc='';
        subDocPrefix=false;
        columns=[];
        rows=[];
        columnHeaders={};
        idColumn=[];
        summaryColumn=[];
        descriptionColumn=[];
        rationaleColumn=[];
        keywordsColumn=[];
        createdByColumn=[];
        modifiedByColumn=[];
        attributeColumn=[];


        attributeMap=[];
        reqifData=[];
        reqIFPanel;
        mappingOptions=[];
        subDocs={};
        filterString='';


serverName
serverUser
serverPass
        serverCatalog=struct('projectNames',{},'serviceURIs',{},'projectURIs',{});
        queryString='';
        connectionMode=1;
        modulesInfo=[];
        queryHistory={};

    end

    properties

        importMode=1;
        destReqSet='';
        destFolder=''


        pickDir=false;

        isReqsetContext=false;


        onCancel;

        PreImportFcn='';
        PostImportFcn='';
    end



    methods(Access=public)

        function this=ImportDlg()
            this.reqIFPanel=slreq.import.ui.ReqIFPanel();
            lh=addlistener(this.reqIFPanel,'ReqSetNameChanged',@this.onReqSetNameChanged);%#ok<NASGU>
        end


        function dlgstruct=getDialogSchema(this)
            if isempty(this.destReqSet)&&~isempty(this.srcDoc)&&~this.isReqsetContext
                this.destReqSet=[this.makeReqSetNameForSrcDoc(),'.slreqx'];
            end



            dlgstruct.DialogTitle=getString(message('Slvnv:slreq_import:ImportingRequirements'));
            if ismac


                dlgstruct.Sticky=false;
            else
                dlgstruct.Sticky=true;
            end

            dlgstruct.DialogTag='SlreqImportDlg';
            dlgstruct.CloseMethod='SlreqImportDlg_Cancel_callback';
            dlgstruct.CloseMethodArgs={'%dialog'};
            dlgstruct.CloseMethodArgsDT={'handle'};

            if this.isReqsetContext||isempty(this.srcDoc)
                reqSetOptions={};
                dlgstruct.LayoutGrid=[5,3];

            else
                reqSetOptions={...
                this.destinationGroup(),...
                this.spacer([5,5],[1,4])};
                dlgstruct.LayoutGrid=[5,5];

            end

            if isempty(this.srcDoc)
                dlgstruct.Items=[{...
                this.sourceGroup(),...
                this.spacer([3,3],[1,4]),...
                this.spacer([4,4],[1,4])},...
                reqSetOptions];
            else
                dlgstruct.Items=[{...
                this.sourceGroup(),...
                this.optionsGroup(),...
                this.spacer([4,4],[1,4])},...
                reqSetOptions];
                if reqmgt('rmiFeature','ReqCallbacks')
                    dlgstruct.Items{end+1}=slreq.internal.gui.createCallbackTabs(this,{'PreImportFcn','PostImportFcn'});
                end
            end



            dlgstruct.StandaloneButtonSet=this.setStandaloneButtons();

            dlgstruct.CloseCallback='slreq.import.ui.dlg_mgr';
            dlgstruct.CloseArgs={'clear'};

        end
    end

    methods(Access=private)


        function onReqSetNameChanged(this,~,eventData)
            if this.reqIFPanel.getAsMutlipleReqSets()

                this.pickDir=true;

                this.destFolder=fileparts(this.destReqSet);


                eventData.dlg.setEnabled('SlreqImportDlg_reqSetEdit',false);

                eventData.dlg.setWidgetValue('SlreqImportDlg_destination',...
                getString(message('Slvnv:slreq_import:DestinationFolder')));

                eventData.dlg.setWidgetValue('SlreqImportDlg_reqSetEdit',this.destFolder);
            else

                this.destReqSet=this.getValidReqSetName(this.destReqSet);


                this.pickDir=false;

                eventData.dlg.setEnabled('SlreqImportDlg_reqSetEdit',true);

                eventData.dlg.setWidgetValue('SlreqImportDlg_destination',...
                getString(message('Slvnv:slreq_import:DestinationFile')));

                eventData.dlg.setWidgetValue('SlreqImportDlg_reqSetEdit',this.destReqSet);
            end
        end


        function setDestReqSet(this,destReqSet)

            if~this.isReqsetContext
                this.destReqSet=destReqSet;
            end
        end

        function schema=sourceGroup(this)

            sourceTypeLabel.Type='text';
            sourceTypeLabel.Name=getString(message('Slvnv:slreq_import:DocType'));
            sourceTypeLabel.RowSpan=[1,1];
            sourceTypeLabel.ColSpan=[1,1];
            sourceTypeLabel.Alignment=7;

            sourceTypeCombo.Type='combobox';
            sourceTypeCombo.Tag='SlreqImportDlg_TypeCombo';


            if ispc()
                sourceTypeCombo.Entries={['<',getString(message('Slvnv:slreq_import:SelectDocType')),'>'],...
                getString(message('Slvnv:slreq_import:MicrosoftWordDocument')),...
                getString(message('Slvnv:slreq_import:MicrosoftExcelSpreadsheet'))};
                sourceTypeCombo.Values=[0,1,2];
            else
                sourceTypeCombo.Entries={['<',getString(message('Slvnv:slreq_import:SelectDocType')),'>']};
                sourceTypeCombo.Values=0;
            end


            sourceTypeCombo.Entries{end+1}=getString(message('Slvnv:slreq_import:ReqifFile'));
            sourceTypeCombo.Values(end+1)=3;


            if is_doors_installed()&&rmidoors.isAppRunning('nodialog')
                sourceTypeCombo.Entries{end+1}=getString(message('Slvnv:slreq_import:IBMRationalDoorsModule'));
                sourceTypeCombo.Values(end+1)=4;
            end


            if~this.isReqsetContext
                sourceTypeCombo.Entries{end+1}=getString(message('Slvnv:slreq_import:IBMRationalDoorsNext'));
                sourceTypeCombo.Values(end+1)=5;
            end

            sourceTypeCombo.Value=this.srcType;
            sourceTypeCombo.RowSpan=[1,1];
            sourceTypeCombo.ColSpan=[2,4];
            sourceTypeCombo.ObjectMethod='SlreqImportDlg_TypeCombo_callback';
            sourceTypeCombo.MethodArgs={'%dialog'};
            sourceTypeCombo.ArgDataTypes={'handle'};

            sourceDocCurrent.Type='pushbutton';
            sourceDocCurrent.Name=getString(message('Slvnv:slreq_import:UseCurrent'));
            sourceDocCurrent.Tag='SlreqImportDlg_docCurrent';
            sourceDocCurrent.RowSpan=[1,1];
            sourceDocCurrent.ColSpan=[5,5];
            sourceDocCurrent.ObjectMethod='SlreqImportDlg_UseCurrent_callback';
            sourceDocCurrent.MethodArgs={'%dialog'};
            sourceDocCurrent.ArgDataTypes={'handle'};
            sourceDocCurrent.Enabled=(this.srcType>0&&this.srcType~=3);

            sourceDocLabel.Type='text';
            sourceDocLabel.Name=getString(message('Slvnv:slreq_import:DocLocation'));
            sourceDocLabel.RowSpan=[2,2];
            sourceDocLabel.ColSpan=[1,1];
            sourceDocLabel.Alignment=7;
            sourceDocLabel.Enabled=(this.srcType>0);

            sourceDocCombo.Type='combobox';
            sourceDocCombo.Tag='SlreqImportDlg_docEdit';
            if isempty(this.srcDoc)
                if this.srcType==5
                    sourceDocCombo.Value=getString(message('Slvnv:slreq_import:DngSelectProjectArea'));
                else
                    sourceDocCombo.Value=getString(message('Slvnv:slreq_import:DocToImportNoValue'));
                end

            else
                sourceDocCombo.Value=this.srcDoc;
            end
            sourceDocCombo.Editable=true;
            sourceDocCombo.RowSpan=[2,2];
            sourceDocCombo.ColSpan=[2,4];
            sourceDocCombo.Mode=true;
            sourceDocCombo.Entries={};
            if this.srcType>0
                switch this.srcType
                case 1

                    sourceDocCombo.Entries=slreq.import.findFilesInFolder(pwd,'.doc');

                    openDocsInfo=rmidotnet.MSWord.getOpenDocuments();
                    for i=1:size(openDocsInfo,1)
                        oneDoc=fullfile(openDocsInfo{i,2},openDocsInfo{i,1});
                        if~contains(oneDoc,sourceDocCombo.Entries)
                            sourceDocCombo.Entries{end+1,1}=oneDoc;
                        end
                    end
                case 2

                    sourceDocCombo.Entries=slreq.import.findFilesInFolder(pwd,'.xls');

                    openDocsInfo=rmidotnet.MSExcel.getOpenDocuments();
                    for i=1:size(openDocsInfo,1)
                        oneDoc=fullfile(openDocsInfo{i,2},strtok(openDocsInfo{i,1},'|'));
                        if~contains(oneDoc,sourceDocCombo.Entries)
                            sourceDocCombo.Entries{end+1,1}=oneDoc;
                        end
                    end
                case 3

                    sourceDocCombo.Entries=slreq.import.findFilesInFolder(pwd,'.reqif');

                case 4

                    if~isempty(this.current)
                        sourceDocCombo.Entries=this.current;
                    end

                case 5

                    sourceDocCombo.Entries=this.serverCatalog.projectNames(:);

                otherwise

                    rmiut.warnNoBacktrace('invalid case in srcType switch statement');
                end
            end
            sourceDocCombo.ObjectMethod='SlreqImportDlg_docEdit_callback';
            sourceDocCombo.MethodArgs={'%dialog'};
            sourceDocCombo.ArgDataTypes={'handle'};
            sourceDocCombo.Enabled=true;

            sourceDocBrowse.Type='pushbutton';
            sourceDocBrowse.Name=getString(message('Slvnv:slreq_import:Browse'));
            sourceDocBrowse.Tag='SlreqImportDlg_docBrowse';
            sourceDocBrowse.RowSpan=[2,2];
            sourceDocBrowse.ColSpan=[5,5];
            sourceDocBrowse.ObjectMethod='SlreqImportDlg_docBrowse_callback';
            sourceDocBrowse.MethodArgs={'%dialog'};
            sourceDocBrowse.ArgDataTypes={'handle'};
            sourceDocBrowse.Enabled=(this.srcType<5);

            schema.Type='group';
            schema.Name=getString(message('Slvnv:slreq_import:Source'));
            schema.LayoutGrid=[4,5];
            schema.Items={...
            sourceTypeLabel,sourceTypeCombo,sourceDocCurrent,...
            sourceDocLabel,sourceDocCombo,sourceDocBrowse};
            if~isempty(this.srcDoc)&&this.srcType==2
                schema.Items(end+1:end+3)=this.xlsSheetSelector();
            elseif~isempty(this.srcDoc)&&this.srcType==5
                schema.Items(end+1:end+2)=this.dngModuleSelector();
            else
                schema.Items{end+1}=this.spacer([3,3],[1,5]);
            end
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,4];
        end

        function schema=optionsGroup(this)
            schema.Type='panel';
            switch this.srcType
            case 1
                [schema.Items,schema.LayoutGrid]=this.msWordOptions();
            case 2
                [schema.Items,schema.LayoutGrid]=this.msExcelOptions();
            case 3
                [schema.Items,schema.LayoutGrid]=this.reqIFPanel.getMappingOptions(this.srcDoc);
            case 4
                [schema.Items,schema.LayoutGrid]=this.doorsOptions();
            case 5
                [schema.Items,schema.LayoutGrid]=this.dngOptions();
            otherwise


            end
            schema.RowSpan=[2,2];
            schema.ColSpan=[1,4];
            schema.Enabled=~isempty(this.srcDoc);

            if ispc()
                reqmgt('winFocus',getString(message('Slvnv:slreq_import:ImportingRequirements')));
            end
        end

        function schema=spacer(~,rowSpan,colSpan)
            schema.Type='text';
            schema.Name=' ';
            schema.RowSpan=rowSpan;
            schema.ColSpan=colSpan;
        end

        function schema=destinationGroup(this)

            reqSetLabel.Type='text';
            reqSetLabel.Name=getString(message('Slvnv:slreq_import:DestinationFile'));
            reqSetLabel.Tag='SlreqImportDlg_destination';
            reqSetLabel.RowSpan=[1,1];
            reqSetLabel.ColSpan=[1,1];
            reqSetLabel.Alignment=7;

            reqSetEdit.Type='edit';
            reqSetEdit.Tag='SlreqImportDlg_reqSetEdit';
            this.setDestReqSet(this.getValidReqSetName(this.destReqSet));
            reqSetEdit.Value=this.destReqSet;
            reqSetEdit.Editable=true;
            reqSetEdit.RowSpan=[1,1];
            reqSetEdit.ColSpan=[2,4];
            reqSetEdit.Mode=true;

            reqSetEdit.Enabled=~isempty(this.srcDoc)&&~this.isReqsetContext;

            reqSetEdit.ObjectMethod='SlreqImportDlg_reqSetEdit_callback';
            reqSetEdit.MethodArgs={'%dialog'};
            reqSetEdit.ArgDataTypes={'handle'};

            reqSetBrowse.Type='pushbutton';
            reqSetBrowse.Name=getString(message('Slvnv:slreq_import:Browse'));
            reqSetBrowse.Tag='SlreqImportDlg_reqSetBrowse';
            reqSetBrowse.RowSpan=[1,1];
            reqSetBrowse.ColSpan=[5,5];

            reqSetBrowse.Enabled=~isempty(this.srcDoc)&&~this.isReqsetContext;
            reqSetBrowse.ObjectMethod='SlreqImportDlg_reqSetBrowse_callback';
            reqSetBrowse.MethodArgs={'%dialog'};
            reqSetBrowse.ArgDataTypes={'handle'};

            importModeCheck.Type='checkbox';
            importModeCheck.Name=getString(message('Slvnv:slreq_import:ImportAsReadOnly'));
            importModeCheck.ToolTip=getString(message('Slvnv:slreq_import:ImportAsReadOnlyTooltip'));
            importModeCheck.Tag='SlreqImportDlg_importModeCheck';

            if this.srcType>3
                importModeCheck.Value=true;
                importModeCheck.Enabled=false;
            else
                importModeCheck.Value=this.importMode;
            end
            importModeCheck.RowSpan=[2,2];
            importModeCheck.ColSpan=[2,4];
            importModeCheck.ObjectMethod='SlreqImportDlg_importModeCheck_callback';
            importModeCheck.MethodArgs={'%dialog','%value'};
            importModeCheck.ArgDataTypes={'handle','mxArray'};

            schema.Type='group';
            schema.Name=getString(message('Slvnv:slreq_import:DestinationSet'));
            schema.LayoutGrid=[2,5];
            schema.Items={reqSetLabel,reqSetEdit,reqSetBrowse,importModeCheck};
            schema.RowSpan=[4,4];
            schema.ColSpan=[1,4];

            schema.Enabled=~this.isReqsetContext;

        end

        function out=setStandaloneButtons(this)

            isReady=this.isReadyForImport();

            noteText.Type='text';
            noteText.Tag='SlreqImportDlg_blockingMsg';
            noteText.Name=this.errorText;
            noteText.ForegroundColor=[255,0,0];
            noteText.Alignment=1;
            noteText.RowSpan=[1,1];
            noteText.ColSpan=[1,2];

            importButton.Name=getString(message('Slvnv:slreq_import:Import'));
            importButton.Tag='SlreqImportDlg_Import';
            importButton.Type='pushbutton';
            importButton.RowSpan=[1,1];
            importButton.ColSpan=[3,3];
            importButton.ObjectMethod='SlreqImportDlg_Import_callback';
            importButton.MethodArgs={'%dialog'};
            importButton.ArgDataTypes={'handle'};
            importButton.Enabled=isReady;

            cancelButton.Name=getString(message('Slvnv:slreq_import:Cancel'));
            cancelButton.Tag='SlreqImportDlg_Cancel';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[4,4];
            cancelButton.ObjectMethod='SlreqImportDlg_Cancel_callback';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.Enabled=true;

            helpButton.Name=getString(message('Slvnv:slreq_import:Help'));
            helpButton.Tag='SlreqImportDlg_Help';
            helpButton.Type='pushbutton';
            helpButton.RowSpan=[1,1];
            helpButton.ColSpan=[5,5];
            helpButton.ObjectMethod='SlreqImportDlg_Help_callback';
            helpButton.MethodArgs={'%dialog'};
            helpButton.ArgDataTypes={'handle'};
            helpButton.Enabled=true;

            out.Tag='SlreqImportDlg_standalonebuttons';
            out.LayoutGrid=[1,5];
            out.Name='';
            out.Type='panel';
            out.Items={noteText,importButton,cancelButton,helpButton};
        end

        function tf=isReadyForImport(this)
            tf=false;
            this.errorText='';

            if isempty(this.srcDoc)

                this.errorText=getString(message('Slvnv:slreq_import:SpecifyDocumentToImport'));
                return;
            end
            switch this.srcType
            case 1

                if this.mapping==0||~isempty(this.pattern)
                    tf=true;
                    this.errorText='';
                else
                    this.errorText=getString(message('Slvnv:slreq_import:SpecifyIdPattern'));
                end
            case 2

                if this.mapping==0&&isempty(this.columns)
                    this.errorText=getString(message('Slvnv:slreq_import:SpecifyColumnMapping'));
                elseif this.mapping==1&&isempty(this.pattern)
                    this.errorText=getString(message('Slvnv:slreq_import:SpecifyIdPattern'));
                else
                    tf=true;
                    this.errorText='';
                end
            case 3

                tf=this.reqIFPanel.isReady();
                this.errorText=this.reqIFPanel.getError();
            case 4


                tf=true;
                this.errorText='';
                wantedModuleId=strtok(this.srcDoc);
                if~strcmp(wantedModuleId,rmidoors.getCurrentObj())

                    try
                        doorsApi=rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors');
                        doorsApi.NavigateFcn(wantedModuleId,'');

                        reqmgt('winFocus',getString(message('Slvnv:slreq_import:ImportingRequirements')));
                    catch
                        this.errorText=getString(message('Slvnv:slreq_import:NotCurrentDoorsModule',this.srcDoc));
                        tf=false;
                        return;
                    end
                end
            case 5

                if this.connectionMode==0
                    tf=~isempty(this.subDoc);
                    if~tf
                        this.errorText=getString(message('Slvnv:slreq_import:DngModuleNotSpecified'));
                    end
                else
                    tf=~isempty(this.queryString);
                    if~tf
                        this.errorText=getString(message('Slvnv:slreq_import:DngQueryNotSpecified'));
                    end
                end
            otherwise

                this.errorText=getString(message('Slvnv:slreq_import:SpecifyDocumentToImport'));
            end



            if~this.isReqsetContext
                try
                    slreq.uri.errorOnInvalidReqSetName(this.destReqSet);
                catch ex
                    tf=false;
                    this.errorText=ex.message;
                    return;
                end

                if this.pickDir

                else

                    if tf
                        this.warnAboutOverwriting(this.destReqSet);
                    end
                end
            end

        end

        function warn=warnAboutOverwriting(this,reqSetFile)
            warn=false;





            if exist(reqSetFile,'file')==2
                reqSetName=slreq.uri.getShortNameExt(reqSetFile);
                this.errorText=getString(message('Slvnv:slreq:SavingRequirementSetQuestDlg',reqSetName));


                warn=true;
            end
        end

        function tf=isReadyForAttributeSelection(this)
            if this.srcType==2
                tf=~isempty(this.srcDoc)&&~isempty(this.subDoc);
            else
                tf=~isempty(this.srcDoc);
            end
        end

        function tf=isReadyForPreview(this)
            if isempty(this.srcDoc)
                tf=false;
                return;
            end

            if this.srcType==1
                if this.bookmarks&&this.mapping==0
                    tf=true;
                elseif this.mapping==1&&~isempty(this.pattern)
                    tf=true;
                else
                    tf=false;
                end
            else
                tf=(this.mapping>0&&~isempty(this.pattern));
            end
        end

        function optStruct=msOptionsStruct(this)

            optStruct.richText=(this.style>0);
            optStruct.preImportFcn=this.PreImportFcn;
            optStruct.postImportFcn=this.PostImportFcn;
            if~isempty(this.pattern)
                optStruct.match=this.pattern;
            end

            if this.srcType==1
                optStruct.bookmarks=this.bookmarks;
                optStruct.ignoreOutlineNumbers=this.ignoreOutlineNumbers;

            elseif this.srcType==2

                if~isempty(this.columns)
                    optStruct.subDoc=this.subDoc;
                    optStruct.subDocPrefix=this.subDocPrefix;
                    optStruct.columns=this.columns;
                    optStruct.rows=this.rows;
                    optStruct.headers=this.columnHeaders;
                    optStruct.summaryColumn=this.summaryColumn;
                    if~isempty(this.idColumn)
                        optStruct.idColumn=this.idColumn;
                    end
                    if~isempty(this.descriptionColumn)
                        optStruct.descriptionColumn=this.descriptionColumn;
                    end
                    if~isempty(this.rationaleColumn)
                        optStruct.rationaleColumn=this.rationaleColumn;
                    end
                    if~isempty(this.keywordsColumn)
                        optStruct.keywordsColumn=this.keywordsColumn;
                    end
                    if~isempty(this.attributeColumn)
                        optStruct.attributeColumn=this.attributeColumn;
                    end
                    if~isempty(this.createdByColumn)
                        optStruct.createdByColumn=this.createdByColumn;
                    end
                    if~isempty(this.modifiedByColumn)
                        optStruct.modifiedByColumn=this.modifiedByColumn;
                    end
                end




                usdmFlag='USDM';
                usdmFlagLength=length(usdmFlag);
                if strncmpi(this.pattern,'USDM',usdmFlagLength)
                    optStruct.usdm=true;
                    optStruct.match=slreq.import.usdmParamsToPattern(strtrim(this.pattern(usdmFlagLength+1:end)));
                end
            else


            end
        end

        function clearStaleOptions(this)


            this.mapping=0;
            this.pattern='';
            this.rows=[];
            this.columns=[];
            this.columnHeaders={};
            this.idColumn=[];
            this.summaryColumn=[];
            this.descriptionColumn=[];
            this.rationaleColumn=[];
            this.keywordsColumn=[];
            this.attributeColumn=[];
            this.attributeMap=[];
            this.subDocs={};

            this.docObj=[];

            this.attributeMap=[];
            this.reqifData=[];

            this.queryString='';

            this.modulesInfo=[];
            this.queryHistory={};
            this.PreImportFcn='';
            this.PostImportFcn='';
        end

        function clearStaleBookmarkOptions(this)
            this.style=0;
            this.bookmarks=true;
            this.mapping=0;
            this.pattern='';
            this.ignoreOutlineNumbers=false;
        end

        function options=doorsOptionalArgs(this)
            attributes={};
            options.DocID=this.srcDoc;
            options.preImportFcn=this.PreImportFcn;
            options.postImportFcn=this.PostImportFcn;
            options.richText=(this.style>0);
            options.filterString=this.filterString;
            if~isempty(this.attributeMap)
                ks=keys(this.attributeMap);
                for i=1:length(ks)
                    key=ks{i};
                    val=this.attributeMap(key);
                    if any(strcmp(val,{'Rationale','Keywords'}))

                        options.(lower(val))=key;
                    else

                        attributes{end+1}=val;%#ok<AGROW>
                    end
                end
                if~isempty(attributes)
                    options.attributes=attributes;
                end
            end
        end



        function[reqSetName,multiReqSets]=makeReqSetNameForSrcDoc(this)

            multiReqSets=false;

            switch this.srcType
            case 3

                multiReqSets=this.reqIFPanel.getAsMutlipleReqSets();


                firstReqSetName=this.reqIFPanel.getFirstReqSetName();
                if~isempty(firstReqSetName)&&multiReqSets
                    reqSetName=fullfile(this.destFolder,[firstReqSetName,'.slreqx']);
                else

                    reqSetName=slreq.import.makeReqSetNameForSrcDoc('file',this.srcDoc);
                end

            case 4
                reqSetName=slreq.import.makeReqSetNameForSrcDoc('linktype_rmi_doors',this.srcDoc);

            otherwise
                reqSetName=slreq.import.makeReqSetNameForSrcDoc('file',this.srcDoc);

            end
        end

    end



    methods(Access=public,Hidden=true)

        function SlreqImportDlg_Cancel_callback(this,dlg)
            dlg.delete();
            if~isempty(this.onCancel)
                this.onCancel();
            end
        end

        function SlreqImportDlg_Help_callback(~,~)
            helpview(fullfile(docroot,'slrequirements','helptargets.map'),'slreqImportReqID');
        end

        function SlreqImportDlg_importModeCheck_callback(this,dlg,value)
            this.importMode=dlg.getWidgetValue('SlreqImportDlg_importModeCheck');
            dlg.setEnabled('PostImportFcn_tab',value);
        end

        function SlreqImportDlg_reqSetBrowse_callback(this,dlg)

            if this.pickDir
                destDir=uigetdir();
                if destDir~=0
                    this.destFolder=destDir;
                    dlg.setWidgetValue('SlreqImportDlg_reqSetEdit',this.destFolder);
                end
            else


                suggestedName='';
                if~isempty(this.srcDoc)
                    [~,suggestedName]=fileparts(this.srcDoc);
                end

                fullFile=slreq.uri.getNewReqSetFilePath(suggestedName,true);

                if~isempty(fullFile)
                    this.setDestReqSet(fullFile);
                    dlg.setWidgetValue('SlreqImportDlg_reqSetEdit',this.destReqSet);
                end

                this.refreshDlg(dlg);
            end
        end

        function out=getValidReqSetName(this,reqSetName)

            if isempty(reqSetName)

                if isempty(this.srcDoc)
                    out='$DocumentName$.slreqx';
                else
                    out=[this.makeReqSetNameForSrcDoc(),'.slreqx'];
                end

            elseif contains(reqSetName,'$DocumentName$')
                out=reqSetName;

            else


                [reqSetPath,reqSetName]=fileparts(reqSetName);
                reqSetFilename=fullfile(reqSetPath,[reqSetName,'.slreqx']);

                if rmiut.isCompletePath(reqSetFilename)
                    out=reqSetFilename;
                else

                    reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetName);
                    if~isempty(reqSet)
                        out=reqSet.filepath;
                    else

                        out=rmiut.simplifypath(fullfile(pwd,reqSetFilename));
                    end
                end
            end
        end


        function SlreqImportDlg_reqSetEdit_callback(this,dlg)
            userInputName=dlg.getWidgetValue('SlreqImportDlg_reqSetEdit');


            this.setDestReqSet(this.getValidReqSetName(userInputName));

            dlg.setWidgetValue('SlreqImportWizard_reqSetEdit',this.destReqSet);

            this.refreshDlg(dlg);
        end

        function SlreqImportDlg_subDocPrefix_callback(this,dlg)
            this.subDocPrefix=dlg.getWidgetValue('SlreqImportDlg_subDocPrefix');
        end

        function SlreqImportDlg_styleOption_callback(this,dlg)
            this.style=dlg.getWidgetValue('SlreqImportDlg_styleOption');
        end

        function SlreqImportDlg_filterOption_callback(this,dlg)
            switch this.srcType
            case 4
                checkboxValue=dlg.getWidgetValue('SlreqImportDlg_filterOption');
                if checkboxValue
                    doorsModuleId=rmidoors.getCurrentObj();
                    this.filterString=rmidoors.getModuleAttribute(doorsModuleId,'rowFilter');
                else
                    this.filterString='';
                end
            otherwise

            end
        end

        function SlreqImportDlg_filterRefresh_callback(this,dlg)
            if(this.srcType==4)

                this.refreshDlg(dlg);
                this.SlreqImportDlg_filterOption_callback(dlg);
            end
        end

        function SlreqImportDlg_bookmarkCheck_callback(this,dlg)
            this.bookmarks=dlg.getWidgetValue('SlreqImportDlg_bookmarkCheck');
            dlg.setEnabled('SlreqImportDlg_Preview',this.isReadyForPreview());
        end

        function SlreqImportDlg_patternCheck_callback(this,dlg)
            value=dlg.getWidgetValue('SlreqImportDlg_patternCheck');
            dlg.setEnabled('SlreqImportDlg_patternLabel',value);
            dlg.setEnabled('SlreqImportDlg_patternEdit',value);
            this.mapping=0+value;
            if value
                this.pattern=dlg.getWidgetValue('SlreqImportDlg_patternEdit');
            else
                this.pattern='';
            end
            this.refreshDlg(dlg);
        end

        function SlreqImportDlg_numbersCheck_callback(this,dlg)
            this.ignoreOutlineNumbers=dlg.getWidgetValue('SlreqImportDlg_numbersCheck');
        end

        function SlreqImportDlg_patternEdit_callback(this,dlg)
            this.pattern=dlg.getWidgetValue('SlreqImportDlg_patternEdit');
            this.refreshDlg(dlg);
        end

        function SlreqImportDlg_mappingOption_callback(this,dlg)
            this.mapping=dlg.getWidgetValue('SlreqImportDlg_mappingOption');
            this.refreshDlg(dlg);



            dlg.setEnabled('SlreqImportDlg_patternEdit',(this.mapping==1));
        end



        SlreqImportDlg_dngMode_callback(this,dlg)

        SlreqImportDlg_UseCurrent_callback(this,dlg)

        SlreqImportDlg_Preview_callback(this,~)

        SlreqImportDlg_attributeSelector_callback(this,dlg)

        SlreqImportDlg_subDocCombo_callback(this,dlg)

        [count,dataReqSet]=SlreqImportDlg_dngImport_callback(this,dlg)

        SlreqImportDlg_docBrowse_callback(this,dlg)

        SlreqImportDlg_docEdit_callback(this,dlg)

        SlreqImportDlg_TypeCombo_callback(this,dlg)

        SlreqImportDlg_dngRawQuery_callback(this,dlg)

        DngOptions_queryHistory_callback(this,dlg)

        SlreqImportDlg_Import_callback(this,dlg)

        SlreqImportDlg_Callbacks_callback(this,dlg)

        setExcelOptionsFromChildDialog(this,childDlgSrc,commit)

        setAttributesFromDoorsDialog(this,childDlgSrc,commit)

        setAttributesFromReqifDialog(this,childDlgSrc,commit)

        setOslcOptionsFromQueryBuilderDialog(this,childDlgSrc,commit)

    end



    methods(Access=private)


        function populateReqIfMapping(this)

            info=slreq.import.ui.ReqIfMappingInfo(this.reqifData,this.attributeMap);
            info.doit();
            this.mappingOptions=info.options;
        end

        function populateDoorsMapping(this,attributeMap)
            attributeMapping=slreq.import.ui.DoorsMappingInfo(attributeMap);
            attributeMapping.doit();
            this.mappingOptions=attributeMapping.options;
            this.mappingOptions.name=strtok(this.srcDoc);
        end


        function populateExcelMapping(this,columnIndex,columnOptions,rawColumns,userColumns)
            info=slreq.import.ui.ExcelMappingInfo(columnIndex,columnOptions,rawColumns,userColumns);
            info.doit();
            this.mappingOptions=info.options;
        end

        function refreshDlg(~,dlg)


            dlg.apply();


            dlg.refresh();



            if ispc()
                reqmgt('winFocus',getString(message('Slvnv:slreq_import:ImportingRequirements')));
            end
        end



        function SlreqImportDlg_dngProjectSelected(this,dlg,dngProjName)
            this.srcDoc=dngProjName;
            this.refreshDlg(dlg);
        end

    end



    methods(Static)

        function warnIfNonUniqueCustomIds(reqSet,sourceDoc,subDoc)
            try
                rootCustomId=slreq.internal.getImportRootId(sourceDoc,subDoc);
                nonUniqueCustomIds=reqSet.preSynchronize(rootCustomId);
            catch ex
                if strcmp(ex.identifier,'Slvnv:reqmgt:synchro:InvalidRootCustomId')



                    return;
                else
                    throw(ex);
                end
            end
            slreq.utils.warnNonUniqueCustomIds(sourceDoc,nonUniqueCustomIds);
        end



        function[uri,id]=getModuleUri(modulesInfo,selectedModuleName)
            selectedModuleIdx=find(strcmp(modulesInfo.title,selectedModuleName));
            if~isempty(selectedModuleIdx)
                uri=modulesInfo.uri{selectedModuleIdx(1)};
                id=modulesInfo.id{selectedModuleIdx(1)};



            else

                errordlg(sprintf('module %s not found',selectedModuleName));
                uri='';
                id='';
            end
        end

        function[uri,serviceUri]=getProjectUri(projectsInfo,selectedProjectName)
            selectedProjectIdx=find(strcmp(projectsInfo.projectNames,selectedProjectName));
            if length(selectedProjectIdx)==1
                uri=projectsInfo.projectURIs{selectedProjectIdx};
                serviceUri=projectsInfo.serviceURIs{selectedProjectIdx};
            else

                errordlg(sprintf('project %s not found',selectedProjectName));
                uri='';
                serviceUri='';
            end
        end
    end
end



