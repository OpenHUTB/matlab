function group=getTargetSoftwareDialogGroup(h,schemaName)














    utilityFuncGeneration_Name='Utility function generation:';
    utilityFuncGeneration_ToolTip=sprintf(...
    ['Specify where utility functions are generated.']);

    group.Name='Software environment';
    utility_entries={'Auto','Shared location'};





    tag=h.getTagPrefix;
    widgetId='pjtgeneratorpkg.GRTFactory.';


    try
        tr=RTW.TargetRegistry.get;
        tbllist=coder.internal.getTflTableList(tr,h.CodeReplacementLibrary);
        tblstr={''};
        for cnt=1:length(tbllist)
            tblstr=[tblstr,'\n',tbllist(cnt)];%#ok
        end
        description=coder.internal.getTfl(tr,h.CodeReplacementLibrary).Description;
    catch tblException
        tblstr={tblException.message};
        description=tblException.message;
    end
    mathTarget_Name='Target function library:';
    mathTarget_ToolTip=sprintf(...
    ['Specify target function library available to your target.\n',...
    description,'\nSelected target function library contains these tables:',tblstr{:}]);
    curEnvironment=getSoftwareEnvironments('Type',h.CodeReplacementLibrary);





    widget=[];
    ObjectProperty='CodeReplacementLibrary';
    widgetLbl=[];
    widgetLbl.Name=mathTarget_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.WidgetId=[widgetId,ObjectProperty];
    mathTargetLbl=widgetLbl;

    widget.Type='combobox';
    widget.Entries=tr.getTflNameList('nonSim',h);
    try
        widget.Value=coder.internal.getTfl(tr,h.CodeReplacementLibrary).Name;
        widget.Entries=RTW.unique([widget.Entries;widget.Value]);
    catch getException %#ok<NASGU>
        badTFL=h.CodeReplacementLibrary;
        widget.Entries=[widget.Entries;badTFL];
        widget.Value=badTFL;
    end
    widget.Enabled=double(~h.isReadonlyProperty(ObjectProperty));
    widget.ToolTip=mathTarget_ToolTip;
    widget.Tag=[tag,ObjectProperty];
    widget.WidgetId=[widgetId,ObjectProperty];
    widget.Source=h;
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.UserData.ObjectProperty=ObjectProperty;
    widget.UserData.Name=widgetLbl.Name;
    mathTarget=widget;
    mathTargetLbl.Buddy=mathTarget.Tag;

    widget=[];
    ObjectProperty='UtilityFuncGeneration';
    widgetLbl=[];
    widgetLbl.Name=utilityFuncGeneration_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.WidgetId=[widgetId,ObjectProperty];
    utilityFuncGenerationLbl=widgetLbl;

    widget.Type='combobox';
    widget.Entries=utility_entries;
    widget.Values=[0,1];
    widget.Value=get(h,ObjectProperty);
    widget.Enabled=double(~h.isReadonlyProperty(ObjectProperty));
    widget.ToolTip=utilityFuncGeneration_ToolTip;
    widget.Tag=[tag,ObjectProperty];
    widget.WidgetId=[widgetId,ObjectProperty];
    widget.ObjectProperty=ObjectProperty;
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.UserData.ObjectProperty=ObjectProperty;
    widget.UserData.Name=widgetLbl.Name;
    utilityFuncGeneration=widget;
    utilityFuncGenerationLbl.Buddy=utilityFuncGeneration.Tag;
    widget=[];




    mathTargetLbl.RowSpan=[1,1];
    mathTargetLbl.ColSpan=[1,1];
    mathTarget.RowSpan=[1,1];
    mathTarget.ColSpan=[2,2];
    utilityFuncGenerationLbl.RowSpan=[2,2];
    utilityFuncGenerationLbl.ColSpan=[1,1];
    utilityFuncGeneration.RowSpan=[2,2];
    utilityFuncGeneration.ColSpan=[2,2];
    group.Items={mathTargetLbl,mathTarget,utilityFuncGenerationLbl,utilityFuncGeneration};
    group.LayoutGrid=[2,2];
    group.ColStretch=[0,1];

    if strcmp(schemaName,'panel')
        group.Type='panel';
    elseif strcmp(schemaName,'group')
        group.Type='group';
    else
        group=[];
    end
