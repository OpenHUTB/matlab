function dlg=getDialogSchema(h,name)




    coreObj=h.coreObj;
    tag=['SLDV_ComponentAdvisor_',name];

    rowidx=1;
    items={};


    pf=get(0,'ScreenPixelsPerInch')/72;


    progress_bar.Type='textbrowser';
    progress_bar.Text=getProgressString(h);
    progress_bar.Tag=[tag,'_','ProgressBar'];
    progress_bar.MaximumSize=pf*[4400,100];
    progress_bar.RowSpan=[rowidx,rowidx];
    progress_bar.ColSpan=[1,2];
    items{end+1}=progress_bar;
    rowidx=rowidx+1;


    summary_panel=getSummaryStats(h);
    summary_panel.RowSpan=[rowidx,rowidx];
    summary_panel.ColSpan=[1,2];
    items{end+1}=summary_panel;

    rowidx=rowidx+1;

    summary_table.Name='';
    summary_table.Type='webbrowser';
    summary_table.WebKit=true;
    summary_table.Tag=[tag,'_','ComponentSummary'];
    summary_table.HTML=h.coreObj.getSummaryStringHTML;
    summary_table.RowSpan=[rowidx,rowidx];
    summary_table.ColSpan=[1,2];
    items{end+1}=summary_table;

    rowidx=rowidx+1;

    switch(coreObj.DerivedAnalysisState)

    case{Sldv.Advisor.MdlCompState.NotExtractable,Sldv.Advisor.MdlCompState.NotCompatible}


    case Sldv.Advisor.MdlCompState.NotAnalyzable


        items=[items,getWidgetsForRecheck(h,rowidx,tag)];
        rowidx=rowidx+1;
        items=[items,getButtonToExtractAndRunSLDV(h,rowidx,tag)];

    case Sldv.Advisor.MdlCompState.Analyzable
        rowidx=rowidx+1;
        items=[items,getButtonToExtractAndRunSLDV(h,rowidx,tag)];

    case Sldv.Advisor.MdlCompState.Simple
        items=[items,getWidgetsForSimpleDialog(h,rowidx,tag)];
        rowidx=rowidx+1;
        items=[items,getButtonToExtractAndRunSLDV(h,rowidx,tag)];

    end

    rowCount=rowidx;
    panel.Type='panel';
    panel.Items=items;
    panel.LayoutGrid=[rowCount,2];
    panel.RowSpan=[1,rowCount];
    panel.ColSpan=[1,2];
    panel.RowStretch=[0,0,1,zeros(1,rowCount-3)];
    panel.ColStretch=[1,0];
    panel.Alignment=0;

    dlg.DialogTitle=DAStudio.message('Sldv:ComponentAdvisor:ComponentName',h.label);
    dlg.LayoutGrid=[rowCount,2];
    dlg.Items={panel};
    dlg.EmbeddedButtonSet=getCSH_HelpButton(coreObj.DerivedAnalysisState,tag);

end

function widget=getWidgetsForRecheck(h,rowidx,tag)

    widget.Name=DAStudio.message('Sldv:ComponentAdvisor:Recheck');
    widget.Type='pushbutton';
    widget.Tag=[tag,'_','ButtonToRecheck'];
    widget.Editable=false;
    widget.Enabled=true;
    widget.RowSpan=[rowidx,rowidx];
    widget.ColSpan=[2,2];

    try
        model_sid=Simulink.ID.getSID(bdroot(h.coreObj.BlockH));
        block_sid=Simulink.ID.getSID(h.coreObj.BlockH);
        widget.MatlabMethod='sldvprivate';
        widget.MatlabArgs={'component_advisor_cb',model_sid,'recheck_component',block_sid};
    catch Mex


        new_me=MException('Sldv:ComponentAdvisor:UnableToFindComponentAdvisor',...
        getString(message('Sldv:ComponentAdvisor:UnableToFindComponentAdvisor')));
        new_me.addCause(Mex);
        Simulink.output.error(new_me);
    end


end

