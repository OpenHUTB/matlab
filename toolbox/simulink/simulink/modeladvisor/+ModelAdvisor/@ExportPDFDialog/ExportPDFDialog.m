classdef(CaseInsensitiveProperties=true)ExportPDFDialog<matlab.mixin.Copyable
    properties(Constant)
        cDialogTag='ModelAdvisorExportPDFReport';
        cReportFormatEnum={'HTML','PDF','Word'};
        cReportFormatNoSlvnvEnum={'HTML'};
    end

    properties(Access=public)
        ReportFormat='';
        TemplateName='';
        ReportName='';
        ReportPath='';
        TaskNode=[];
        ViewReport=false;
        ShowOptions=false;
        InternalValues=[];
        Tokens=[];
        doNotReadInternalValues=false;
        WarnOccurredInHTML2DOM=false;
    end

    methods(Static=true)
        function instance=getInstance()
            persistent dlgInstance;
            if isempty(dlgInstance)||~isvalid(dlgInstance)
                dlgInstance=ModelAdvisor.ExportPDFDialog();
            end
            instance=dlgInstance;
        end
    end

    methods

        function this=ExportPDFDialog()
            this.ReportPath=pwd;
            this.ReportName='report';
            this.ReportFormat='html';
            if isJaLocale
                this.TemplateName=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','templates','default_ja.dotx');
            else
                this.TemplateName=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','templates','default.dotx');
            end
            this.ViewReport=true;
            this.ShowOptions=true;
            this.Tokens.CustomHeader='';
            this.syncInternalValues('write');
            this.doNotReadInternalValues=false;
        end

        function dlg=getDialogSchema(this,~)
            if~this.doNotReadInternalValues
                this.syncInternalValues('read');
            else
                this.doNotReadInternalValues=false;
            end
            tabContainer=getTabContainer(this);
            dlg.DialogTag=ModelAdvisor.ExportPDFDialog.cDialogTag;
            dlg.DialogTitle=DAStudio.message('ModelAdvisor:engine:GenMAReport');
            dlg.Items={tabContainer};
            dlg.DisplayIcon=fullfile('toolbox','simulink','simulink','modeladvisor','resources','ma.png');
            dlg.StandaloneButtonSet=getButtonPanelSchema;
            dlg.Sticky=true;




        end

        function value=getFullname(this)

            value=[fullfile(this.InternalValues.ReportPath,this.ReportName),'.',this.InternalValues.ReportFormat];
        end

        function value=getDisplayFullname(this)
            value=[fullfile(this.ReportPath,this.ReportName),'.',this.ReportFormat];
        end

        function set.TaskNode(this,value)
            this.TaskNode=value;
            if isa(value,'ModelAdvisor.Node')
                [~,rptName,~]=fileparts(modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',...
                this.TaskNode,this.TaskNode.MAObj.AtticData.WorkDir));
                this.ReportName=rptName;%#ok<MCSUP>
            end
        end
    end

    methods(Hidden=true)
        domObjs=emitDOMforTaskNode(obj,this,taskNode);

        function handleCheckEvent(this,tag,handle)
            if strcmp(tag,'ReportFormat')
                widgetValue=handle.getWidgetValue(tag);
                if widgetValue==0
                    this.ReportFormat='html';
                elseif widgetValue==1
                    this.ReportFormat='pdf';
                else
                    this.ReportFormat='docx';
                end
                this.refreshDialog;
            elseif strcmp(tag,'ReportName')
                widgetValue=handle.getWidgetValue(tag);
                this.ReportName=widgetValue;
            elseif strcmp(tag,'Directory')
                widgetValue=handle.getWidgetValue(tag);
                this.ReportPath=widgetValue;
            elseif strcmp(tag,'ReportTemplate')
                widgetValue=handle.getWidgetValue(tag);
                this.TemplateName=widgetValue;
            elseif strcmp(tag,'OpenReportOption')
                widgetValue=handle.getWidgetValue(tag);
                this.ViewReport=widgetValue;
                this.refreshDialog;
            elseif strcmp(tag,'ShowOptions')
                widgetValue=handle.getWidgetValue(tag);
                this.ShowOptions=widgetValue;
                this.refreshDialog;
            else
                widgetValue=handle.getWidgetValue(tag);
                this.Tokens.(tag)=widgetValue;
                this.refreshDialog;
            end
        end














        function chooseTemplateButton(this)
            [filename,filepath]=uigetfile('.dotx',DAStudio.message('ModelAdvisor:engine:SelectTemplateforRpt'),this.TemplateName);
            dstFileName=[filepath,filename];
            if(dstFileName(1)~=0)
                this.TemplateName=dstFileName;
                this.refreshDialog;
            end
        end

        function chooseDirectoryButton(this)
            directoryname=uigetdir(this.ReportPath,DAStudio.message('ModelAdvisor:engine:SelectDirectoryforRpt'));
            if(directoryname(1)~=0)
                this.ReportPath=directoryname;
                this.refreshDialog;
            end
        end

        function refreshDialog(this)

            dlgs=DAStudio.ToolRoot.getOpenDialogs(this);
            if isa(dlgs,'DAStudio.Dialog')
                this.doNotReadInternalValues=true;
                dlgs.restoreFromSchema;
            end
        end

        function GenerateReport(this)
            rptname=this.getFullname;
            rptTemplate=this.InternalValues.TemplateName;
            rptFormat=this.InternalValues.ReportFormat;
            Simulink.DDUX.logData('REPORTING','reportingformat',rptFormat);
            if strcmpi(rptFormat,'html')
                generateHTMLReport(this,rptname);
            else
                makerpt(this,this.TaskNode,rptname,rptTemplate,rptFormat);
            end
        end

        function closeDialog(this)
            dlg=DAStudio.ToolRoot.getOpenDialogs(this);
            dlg.delete;
        end

        function Generate(this)
            if~exist(this.ReportPath,'dir')
                warndlg(DAStudio.message('ModelAdvisor:engine:DirNotExists',this.ReportPath));
                this.refreshDialog;
                return
            end

            if~exist(this.TemplateName,'file')
                warndlg(DAStudio.message('ModelAdvisor:engine:TemplateNotExists',this.TemplateName));
                this.refreshDialog;
                return
            end

            this.syncInternalValues('write');
            rptname=this.getFullname;
            if exist(rptname,'file')
                response=questdlg([DAStudio.message('ModelAdvisor:engine:AlreadyExists',rptname),sprintf('\n'),DAStudio.message('ModelAdvisor:engine:DoYouWantReplaceIt')],...
                DAStudio.message('ModelAdvisor:engine:ConfirmOverwrite'),DAStudio.message('ModelAdvisor:engine:Yes'),DAStudio.message('ModelAdvisor:engine:No'),DAStudio.message('ModelAdvisor:engine:No'));
                if isempty(response)||strcmp(response,DAStudio.message('ModelAdvisor:engine:No'))

                    return
                end
            end
            this.closeDialog();
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('MESleep');
            disp(DAStudio.message('ModelAdvisor:engine:GeneratingRpt',rptname));
            try
                this.GenerateReport();
                fprintf('\n');
                disp(DAStudio.message('ModelAdvisor:engine:RptGenCompleted'));
                if this.ViewReport
                    if strcmp(this.ReportFormat,'html')
                        web(this.getFullname());
                    else
                        winopen(this.getFullname());
                    end
                end
                if this.WarnOccurredInHTML2DOM
                    warndlgHandle=warndlg(DAStudio.message('ModelAdvisor:engine:WarnOccurredInHTML2DOM'));
                    set(warndlgHandle,'Tag','WarnOccurredInHTML2DOM');
                    this.TaskNode.MAObj.DialogCellArray{end+1}=warndlgHandle;
                end
            catch E
                ed.broadcastEvent('MEWake');
                errormsg=E.message;
                if length(errormsg)>512
                    errormsg=[errormsg(1:256),sprintf('\n'),'...',sprintf('\n'),errormsg(end-255:end)];
                end
                errormsg=[DAStudio.message('ModelAdvisor:engine:ErrInRptGen'),sprintf('\n'),errormsg];
                errordlg(errormsg);
                disp(E.message);
                return
            end
            ed.broadcastEvent('MEWake');
        end

        function Help(~)
            helpview([docroot,'/mapfiles/simulink.map'],'ma_report_custom');
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

    fields={'ReportFormat','TemplateName','ReportPath','ViewReport','ShowOptions','Tokens'};
