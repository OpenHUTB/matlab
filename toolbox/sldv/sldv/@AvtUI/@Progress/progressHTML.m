function progressHTML(h)




























    prog=h.browserparam1(1);
    obj=h.browserparam1(2);
    fals=h.browserparam1(3);
    sat=h.browserparam1(4);
    proc=h.browserparam1(5);
    sat_by_cov_data=h.browserparam1(12);
    sat_by_existing_tests=h.browserparam1(13);

    total_sat=sat+sat_by_cov_data+sat_by_existing_tests;






















    secs=h.browserparam2;


    pf=get(0,'ScreenPixelsPerInch')/72;

    timestr=sec2hms(secs);

    width=200;
    scale=10;
    cellWidth=135;
    colorsize=width/scale;

    progint=floor((width*prog)./scale);
    if isnan(prog)
        progint=0;
    elseif progint==0&&prog>0
        progint=1;
    end

    progcellcolor=struct('color',{});

    for i=1:progint
        progcellcolor(i).color='#8B0000';
    end
    for i=progint+1:colorsize
        progcellcolor(i).color='white';
    end

    prgLabel=getString(message('Sldv:SldvresultsSummary:Progress'));
    objProcLabel=getString(message('Sldv:SldvresultsSummary:ObjectivesProcessed'));


    switch h.mode
    case 'TestGeneration'
        satLabel=getString(message('Sldv:KeyWords:Sat'));
        if slavteng('feature','ChangeUnsatisfiableToDeadLogic')
            falsifiedLabel=getString(message('Sldv:KeyWords:DeadLogic'));
        else
            falsifiedLabel=getString(message('Sldv:KeyWords:Unsatisfiable'));
        end
    case 'PropertyProving'
        satLabel=getString(message('Sldv:KeyWords:ProvenValid'));
        falsifiedLabel=getString(message('Sldv:KeyWords:Falsified'));
    case 'DesignErrorDetection'
        satLabel=getString(message('Sldv:KeyWords:ProvenValid'));
        falsifiedLabel=getString(message('Sldv:KeyWords:Falsified'));
    end

    if strcmp(h.testComp.activeSettings.RequirementsTableAnalysis,"on")&&...
        strcmp(h.Mode,'TestGeneration')




        satLabel=getString(message('Sldv:KeyWords:Falsified'));
        falsifiedLabel=getString(message('Sldv:KeyWords:ProvenValid'));
    end

    elapsedtimeLabel=getString(message('Sldv:SldvresultsSummary:ElapsedTime'));

    h.ProgressStr=...
    [...
    '<BODY bgcolor="#DEDEDE" >',...
    '<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 RULES=GROUPS FRAME=VOID>',...
    '<tr>  <td align=left>  <font size="3"></font> </td> <td  align=left>  <font size="3"> </font> </td> </tr> ',...
    '<TR> <TD WIDTH=',num2str(cellWidth*pf),' align=left> <font size="3">&nbsp;',prgLabel,'</font> </TD>',...
    '<TD>',...
    '<table width="',num2str(width*pf),'" border="0" CELLSPACING=0 CELLPADDING=0 FRAME=BOX BORDERCOLOR="black">',...
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
    '<tr>  <td WIDTH=',num2str(cellWidth*pf),'>  <font size="3">&nbsp;',objProcLabel,'</font></td>  <td align=left>  <font size="3">',num2str(proc),'/',num2str(obj),'</font> </td> </tr> ',...
    '<tr>  <td WIDTH=',num2str(cellWidth*pf),'>  <font size="3">&nbsp;',satLabel,'</font> </td>  <td align=left>  <font size="3"> ',num2str(total_sat),' </font> </td> </tr> ',...
    '<tr>  <td WIDTH=',num2str(cellWidth*pf),'>  <font size="3">&nbsp;',falsifiedLabel,'</font> </td>  <td align=left>  <font size="3"> ',num2str(fals),'</font> </td> </tr> ',...
    '<tr>  <td WIDTH=',num2str(cellWidth*pf),'>  <font size="3">&nbsp;',elapsedtimeLabel,'</font> </td>  <td align=left>  <font size="3"> ',timestr,' </font> </td> </tr> ',...
    '</TABLE>',...
    '</BODY>',...
    ];



    try
        w=DAStudio.imDialog.getIMWidgets(h.dialogH);
        log=find(w,'Tag','browserarea');
        if~h.closed
            log.text=h.ProgressStr;
        end
    catch Mex %#ok<NASGU>
    end




    function timestr=sec2hms(secs)

        hour=floor(secs/3600);
        min=floor(rem(secs,3600)/60);
        sec=rem(secs,60);

        if hour>0
            timestr=sprintf('%d:%02d:%02d',hour,min,sec);
        else
            timestr=sprintf('%d:%02d',min,sec);
        end


