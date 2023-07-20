function dlg=getDialogSchema(hSrc,~)




    isExportFcnDiagram=ishandle(hSrc.fcnclass.ModelHandle)&&...
    isequal(get_param(hSrc.fcnclass.ModelHandle,'SolverType'),'Fixed-step')&&...
    slprivate('getIsExportFcnModel',hSrc.fcnclass.ModelHandle);


    grpDescription=hSrc.fcnclass.getDescriptionGrpSchema;
    grpDescription.RowSpan=[1,1];
    grpDescription.ColSpan=[1,10];
    if isempty(grpDescription.Items)
        grpDescription.Visible=false;
    else
        grpDescription.Visible=true;
    end


    grpGetPreConf=hSrc.fcnclass.getPreconfGrpSchema;
    grpGetPreConf.RowSpan=[2,4];
    grpGetPreConf.ColSpan=[1,10];
    if isempty(grpGetPreConf.Items)
        grpGetPreConf.Visible=false;
    else
        grpGetPreConf.Visible=true;
    end






    dialogSchema=hSrc.fcnclass.getDialogSchema('');
    grpConfig.Type='group';
    grpConfig.RowSpan=[5,11];
    grpConfig.ColSpan=[1,10];
    grpConfig.LayoutGrid=dialogSchema.LayoutGrid;
    grpConfig.Items=dialogSchema.Items;
    grpConfig.Name=dialogSchema.DialogTitle;
    if isempty(grpConfig.Items)
        grpConfig.Visible=false;
    else
        grpConfig.Visible=true;
    end


    grpPreview=hSrc.fcnclass.getPreviewGrpSchema(hSrc);
    if grpConfig.Visible
        grpPreview.RowSpan=[12,12];
    else
        grpPreview.RowSpan=[5,5];
    end
    grpPreview.ColSpan=[1,10];
    if isempty(grpPreview.Items)||isExportFcnDiagram
        grpPreview.Visible=false;
    else
        grpPreview.Visible=true;
    end



    grpValid=hSrc.fcnclass.getValidateGrpSchema(hSrc);

    if grpConfig.Visible
        grpValid.RowSpan=[13,14];
    else
        grpValid.RowSpan=[6,7];
    end
    grpValid.ColSpan=[1,10];
    grpValid.RowStretch=[0,1];


    dlg.HelpMethod='helpview';
    dlg.HelpArgs={'simulink'};
    if grpConfig.Visible
        dlg.LayoutGrid=[14,10];
        dlg.RowStretch=[0,0,0,0,1,1,1,1,1,1,1,0,0,0];
    else
        dlg.LayoutGrid=[7,10];
    end
    dlg.PreApplyCallback='preApplyCB';
    dlg.PreApplyArgs={hSrc,'%dialog'};
    dlg.CloseCallback='closeCB';
    dlg.CloseArgs={hSrc,'%dialog','%closeaction'};
    dlg.DefaultOk=false;

    dlg.Items={grpDescription,grpGetPreConf,grpConfig,grpPreview,grpValid};

    if~hSrc.fcnclass.RightClickBuild
        dlg.DialogTitle=DAStudio.message('RTW:fcnClass:configModelInterface',...
        get_param(hSrc.fcnclass.ModelHandle,'Name'));
    else
        dlg.DialogTitle=DAStudio.message('RTW:fcnClass:configModelInterfaceForSubsys',...
        get_param(hSrc.fcnclass.SubsysBlockHdl,'Name'));
    end
    dlg.HelpArgs={[docroot,'/toolbox/ecoder/helptargets.map'],'cp_ecoder_step_prototype'};