end

function tabContainer=getTabContainer(this)

    row=1;
    FileLocationGroup=getFileLocationGroup(this);
    FileLocationGroup.ColSpan=[1,2];
    FileLocationGroup.RowSpan=[row,row];

    row=row+1;
    OpenReportOption.Type='checkbox';
    OpenReportOption.Tag='OpenReportOption';
    OpenReportOption.Value=this.ViewReport;
    OpenReportOption.ColSpan=[1,2];
    OpenReportOption.RowSpan=[row,row];
    OpenReportOption.Name=DAStudio.message('ModelAdvisor:engine:ViewRptAfterGeneration');
    OpenReportOption.ObjectMethod='handleCheckEvent';
    OpenReportOption.MethodArgs={'%tag','%dialog'};
    OpenReportOption.ArgDataTypes={'string','handle'};















    row=row+1;
    OptionsGroup=getOptionsGroup(this);
    OptionsGroup.ColSpan=[1,2];
    OptionsGroup.RowSpan=[row,row];
    if strcmp(this.ReportFormat,'html')
        OptionsGroup.Enabled=false;
    end

    tabContainer.Type='panel';
    tabContainer.Tag='Tab_Container';
    tabContainer.LayoutGrid=[3,2];
    tabContainer.RowStretch=[0,0,1];
    tabContainer.Items={FileLocationGroup,OpenReportOption,OptionsGroup};



