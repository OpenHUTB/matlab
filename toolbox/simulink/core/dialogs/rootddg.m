function dlgstruct=rootddg(h)








    info.Type='textbrowser';
    info.Text=root_info_l(h);
    info.DialogRefresh=1;
    info.RowSpan=[1,2];
    info.ColSpan=[1,2];
    info.Tag='Info';




    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:RootDialogTitle');
    dlgstruct.LayoutGrid=[2,2];
    dlgstruct.Items={info};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_root'};


    function htm=root_info_l(h)




        m=h.find('-isa','Simulink.BlockDiagram','-depth',1);

        libInds=[];
        openInds=[];
        for i=1:length(m),
            if m(i).isLibrary,
                libInds=[libInds,i];
            end;
            h=m(i).handle;
            if isequal(get_param(h,'Open'),'on'),
                openInds=[openInds,i];
            end;
        end;

        libs=m(libInds);
        openThings=m(openInds);
        m(libInds)=[];

        numOpenModels=length(intersect(m,openThings));
        numOpenLibs=length(intersect(libs,openThings));

        str=['<table width="100%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
        '<tr><td>',...
        '<b><font size=+3>',...
        DAStudio.message('Simulink:dialog:RootHTMLTextLineFour'),...
        '</font></b>',...
        '<table><tr><td>',...
        DAStudio.message('Simulink:dialog:RootHTMLTextLineSeven'),...
        ' <a href="matlab:helpview(strcat(docroot,''/mapfiles/simulink.map''), ''parameter_class'');">',...
        DAStudio.message('Simulink:dialog:RootHTMLTextLineNine'),'</a>, ',...
        '<a href="matlab:helpview(strcat(docroot,''/mapfiles/simulink.map''), ''signal_class'');">',...
        DAStudio.message('Simulink:dialog:RootHTMLTextLineEleven'),'</a>, ',...
        DAStudio.message('Simulink:dialog:RootHTMLTextLineTwelve'),' <a href="matlab:helpview(strcat(docroot,''/mapfiles/simulink.map''), ''data_object_classes'');">',...
        DAStudio.message('Simulink:dialog:RootHTMLTextLineThirteen'),'</a> ',...
        DAStudio.message('Simulink:dialog:RootHTMLTextLineFourteen'),...
        '</td></tr></table>',...
        '<table>',...
        '<tr><td align="right"><b>',DAStudio.message('Simulink:dialog:RootHTMLTextLineSeventeen'),'</b></td><td>%d</td>',...
        '<td align="right"><b>',DAStudio.message('Simulink:dialog:RootHTMLTextLineEighteen'),'</b></td><td>%d</td></tr>',...
        '<tr><td align="right"><b>',DAStudio.message('Simulink:dialog:RootHTMLTextLineNineteen'),'</b></td><td>%d</td>',...
        '<td align="right"><b>',DAStudio.message('Simulink:dialog:RootHTMLTextLineTwenty'),'</b></td><td>%d</td></tr>',...
        '</table>',...
        '</td></tr>',...
        '</table>',...
        '<p>',...
        '<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0>',...
        '<tr><td>',...
        '<b><font size=+2>',DAStudio.message('Simulink:dialog:RootHTMLTextLineThirty'),'</font></b>',...
        '   <br>',...
        '<font size=+2><a href="matlab:slprivate(''showprefs'');">',DAStudio.message('Simulink:dialog:RootHTMLTextLineTwentySix'),'</a></font>',...
        '</td></tr>',...
'</table>'...
        ];


        htm=sprintf(str,length(m),length(libs),numOpenModels,numOpenLibs);
