function dlgstruct=linkedsourcesddg(hObj)




    modelName='';

    parent=hObj.getParent;
    while~isempty(parent)
        if isa(parent,'Simulink.BlockDiagram')
            modelName=parent.getFullName();
            break;
        end
        parent=parent.getParent;
    end

    dialogText=['<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0>',...
    ];

    dialogText=[dialogText,...
    '<tr><td>',...
    DAStudio.message('Simulink:Data:LinkedLibrariesText'),...
    '</td></tr>',...
    '<tr/>',...
    ];

    if~isempty(modelName)&&slfeature('SLLibrarySLDD')>1
        bd=get_param(modelName,'slobject');
        br=bd.getBroker;
        cfg=br.getActiveBrokerConfig;
        strSet=cfg.getImplicitExternalSourceList;
        if iscell(strSet)
            implicitSources=strSet;
        else
            implicitSources=strSet.toArray;
        end
        for source=implicitSources
            [~,filename,ext]=fileparts(source{1});
            if isequal(ext,'.slx')&&~isequal(filename,modelName)
                link='<tr><td><a href="matlab:open_system(''%s'')">%s</a></td></tr>';
                line=sprintf(link,[source{1}],[filename,ext]);
                dialogText=[dialogText,line,newline];%#ok<AGROW>
            end
        end
    end
    dialogText=[dialogText,...
    '</table>',...
    ];


    FilesDesc.Type='textbrowser';
    FilesDesc.Text=dialogText;
    FilesDesc.Tag='FilesDesc';

    dlgstruct.Items={FilesDesc};
    modelName=[modelName,': '];
    dlgstruct.DialogTitle=[modelName,hObj.getDisplayLabel];
    dlgstruct.EmbeddedButtonSet={'Help'};
    dlgstruct.StandaloneButtonSet={'Ok','Help'};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'external_sources'};

end