end

function FileLocationGroup=getFileLocationGroup(this)
    row=0;

    row=row+1;
    DirectoryPrompt.Type='text';
    DirectoryPrompt.Name=DAStudio.message('ModelAdvisor:engine:Directory');
    DirectoryPrompt.ColSpan=[1,1];
    DirectoryPrompt.RowSpan=[row,row];
    Directory.Type='edit';
    Directory.Value=this.ReportPath;
    Directory.Tag='Directory';
    Directory.ColSpan=[2,2];
    Directory.RowSpan=[row,row];
    Directory.ObjectMethod='handleCheckEvent';
    Directory.MethodArgs={'%tag','%dialog'};
    Directory.ArgDataTypes={'string','handle'};
    chooseDirectoryButton.Name='...';
    chooseDirectoryButton.Type='pushbutton';
    chooseDirectoryButton.ObjectMethod='chooseDirectoryButton';
    chooseDirectoryButton.MethodArgs={};
    chooseDirectoryButton.ArgDataTypes={};
    chooseDirectoryButton.Tag='chooseDirectoryButton';
    chooseDirectoryButton.RowSpan=[row,row];
    chooseDirectoryButton.ColSpan=[3,3];
    chooseDirectoryButton.Alignment=5;


    row=row+1;
    RptNamePrompt.Type='text';
    RptNamePrompt.Name=DAStudio.message('ModelAdvisor:engine:Filename');
    RptNamePrompt.ColSpan=[1,1];
    RptNamePrompt.RowSpan=[row,row];
    ReportName.Type='edit';
    ReportName.Value=this.ReportName;
    ReportName.Tag='ReportName';
    ReportName.ColSpan=[2,2];
    ReportName.RowSpan=[row,row];
    ReportName.ObjectMethod='handleCheckEvent';
    ReportName.MethodArgs={'%tag','%dialog'};
    ReportName.ArgDataTypes={'string','handle'};

    row=row+1;
    FileFormatPrompt.Type='text';
    FileFormatPrompt.Name=DAStudio.message('ModelAdvisor:engine:FileFormat');
    FileFormatPrompt.ColSpan=[1,1];
    FileFormatPrompt.RowSpan=[row,row];
    FileFormat.Type='combobox';
    if license('test','SL_Verification_Validation')&&strcmp(this.TaskNode.MAObj.CustomTARootID,'_modeladvisor_')&&ispc
        FileFormat.Entries=ModelAdvisor.ExportPDFDialog.cReportFormatEnum;
    else
        FileFormat.Entries=ModelAdvisor.ExportPDFDialog.cReportFormatNoSlvnvEnum;
    end
    if strcmp(this.ReportFormat,'html')
        FileFormat.Value=0;
    elseif strcmp(this.ReportFormat,'pdf')
        FileFormat.Value=1;
    else
        FileFormat.Value=2;
    end
    FileFormat.ColSpan=[2,3];
    FileFormat.RowSpan=[row,row];
    FileFormat.Tag='ReportFormat';

    FileFormat.ObjectMethod='handleCheckEvent';
    FileFormat.MethodArgs={'%tag','%dialog'};
    FileFormat.ArgDataTypes={'string','handle'};

    row=row+1;
    RptFullName.Type='text';
    RptFullName.Tag='Fullname';
    RptFullName.Name=this.getDisplayFullname;
    RptFullName.ColSpan=[1,3];
    RptFullName.RowSpan=[row,row];



    FileLocationGroup.Type='panel';
    FileLocationGroup.Items={RptFullName,DirectoryPrompt,Directory,RptNamePrompt,ReportName,chooseDirectoryButton,FileFormatPrompt,FileFormat};
    FileLocationGroup.LayoutGrid=[2,3];
