function dlgstruct=referenceblock_ddg(~,h)





    if ispc
        backGroundColor='#F0F0F0';
    else
        backGroundColor='#EFEEED';
    end


    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};


    reasonForUnresolvedLink='';
    try
        reasonForUnresolvedLink=slInternal('getReasonForUnresolvedLink',h.Handle);
    catch


    end

    sourceInfoLabel=DAStudio.message('Simulink:dialog:SourceInformation');
    sourceLibraryInfo='';
    try
        sourceLibraryInfo=get_param(h.Handle,'SourceLibraryInfo');
    catch


    end




    html=[...
    '<html><body padding="0" spacing="0" border-style:dotted bgcolor="',...
    backGroundColor,'">',...
    ];


    if~isempty(reasonForUnresolvedLink)
        html=[...
        html,...
        '<p>',reasonForUnresolvedLink,'</p>',...
        ];
    end


    if~isempty(sourceLibraryInfo)
        pattern='https?://[^\\s].[^\\s]*+';
        result=regexp(sourceLibraryInfo,pattern,'once');
        if~isempty(result)
            sourceLibraryInfo=['<a href="ddgrefresh:eval(''web ',sourceLibraryInfo,''')">',sourceLibraryInfo,'</a>'];
        end
        html=[...
        html,...
        '<p><u>',sourceInfoLabel,'</u></p>',...
        '<p>',sourceLibraryInfo,'</p>',...
        ];
    end


    html=[...
    html,...
'</body></html>'...
    ];

    textBrowserWidget.Name='More Information From Library Author';
    textBrowserWidget.Type='textbrowser';
    textBrowserWidget.Text=html;
    textBrowserWidget.Tag='UnresolvedLinkTextBrowser';

    informationGrp.Name='Details';
    informationGrp.Type='group';
    informationGrp.Items={textBrowserWidget};
    informationGrp.Visible=0;


    sourceBlockLabel.Name=DAStudio.message('Simulink:blkprm_prompts:ReferenceSourceBlock');
    sourceBlockLabel.Type='text';

    sourceBlockEditWidget.Name='';
    sourceBlockEditWidget.Type='edit';
    sourceBlockEditWidget.ObjectProperty='SourceBlock';
    sourceBlockEditWidget.Tag=sourceBlockEditWidget.ObjectProperty;

    sourceTypeLabel.Name=DAStudio.message('Simulink:blkprm_prompts:ReferenceSourceType');
    sourceTypeLabel.Type='text';

    sourceTypeEditWidget.Name='';
    sourceTypeEditWidget.Type='edit';
    sourceTypeEditWidget.ObjectProperty='SourceType';
    sourceTypeEditWidget.Tag=sourceTypeEditWidget.ObjectProperty;
    sourceTypeEditWidget.Enabled=0;

    spacer.Name='';
    spacer.Type='text';

    blockParameterGrp.Name='Parameters';
    blockParameterGrp.Type='group';
    blockParameterGrp.Items={sourceBlockLabel,sourceBlockEditWidget,sourceTypeLabel,sourceTypeEditWidget,spacer};
    blockParameterGrp.Source=h;



    dlgstruct.DialogTitle='';
    if(~isempty(sourceLibraryInfo))||(~isempty(reasonForUnresolvedLink))
        informationGrp.Visible=1;
    end

    dlgstruct.Items={descGrp,informationGrp,blockParameterGrp};


    dlgstruct.PreApplyCallback='referenceblock_ddg_cb';
    dlgstruct.PreApplyArgs={'doPreApply','%dialog',h};


    dlgstruct.CloseMethod='closeCallback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};

