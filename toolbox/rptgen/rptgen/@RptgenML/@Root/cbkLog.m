function fileName=cbkLog(r,cLog)






    if nargin<2
        cLog=r.getCurrentRpt;
    elseif ischar(cLog)
        tLog=r.findRptByName(cLog);
        if isempty(tLog)
            cLog=rptgen.loadRpt(cLog);
        else
            cLog=tLog;
            clear tLog;
        end
    end

    if isempty(cLog)||~isa(cLog,'rptgen.coutline')

        warning(message('rptgen:RptgenML_Root:noReportToLog'));
        return;
    end

    [rDir,rFile,rExt]=fileparts(cLog.RptFileName);

    if isempty(rDir)
        rDir=tempdir;
    end
    if isempty(rFile)
        rFile=getString(message('rptgen:RptgenML_Root:unnamedLabel'));
    end

    c=loadReport;
    set(c,...
    'DirectoryName',rDir,...
    'FilenameName',[rFile,'_log']);
    tPage=find(c,'-isa','rptgen.cfr_titlepage');
    if~isempty(tPage)
        set(tPage(1),'Title',getString(message('rptgen:RptgenML_Root:logName',rFile)));
    end

    oldStatus=r.StatusWindow;
    assignin('base','RPTGEN_CURRENT_RPT',cLog);
    assignin('base','RPTGEN_CURRENT_STATUS',oldStatus);

    rptgen.internal.gui.GenerationDisplayClient.reset;
    r.StatusWindow=rptgen.internal.gui.GenerationDisplayClient.getMessageClient;

    if isa(r.Editor,'DAStudio.Explorer')
        r.addReport(c);
        r.cbkReport(c);



        r.closeReport(c);
        r.Editor.view(cLog);
    else
        fileName=rptgen.report(c);
    end

    r.StatusWindow=oldStatus;



    function c=loadReport

        c=RptgenML.CReport(...
        'DirectoryType','other',...
        'FilenameType','other',...
        'SectionType','sect1',...
        'RptFileName',fullfile(matlabroot,'toolbox','rptgen','log.rpt'),...
        'Description','Documents the report in workspace variable RPTGEN_CURRENT_RPT');

        ev1=rptgen.cml_eval(...
        'isDiary',false,...
        'isInsertString',false,...
        'EvalString',['if ~exist(''RPTGEN_CURRENT_RPT'',''var'')',char(10),...
        '   RPTGEN_CURRENT_RPT = getCurrentRpt(RptgenML.Root);',char(10),...
        'end']);
        ev1.connect(c,'up');

        tPage=rptgen.cfr_titlepage(...
        'Title','Log',...
        'Subtitle','Report Generator Log',...
        'Include_Copyright',false,...
        'AuthorMode','auto');
        connect(tPage,c,'up');

        objLoop1=rptgen_ud.cud_obj_loop(...
        'ObjectSource','workspace',...
        'NameList',{'RPTGEN_CURRENT_RPT'},...
        'ExcludeRoot',false);

        objLoop1.connect(c,'up');

        hier=rptgen_ud.cud_obj_hier(...
        'ListStyle','itemizedlist',...
        'NumInherit','inherit',...
        'EmphasizeCurrent',false,...
        'ParentDepth',0,...
        'ShowSiblings',false,...
        'ChildDepth',24);
        connect(hier,objLoop1,'up');

        objLoop2=rptgen_ud.cud_obj_loop('ObjectSource','loopchild',...
        'ObjectSection',true,...
        'ObjectAnchor',true,...
        'ExcludeRoot',false);
        objLoop2.connect(objLoop1,'up');

        summTable=rptgen_ud.cud_summ_table('LoopType','property',...
        'TitleType','manual',...
        'TableTitle','');
        summTable.connect(objLoop2,'up');
        summTable.summ_set('',...
        'Properties',{'Name','Value'},...
        'ColumnWidths',[150,500]);

        msgIf=rptgen_lo.clo_if('ConditionalString','isa(RPTGEN_CURRENT_STATUS,''rptgen.internal.gui.GenerationMessageList'')');

        msgIf.connect(c,'up');

        msgSect=rptgen.cfr_section('SectionTitle',getString(message('rptgen:RptgenML_Root:statusMessageLabel')));
        msgSect.connect(msgIf,'up');

        msgComp=rptgen.cml_variable(...
        'Variable','toDocBook(RPTGEN_CURRENT_STATUS,java(get(rptgen.appdata_rg,''CurrentDocument'')))',...
        'IgnoreIfEmpty',true,...
        'Source','w',...
        'TitleMode','none');
        msgComp.connect(msgSect,'up');

        vSect=rptgen.cfr_section('SectionTitle',getString(message('rptgen:RptgenML_Root:versionInfoLabel')));
        vSect.connect(c,'up');

        vComp=rptgen.cml_ver(...
        'TableTitle','');
        vComp.connect(vSect,'up');



        ev2=rptgen.cml_eval(...
        'isDiary',false,...
        'isInsertString',false,...
        'EvalString','clear RPTGEN_CURRENT_STATUS RPTGEN_CURRENT_RPT;');
        ev2.connect(c,'up');

