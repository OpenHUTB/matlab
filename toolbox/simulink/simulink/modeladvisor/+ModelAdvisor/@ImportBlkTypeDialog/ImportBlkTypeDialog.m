classdef(CaseInsensitiveProperties=true)ImportBlkTypeDialog<matlab.mixin.Copyable




    properties(Constant)
        cDialogTag='ModelAdvisorImportBlkTypeDialog';
        cBlkTypeSourceEnum={DAStudio.message('ModelAdvisor:engine:Library'),DAStudio.message('ModelAdvisor:engine:slBlkSupportTable'),DAStudio.message('ModelAdvisor:engine:cstBlkSupportTable'),DAStudio.message('ModelAdvisor:engine:cvstBlkSupportTable'),DAStudio.message('ModelAdvisor:engine:dstBlkSupportTable')};
        cBlkTypeSourceEnum_NoBlkSptTbl={DAStudio.message('ModelAdvisor:engine:Library')};
        cImportTypeEnum={DAStudio.message('ModelAdvisor:engine:AddintoTbl'),DAStudio.message('ModelAdvisor:engine:RemovefromTbl'),DAStudio.message('ModelAdvisor:engine:ReplaceTbl')};
    end

    properties(Access=public)
        BlkTypeSource='';
        BlkListInterpretionMode=0;
        ImportType='';
        LibraryPath='';
        InternalValues=[];
        doNotReadInternalValues=false;
        TaskNode=[];
        InputParameter=[];
        TaskNodeDialog=[];
    end

    methods(Static=true)
        function instance=getInstance()
            persistent dlgInstance;
            if isempty(dlgInstance)||~isvalid(dlgInstance)
                dlgInstance=ModelAdvisor.ImportBlkTypeDialog();
            end
            instance=dlgInstance;
        end

        function deleteInstance()
            dlgObj=ModelAdvisor.ImportBlkTypeDialog.getInstance();
            delete(dlgObj);
        end
    end

    methods

        function this=ImportBlkTypeDialog()
            this.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:Library');
            this.ImportType='Add into table';
            this.syncInternalValues('write');
        end

        function dlg=getDialogSchema(this,~)
            if~this.doNotReadInternalValues
                this.syncInternalValues('read');
            else
                this.doNotReadInternalValues=false;
            end
            tabContainer=getTabContainer(this);
            dlg.DialogTag=ModelAdvisor.ImportBlkTypeDialog.cDialogTag;
            dlg.DialogTitle=DAStudio.message('ModelAdvisor:engine:ImportBlkTypes');
            dlg.Items={tabContainer};
            dlg.DisplayIcon=fullfile('toolbox','simulink','simulink','modeladvisor','resources','ma.png');
            dlg.StandaloneButtonSet=getButtonPanelSchema;
            dlg.Sticky=true;
        end

        function set.TaskNode(this,value)
            this.TaskNode=value;
        end
    end

    methods(Hidden=true)
        function handleCheckEvent(this,tag,handle)
            if strcmp(tag,'ImportSource')
                widgetValue=handle.getWidgetValue(tag);
                switch widgetValue
                case 0
                    this.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:Library');
                case 1
                    this.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:slBlkSupportTable');
                case 2
                    this.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:cstBlkSupportTable');
                case 3
                    this.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:cvstBlkSupportTable');
                case 4
                    this.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:dstBlkSupportTable');
                end
                this.refreshDialog;
            elseif strcmp(tag,'ImportType')
                widgetValue=handle.getWidgetValue(tag);
                if widgetValue==0
                    this.ImportType='Add into table';
                elseif widgetValue==1
                    this.ImportType='Remove from table';
                else
                    this.ImportType='Replace table';
                end
                this.refreshDialog;
            elseif strcmp(tag,'Directory')
                widgetValue=handle.getWidgetValue(tag);
                this.LibraryPath=widgetValue;
            end
        end

        function chooseDirectoryButton(this)
            [filename,pathname]=uigetfile('*.slx',DAStudio.message('ModelAdvisor:engine:ImportBlkListFromLib'));
            if~isequal(filename,0)&&~isequal(pathname,0)
                libraryPath=fullfile(pathname,filename);
                this.LibraryPath=libraryPath;
                this.refreshDialog;
            end
        end

        function ImportIntoTable(this)
            if strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:Library'))&&~exist(this.LibraryPath,'file')
                warndlg(DAStudio.message('ModelAdvisor:engine:LibNotExists',this.LibraryPath));
                this.refreshDialog;
                return
            end

            this.syncInternalValues('write');
            this.closeDialog();

            if(isa(this.TaskNode,'ModelAdvisor.ConfigUI')||isa(this.TaskNode,'ModelAdvisor.Task'))...
                &&isa(this.InputParameter,'ModelAdvisor.InputParameter')
                [~,libname,ext]=fileparts(this.LibraryPath);
                UserInputValidated=false;
                if strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:Library'))&&strcmp(ext,'.slx')
                    alreadyLoaded=bdIsLoaded(libname);
                    load_system(this.LibraryPath);


                    libblks=find_system(libname,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                    libblkTypes={};
                    for i=2:length(libblks)
                        blkType=get_param(libblks{i},'BlockType');
                        maskType=get_param(libblks{i},'MaskType');
                        libblkTypes{end+1,1}=blkType;%#ok<*AGROW>
                        libblkTypes{end,2}=maskType;
                    end
                    newblkTypes=libblkTypes;
                    UserInputValidated=true;
                    if~alreadyLoaded
                        close_system(this.LibraryPath);
                    end
                elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:slBlkSupportTable'))
                    newblkTypes=Advisor.Utils.Simulink.block.getSimulinkBlockSupportTable;
                    UserInputValidated=true;
                elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:cstBlkSupportTable'))
                    newblkTypes=Advisor.Utils.Simulink.block.getCSTBlockSupportTable;
                    UserInputValidated=true;
                elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:cvstBlkSupportTable'))
                    newblkTypes=Advisor.Utils.Simulink.block.getCVSTBlockSupportTable;
                    UserInputValidated=true;
                elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:dstBlkSupportTable'))
                    newblkTypes=Advisor.Utils.Simulink.block.getDSTBlockSupportTable;
                    UserInputValidated=true;
                end
                if UserInputValidated
                    originalSet=Advisor.Utils.Simulink.block.convertBlkTypeList_into_cell(this.InputParameter.Value);
                    newSet=Advisor.Utils.Simulink.block.convertBlkTypeList_into_cell(newblkTypes);
                    switch this.ImportType
                    case 'Add into table'
                        this.InputParameter.Value=...
                        Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(union(originalSet,newSet));
                    case 'Remove from table'
                        this.InputParameter.Value=...
                        Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(setdiff(originalSet,newSet));
                    case 'Replace table'
                        this.InputParameter.Value=...
                        Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(unique(newSet));
                    end
                    if isa(this.TaskNode,'ModelAdvisor.ConfigUI')
                        this.TaskNodeDialog.enableApplyButton(true);
                        this.TaskNode.MAObj.ConfigUIDirty=true;
                        loc_refresh_dlg(this.TaskNode);
                    elseif isa(this.TaskNode,'ModelAdvisor.Task')
                        this.TaskNodeDialog.enableApplyButton(true);
                        loc_refresh_dlg(this.TaskNode);
                    end
                end
            end
        end

        function refreshDialog(this)

            dlgs=DAStudio.ToolRoot.getOpenDialogs(this);
            if isa(dlgs,'DAStudio.Dialog')
                this.doNotReadInternalValues=true;
                dlgs.restoreFromSchema;
            end
        end

        function closeDialog(this)
            dlg=DAStudio.ToolRoot.getOpenDialogs(this);
            dlg.delete;
        end





        function cancelReport(this)
            this.closeDialog();
        end

        function syncInternalValues(this,operation)
            fields=getReplicateFields;
            if strcmp(operation,'write')
                for i=1:length(fields)
                    this.InternalValues.(fields{i})=this.(fields{i});
                end
            else
                for i=1:length(fields)
                    this.(fields{i})=this.InternalValues.(fields{i});
                end
            end
        end
    end
end

function fields=getReplicateFields
    fields={'BlkTypeSource','ImportType','LibraryPath'};
end

function tabContainer=getTabContainer(this)

    row=1;
    SourceSelectionGroup=getSourceSelectionGroup(this);
    SourceSelectionGroup.ColSpan=[1,2];
    SourceSelectionGroup.RowSpan=[row,row];

    tabContainer.Type='panel';
    tabContainer.Tag='Tab_Container';
    tabContainer.LayoutGrid=[1,1];
    tabContainer.RowStretch=1;
    tabContainer.Items={SourceSelectionGroup};
end

function SourceSelectionGroup=getSourceSelectionGroup(this)
    row=0;

    row=row+1;
    ImportSourcePrompt.Type='text';
    ImportSourcePrompt.Name=DAStudio.message('ModelAdvisor:engine:ImportSource');
    ImportSourcePrompt.ColSpan=[1,1];
    ImportSourcePrompt.RowSpan=[row,row];
    ImportSource.Type='combobox';
    if this.BlkListInterpretionMode==0
        ImportSource.Entries=ModelAdvisor.ImportBlkTypeDialog.cBlkTypeSourceEnum;
    else
        ImportSource.Entries=ModelAdvisor.ImportBlkTypeDialog.cBlkTypeSourceEnum_NoBlkSptTbl;
    end
    if strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:Library'))
        ImportSource.Value=0;
    elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:slBlkSupportTable'))
        ImportSource.Value=1;
    elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:cstBlkSupportTable'))
        ImportSource.Value=2;
    elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:cvstBlkSupportTable'))
        ImportSource.Value=3;
    elseif strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:dstBlkSupportTable'))
        ImportSource.Value=4;
    end
    ImportSource.ColSpan=[2,3];
    ImportSource.RowSpan=[row,row];
    ImportSource.Tag='ImportSource';
    ImportSource.ObjectMethod='handleCheckEvent';
    ImportSource.MethodArgs={'%tag','%dialog'};
    ImportSource.ArgDataTypes={'string','handle'};

    row=row+1;
    LibraryPrompt.Type='text';
    LibraryPrompt.Name=DAStudio.message('ModelAdvisor:engine:LibraryFile');
    LibraryPrompt.ColSpan=[1,1];
    LibraryPrompt.RowSpan=[row,row];
    Directory.Type='edit';
    Directory.Value=this.LibraryPath;
    Directory.Tag='Directory';
    Directory.ColSpan=[2,2];
    Directory.RowSpan=[row,row];
    Directory.ObjectMethod='handleCheckEvent';
    Directory.MethodArgs={'%tag','%dialog'};
    Directory.ArgDataTypes={'string','handle'};
    if~strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:Library'))
        Directory.Enabled=false;
    end
    chooseDirectoryButton.Name='...';
    chooseDirectoryButton.Type='pushbutton';
    chooseDirectoryButton.ObjectMethod='chooseDirectoryButton';
    chooseDirectoryButton.MethodArgs={};
    chooseDirectoryButton.ArgDataTypes={};
    chooseDirectoryButton.Tag='chooseDirectoryButton';
    chooseDirectoryButton.RowSpan=[row,row];
    chooseDirectoryButton.ColSpan=[3,3];
    chooseDirectoryButton.Alignment=5;
    if~strcmp(this.BlkTypeSource,DAStudio.message('ModelAdvisor:engine:Library'))
        chooseDirectoryButton.Enabled=false;
    end
























    SourceSelectionGroup.Type='panel';

    SourceSelectionGroup.Items={ImportSourcePrompt,ImportSource,LibraryPrompt,Directory,chooseDirectoryButton};
    SourceSelectionGroup.LayoutGrid=[2,3];
end

function schema=getButtonPanelSchema
    tag_prefix='buttonpnl_';

    col=1;


    col=col+1;
    btnRun.Type='pushbutton';
    btnRun.Name=DAStudio.message('ModelAdvisor:engine:OK');
    btnRun.ColSpan=[col,col];
    btnRun.ObjectMethod='ImportIntoTable';
    btnRun.Tag=[tag_prefix,'RunButton'];
    btnRun.ToolTip='Generate Report';


    col=col+1;
    btnCancel.Type='pushbutton';
    btnCancel.Name=DAStudio.message('ModelAdvisor:engine:Cancel');
    btnCancel.ColSpan=[col,col];
    btnCancel.ObjectMethod='cancelReport';
    btnCancel.Tag=[tag_prefix,'CancelButton'];










    pnlSpacer.Type='panel';

    pnlButton.Type='panel';


    pnlButton.LayoutGrid=[1,col];
    pnlButton.ColStretch=[1,zeros(1,col-1)];
    pnlButton.Items={pnlSpacer,btnRun,btnCancel};
    pnlButton.Tag=[tag_prefix,'ButtonPanel'];

    schema=pnlButton;

end

function loc_refresh_dlg(this)
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyChangedEvent',this);
end


