function dlgstruct=externalsourceddg(hObj)



    ExtSourceDesc.Type='textbrowser';
    filespec=hObj.getFileSpec;
    [path,filename,ext]=fileparts(filespec);

    if strcmpi(ext,'.m')
        str=['<table width="100%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
        '<tr><td>',...
        '<b><font size=+2>',DAStudio.message('Simulink:dialog:DataDictHTMLTextInfoFor'),' %s</b></font>',...
        '<table>',...
        '<tr><td align="left"><b>',DAStudio.message('Simulink:dialog:DataDictHTMLTextSourceFile'),'</b> <a href="matlab:%s">%s</a></td></tr>'];
    else
        str=['<table width="100%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
        '<tr><td>',...
        '<b><font size=+2>',DAStudio.message('Simulink:dialog:DataDictHTMLTextInfoFor'),' %s</b></font>',...
        '<table>',...
        '<tr><td align="left"><b>',DAStudio.message('Simulink:dialog:DataDictHTMLTextSourceFile'),'</b> %s</td></tr>'];
    end

    errorMsg=hObj.getAdapterErrorMsg;
    str=[str,'<p><tr><td align="left"><b>',errorMsg,'</b></td></tr>'];

    str=[str,...
    '</table>',...
    '</td></tr>',...
    '</table>',...
    ];

    if strcmpi(ext,'.m')
        editCmd=['edit ',filespec];
        html=sprintf(str,filename,editCmd,filespec);
    else
        html=sprintf(str,filename,filespec);
    end

    ExtSourceDesc.Text=html;
    ExtSourceDesc.Tag='ExtSourceDesc';

    dlgstruct.Items={ExtSourceDesc};
    dlgstruct.DialogTitle=['External File',': ',filename,ext];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};

end