function widget=getWidgetsForSimpleDialog(h,rowidx,tag)%#ok<INUSL>

    widget.Name=DAStudio.message('Sldv:ComponentAdvisor:LabelSimpleComponent');
    widget.Type='text';
    widget.Tag=[tag,'_','LabelSimpleComponent'];
    widget.Editable=false;
    widget.Enabled=true;
    widget.RowSpan=[1,1]*rowidx;
    widget.ColSpan=[1,2];
end


function widget=getButtonToExtractAndRunSLDV(h,rowidx,tag)

    widget.Name=DAStudio.message('Sldv:ComponentAdvisor:RunSldvTestGen');
    widget.Type='pushbutton';
    widget.Tag=[tag,'_','ButtonToRunTestGen'];
    widget.Editable=false;
    widget.Enabled=true;
    widget.RowSpan=[1,1]*rowidx;
    widget.ColSpan=[2,2];
    widget.MatlabMethod='dialogCallback';
    widget.MatlabArgs={h,'run_tg'};
end

function str=getProgressString(h)
    try
        num_components_total=sum(h.coreObj.HierAnalyzer.ComponentStatus);

        num_components_done=num_components_total-...
        h.coreObj.HierAnalyzer.ComponentStatus(Sldv.Advisor.MdlCompState.NotProcessedYet.idx);

    catch Mex %#ok<NASGU>
        num_components_total=0;
        num_components_done=0;
    end
    if num_components_total==0
        prog=0;
    else
        prog=num_components_done/num_components_total;
    end


    pf=get(0,'ScreenPixelsPerInch')/72;

    width=200;
    scale=10;
    cellWidth=135;

    colorsize=width/scale;

    progint=floor((width*prog)./scale);
    if progint==0&&prog>0
        progint=1;
    end

    progcellcolor=struct('color',{});

    for i=1:progint
        progcellcolor(i).color='#8B0000';
    end
    for i=progint+1:colorsize
        progcellcolor(i).color='white';
    end

    prgLabel=getString(message('Sldv:ComponentAdvisor:Progress'));
    objProcLabel=getString(message('Sldv:ComponentAdvisor:ComponentsProcessed'));

    str=...
    [...
    '<BODY bgcolor="#DEDEDE" >',...
    '<tr>  <td align=left>  <font size="3"></font> </td> <td  align=left>  <font size="3"> </font> </td> </tr> ',...
    '<TR> <TD WIDTH=',num2str(cellWidth*pf),' align=left> <font size="3">&nbsp;',prgLabel,'</font> </TD>',...
    '<TD NOWRAP>',...
    '<table width="',num2str(width*pf),'" border="0" CELLSPACING=0 CELLPADDING=0 >',...
    '<tr>',...
    '<td  align=left bgcolor="',progcellcolor(1).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(2).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(3).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(4).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(5).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(6).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(7).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(8).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(9).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(10).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(11).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(12).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(13).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(14).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(15).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(16).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(17).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(18).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(19).color,'" width="',num2str(scale*pf),'"></td>',...
    '<td  align=left bgcolor="',progcellcolor(20).color,'" width="',num2str(scale*pf),'"></td>',...
    '</tr>',...
    '</table>',...
    '</TD>',...
    '</TR>',...
    '<tr>  <td align=left>  <font size="3"></font> </td> <td  align=left>  <font size="3"> </font> </td> </tr> ',...
    '<tr>  <td NOWRAP WIDTH=',num2str(cellWidth*pf),' align=left>  <font size="3"><NOBR>&nbsp;',objProcLabel,'</NOBR></font></td>  <td NOWRAP align=left>  <font size="3">',num2str(num_components_done),'/',num2str(num_components_total),'</font> </td> </tr> ',...
    '</TABLE>',...
    '</BODY>',...
    ];

end

