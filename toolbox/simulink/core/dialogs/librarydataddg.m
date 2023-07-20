function dlgstruct=librarydataddg(hObj)

    model=hObj.getParent;

    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(model.name);

    LibraryDataDesc.Type='textbrowser';

    str=['<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
    '<tr><td>',...
    '<b><font size=+2>',DAStudio.message('Simulink:dialog:DataDictHTMLTextInfoFor'),' %s</b></font>',...
    '<table>',...
    '<tr><td align="right"><b>','Include Dirs: ','</b></td><td>%s</td></tr>',...
    '<tr><td align="right"><b>','Sources: ','</b></td><td>%s</td></tr>',...
    '<tr><td align="right"><b>','Libraries: ','</b></td><td>%s</td></tr>'];

    str=[str,...
    '</table>',...
    '</td></tr>',...
    '</table>',...
    ];

    html=sprintf(str,hObj.getDisplayLabel,customCodeSettings.userIncludeDirs,customCodeSettings.userSources,customCodeSettings.userLibraries);

    LibraryDataDesc.Text=html;
    LibraryDataDesc.Tag='LibraryDataDesc';

    dlgstruct.Items={LibraryDataDesc};
    dlgstruct.DialogTitle=[model.getFullName(),': ',hObj.getDisplayLabel];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};

end