end

function OptionsGroup=getOptionsGroup(this)
    row=0;
    OptionsGroup.Items={};

    row=row+1;





    TemplateName.Type='edit';
    TemplateName.Value=this.TemplateName;
    TemplateName.Editable=false;
    TemplateName.ColSpan=[1,6];
    TemplateName.RowSpan=[row,row];
    TemplateName.Tag='ReportTemplate';
    TemplateName.ObjectMethod='handleCheckEvent';
    TemplateName.MethodArgs={'%tag','%dialog'};
    TemplateName.ArgDataTypes={'string','handle'};
    OptionsGroup.Items{end+1}=TemplateName;
    chooseTemplateButton.Name='...';
    chooseTemplateButton.Type='pushbutton';
    chooseTemplateButton.ObjectMethod='chooseTemplateButton';
    chooseTemplateButton.MethodArgs={};
    chooseTemplateButton.ArgDataTypes={};
    chooseTemplateButton.Tag='chooseTemplateButton';
    chooseTemplateButton.RowSpan=[row,row];
    chooseTemplateButton.ColSpan=[7,7];
    chooseTemplateButton.Alignment=5;

    OptionsGroup.Items{end+1}=chooseTemplateButton;













    OptionsGroup.Name=DAStudio.message('ModelAdvisor:engine:ReportTemplate');
    OptionsGroup.Tag='OptionsGroup';
    OptionsGroup.Type='group';
    OptionsGroup.LayoutGrid=[row,7];
    OptionsGroup.ColStretch=[ones(1,6),0];
    OptionsGroup.Visible=this.ShowOptions;
    if~license('test','MATLAB_Report_Gen')
        OptionsGroup.Enabled=false;
    end
end