function statsPanel=getSummaryStats(h)
    try
        num_components_red=...
        h.coreObj.HierAnalyzer.ComponentStatus(Sldv.Advisor.MdlCompState.NotCompatible.idx)+...
        h.coreObj.HierAnalyzer.ComponentStatus(Sldv.Advisor.MdlCompState.NotExtractable.idx);

        num_components_yellow=h.coreObj.HierAnalyzer.ComponentStatus(Sldv.Advisor.MdlCompState.NotAnalyzable.idx);

        num_components_green=...
        h.coreObj.HierAnalyzer.ComponentStatus(Sldv.Advisor.MdlCompState.Analyzable.idx)+...
        h.coreObj.HierAnalyzer.ComponentStatus(Sldv.Advisor.MdlCompState.Simple.idx);
    catch Mex %#ok<NASGU>
        num_components_red=0;
        num_components_yellow=0;
        num_components_green=0;
    end

    row=1;
    col=1;

    nRedIcon.Type='image';
    nRedIcon.Tag='image_redIcon';
    nRedIcon.RowSpan=[row,row];
    nRedIcon.ColSpan=[col,col];
    nRedIcon.FilePath=Sldv.Advisor.MdlCompState.NotCompatible.iconPath;

    col=col+1;

    nRedCounter.Name=num2str(num_components_red);
    nRedCounter.Name=[DAStudio.message('Sldv:ComponentAdvisor:ComponentsRed'),': ',nRedCounter.Name];
    nRedCounter.Type='text';
    nRedCounter.Tag='text_redCounter';
    nRedCounter.WordWrap=true;
    nRedCounter.RowSpan=[row,row];
    nRedCounter.ColSpan=[col,col];

    col=col+1;

    nGreenIcon.Type='image';
    nGreenIcon.Tag='image_greenIcon';
    nGreenIcon.RowSpan=[row,row];
    nGreenIcon.ColSpan=[col,col];
    nGreenIcon.FilePath=Sldv.Advisor.MdlCompState.Analyzable.iconPath;

    col=col+1;

    nGreenCounter.Name=num2str(num_components_green);
    nGreenCounter.Name=[DAStudio.message('Sldv:ComponentAdvisor:ComponentsGreen'),': ',nGreenCounter.Name];
    nGreenCounter.Type='text';
    nGreenCounter.Tag='text_greenCounter';
    nGreenCounter.WordWrap=true;
    nGreenCounter.RowSpan=[row,row];
    nGreenCounter.ColSpan=[col,col];

    col=col+1;

    nYellowIcon.Type='image';
    nYellowIcon.Tag='image_yellowIcon';
    nYellowIcon.RowSpan=[row,row];
    nYellowIcon.ColSpan=[col,col];
    nYellowIcon.FilePath=Sldv.Advisor.MdlCompState.NotAnalyzable.iconPath;

    col=col+1;

    nYellowCounter.Name=num2str(num_components_yellow);
    nYellowCounter.Name=[DAStudio.message('Sldv:ComponentAdvisor:ComponentsYellow'),': ',nYellowCounter.Name];
    nYellowCounter.Type='text';
    nYellowCounter.Tag='text_yellowCounter';
    nYellowCounter.WordWrap=true;
    nYellowCounter.RowSpan=[row,row];
    nYellowCounter.ColSpan=[col,col];


    statsPanel.Type='panel';
    statsPanel.Items={nRedIcon,nRedCounter,nGreenIcon,nGreenCounter,nYellowIcon,nYellowCounter};
    statsPanel.LayoutGrid=[1,2];

end

function help_panel=getCSH_HelpButton(state,tag)
    page='';
    switch state
    case Sldv.Advisor.MdlCompState.NotAnalyzable
        page='help_complex';

    case Sldv.Advisor.MdlCompState.NotCompatible
        page='help_incompatibility';

    case Sldv.Advisor.MdlCompState.Analyzable
        page='help_analyzable';

    case Sldv.Advisor.MdlCompState.Simple
        page='help_simple';

    case Sldv.Advisor.MdlCompState.NotProcessedYet
        page='help_notProcessed';
    end

    widget.Name=DAStudio.message('Sldv:ComponentAdvisor:HelpButton');
    widget.Type='pushbutton';
    widget.Tag=[tag,'_','CSH_Help'];
    widget.Editable=false;
    widget.Enabled=true;
    widget.MatlabMethod='sldvprivate';
    widget.MatlabArgs={'util_testgen_advisor_open_help',page};

    help_panel.Type='panel';
    help_panel.Items={widget};
end