function makerpt(exportObj,this,rptname,rpttemplate,rptFormat)
    if~license('checkout','SL_Verification_Validation')
        DAStudio.error('ModelAdvisor:engine:CustomRptLicenseFailed');
    end


    if connector.internal.Worker.isMATLABOnline
        DAStudio.error('ModelAdvisor:engine:ReportNotSupportedOnline');
    end

    import mlreportgen.dom.*
    origFormat=rptFormat;
    origName=rptname;
    if strcmpi(rptFormat,'pdf')

        rptname=[tempname,'.docx'];
        rptFormat='docx';
    end


    try
        rpt=ModelAdvisor.ReportDocument(rptname,rptFormat,rpttemplate);
    catch err
        throw(err);
    end

    exportObj.WarnOccurredInHTML2DOM=false;
    dispatcher=MessageDispatcher.getTheDispatcher;
    listener=addlistener(dispatcher,'Message',@msghandler);

    sect=rpt.CurrentDOCXSection;
    for i=1:numel(sect.PageHeaders)
        PageHeader=sect.PageHeaders(i);
        while~strcmp(PageHeader.CurrentHoleId,'#end#')
            switch PageHeader.CurrentHoleId
            otherwise
                if isfield(exportObj.InternalValues.Tokens,PageHeader.CurrentHoleId)
                    append(rpt,exportObj.InternalValues.Tokens.(PageHeader.CurrentHoleId));
                end
            end
            moveToNextHole(PageHeader);
        end
    end

    for i=1:numel(sect.PageFooters)
        PageFooter=sect.PageFooters(i);
        while~strcmp(PageFooter.CurrentHoleId,'#end#')
            switch PageFooter.CurrentHoleId
            otherwise
                if isfield(exportObj.InternalValues.Tokens,PageFooter.CurrentHoleId)
                    append(rpt,exportObj.InternalValues.Tokens.(PageFooter.CurrentHoleId));
                end
            end
            moveToNextHole(PageFooter);
        end
    end

    counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',this);
    while~strcmp(rpt.CurrentHoleId,'#end#')
        switch rpt.CurrentHoleId
        case 'ModelName'
            [~,mdlname,mdlext]=fileparts(get_param(bdroot(this.MAObj.SystemName),'fileName'));
            Value=Text([mdlname,mdlext]);
            Value.Color='#800000';
            append(rpt,Value);
        case 'SimulinkVersion'
            Value=ver('Simulink');
            Value=Text(Value.Version);
            Value.Color='#800000';
            append(rpt,Value);
        case 'ModelVersion'
            Value=Text(get_param(bdroot(this.MAObj.SystemName),'ModelVersion'));
            Value.Color='#800000';
            append(rpt,Value);
        case 'SystemName'
            Value=Text(this.MAObj.SystemName);
            Value.Color='#800000';
            append(rpt,Value);
        case 'TreatAsMdlref'
            if this.MAObj.treatAsMdlref
                Value=Text('on');
            else
                Value=Text('off');
            end
            Value.Color='#800000';
            append(rpt,Value);
        case 'CurrentRun'
            if counterStructure.generateTime~=0
                Value=Text(loc_getDateString(counterStructure.generateTime));
            else
                Value=Text(DAStudio.message('Simulink:tools:MANotApplicable'));
            end
            Value.Color='#800000';
            append(rpt,Value);
        case 'noSyncCheckCount'
            [~,noSyncCounter]=modeladvisorprivate('modeladvisorutil2','emitHTMLforTaskNode',this,this.MAObj.CheckCellArray);
            if noSyncCounter~=0;
                if noSyncCounter==1
                    noSyncCheckCountString=[' ',DAStudio.message('Simulink:tools:MAOneCheckNotSyncRpt',loc_getDateString(counterStructure.generateTime))];
                else
                    noSyncCheckCountString=[' ',DAStudio.message('Simulink:tools:MAMoreCheckNotSyncRpt',num2str(noSyncCounter),loc_getDateString(counterStructure.generateTime))];
                end
                groupObj=Group();
                Value=Text(noSyncCheckCountString);


                groupObj.append(Value);
                append(rpt,groupObj);
            end
        case 'PassCount'
            append(rpt,num2str(counterStructure.passCt));
        case 'FailCount'
            append(rpt,num2str(counterStructure.failCt));
        case 'WarningCount'
            append(rpt,num2str(counterStructure.warnCt));
        case 'JustifiedCount'
            append(rpt,num2str(counterStructure.JustifiedCt));
        case 'IncompleteCount'
            append(rpt,num2str(counterStructure.IncompleteCt));
        case 'NrunCount'
            append(rpt,num2str(counterStructure.nrunCt));
        case 'TotalCount'
            append(rpt,num2str(counterStructure.allCt));
        case 'CheckResults'
            domObjs=exportObj.emitDOMforTaskNode(this,rpt);
            for i=1:length(domObjs)
                append(rpt,domObjs{i});
            end
        otherwise
            if isfield(exportObj.InternalValues.Tokens,rpt.CurrentHoleId)
                append(rpt,exportObj.InternalValues.Tokens.(rpt.CurrentHoleId));
            end
        end
        moveToNextHole(rpt);
    end
    close(rpt);
    delete(listener);
    if strcmpi(origFormat,'pdf')
        rptgen.docview(rptname,'convertdocxtopdf');
        copyfile([rptname(1:end-4),'pdf'],origName);
        delete(rptname);
    end
end

function msghandler(~,evtdata)
    msg=evtdata.Message;
    if isa(msg,'mlreportgen.dom.WarningMessage')
        disp(msg.formatAsText);
        this=ModelAdvisor.ExportPDFDialog.getInstance;
        this.WarnOccurredInHTML2DOM=true;
    end
end





function dateString=loc_getDateString(timeInfo)
    locale=feature('locale');
    lang=locale.messages;
    if strncmpi(lang,'ja',2)||strncmp(lang,'zh_CN',5)||strncmpi(lang,'ko_KR',5)
        dateString=datestr(timeInfo,'yyyy/mm/dd HH:MM:SS');
    else
        dateString=datestr(timeInfo);
    end
end

function generateHTMLReport(this,dstFileName)
    srcFilename=['report_',num2str(this.TaskNode.index),'.html'];
    MdlAdvHandle=this.TaskNode.MAObj;
    report=[MdlAdvHandle.getWorkDir('CheckOnly'),filesep,srcFilename];
    if~(exist(report,'file'))
        this.TaskNode.viewReport('saveas');
    end


    if(dstFileName(1)~=0)
        [success,message]=MdlAdvHandle.exportReport(dstFileName,srcFilename);
        if~success
            errordlg(message);
        end
    end
end

function schema=getButtonPanelSchema
    tag_prefix='buttonpnl_';

    col=1;


    col=col+1;
    btnRun.Type='pushbutton';
    btnRun.Name=DAStudio.message('ModelAdvisor:engine:OK');
    btnRun.ColSpan=[col,col];
    btnRun.ObjectMethod='Generate';
    btnRun.Tag=[tag_prefix,'RunButton'];
    btnRun.ToolTip='Generate Report';










    col=col+1;
    btnCancel.Type='pushbutton';
    btnCancel.Name=DAStudio.message('ModelAdvisor:engine:Cancel');
    btnCancel.ColSpan=[col,col];
    btnCancel.ObjectMethod='cancelReport';
    btnCancel.Tag=[tag_prefix,'CancelButton'];


    col=col+1;
    btnHelp.Type='pushbutton';
    btnHelp.Name=DAStudio.message('ModelAdvisor:engine:Help');
    btnHelp.ColSpan=[col,col];
    btnHelp.ObjectMethod='Help';
    btnHelp.Tag=[tag_prefix,'HelpButton'];


    pnlSpacer.Type='panel';

    pnlButton.Type='panel';


    pnlButton.LayoutGrid=[1,col];
    pnlButton.ColStretch=[1,zeros(1,col-1)];
    pnlButton.Items={pnlSpacer,btnRun,btnCancel,btnHelp};
    pnlButton.Tag=[tag_prefix,'ButtonPanel'];

    schema=pnlButton;

end

function bool=isJaLocale
    locale=feature('locale');
    lang=locale.messages;
    if strncmpi(lang,'ja',2)
        bool=true;
    else
        bool=false;
    end
end