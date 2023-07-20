function dlgstruct=getDialogSchema(obj,name)%#ok (name unsued)








    if obj.SimulinkHandle==0
        dialog_title=DAStudio.message('Simulink:prefs:EditorPrefsDialogTitle');
        label_text=DAStudio.message('Simulink:prefs:AllSimulinkModels');
    else
        dialog_title=DAStudio.message('Simulink:prefs:EditorDialogTitle');
        label_text=DAStudio.message('Simulink:prefs:ThisSimulinkModel',...
        get_param(obj.SimulinkHandle,'Name'));
    end

    items={};
    row=1;
    nCols=1;




    info.Type='text';
    info.Name=label_text;
    info.RowSpan=[row,row];
    info.ColSpan=[1,nCols];

    row=row+1;
    items=[items,{info}];



    theme.Type='checkbox';
    theme.Name=DAStudio.message('Simulink:prefs:DiagramTheme');
    theme.Enabled=true;
    theme.ToolTip=...
    DAStudio.message('Simulink:prefs:DiagramThemeToolTip');
    theme.Value=~i_ison(get_param(0,'EditorModernTheme'));
    theme.Tag='EditorTheme';
    theme.RowSpan=[row,row];
    theme.ColSpan=[1,nCols];

    items=[items,{theme}];
    row=row+1;




    pathXStyle.Type='radiobutton';
    pathXStyle.Name='';
    pathXStyle.Tag='PathXStyle';
    pathXStyle.ShowBorder=false;
    pathXStyle.Entries={DAStudio.message('Simulink:prefs:PathXStyleGradPin')...
    ,DAStudio.message('Simulink:prefs:PathXStyleLineHop')...
    ,DAStudio.message('Simulink:prefs:PathXStyleNone')};
    pathXStyle.OrientHorizontal=true;
    pathXStyle.RowSpan=[1,1];
    pathXStyle.ColSpan=[1,1];

    pxss=get_param(0,'EditorPathXStyle');
    if strcmp(pxss,'none')
        pathXStyle.Value=2;
    elseif strcmp(pxss,'hop')
        pathXStyle.Value=1;
    else
        pathXStyle.Value=0;
    end

    imagedir=slfullfile(matlabroot,'toolbox','simulink','simulink_udd','resources');

    pathXStyleGradPin.Type='image';
    pathXStyleGradPin.FilePath=slfullfile(imagedir,'pathxstyle-gradpin.png');
    pathXStyleGradPin.RowSpan=[1,1];
    pathXStyleGradPin.ColSpan=[1,1];
    pathXStyleGradPin.Alignment=2;

    pathXStyleLineHop.Type='image';
    pathXStyleLineHop.FilePath=slfullfile(imagedir,'pathxstyle-hop.png');
    pathXStyleLineHop.RowSpan=[1,1];
    pathXStyleLineHop.ColSpan=[2,2];
    pathXStyleLineHop.Alignment=2;

    pathXStyleNone.Type='image';
    pathXStyleNone.FilePath=slfullfile(imagedir,'pathxstyle-none.png');
    pathXStyleNone.RowSpan=[1,1];
    pathXStyleNone.ColSpan=[3,3];
    pathXStyleNone.Alignment=2;

    pathXStyleImages.Type='panel';
    pathXStyleImages.Items={pathXStyleGradPin,pathXStyleLineHop,pathXStyleNone};
    pathXStyleImages.LayoutGrid=[1,3];
    pathXStyleImages.RowSpan=[2,2];
    pathXStyleImages.ColSpan=[1,1];


    pathXStyleGroup.Type='group';
    pathXStyleGroup.Name=DAStudio.message('Simulink:prefs:PathXStylePrompt');
    pathXStyleGroup.ToolTip=DAStudio.message('Simulink:prefs:PathXStyleTooltip');
    pathXStyleGroup.Items={pathXStyleImages,pathXStyle};
    pathXStyleGroup.LayoutGrid=[2,1];
    pathXStyleGroup.RowSpan=[row,row];
    pathXStyleGroup.ColSpan=[1,nCols];

    items=[items,{pathXStyleGroup}];
    row=row+1;




    mw.Type='checkbox';
    mw.Name=DAStudio.message('Simulink:prefs:ScrollWheel');
    mw.Enabled=true;
    mw.ToolTip=...
    DAStudio.message('Simulink:prefs:ScrollWheelToolTip');
    mw.Value=i_ison(get_param(0,'EditorScrollWheelZooms'));
    mw.Tag='ScrollWheel';
    mw.RowSpan=[row,row];
    mw.ColSpan=[1,nCols];

    items=[items,{mw}];
    row=row+1;


    if slfeature('SLContentPreview')~=0
        mw.Type='checkbox';
        mw.Name=DAStudio.message('Simulink:prefs:ContentPreview');
        mw.Enabled=true;
        mw.ToolTip=...
        DAStudio.message('Simulink:prefs:ContentPreviewToolTip');
        mw.Value=i_ison(get_param(0,'EditorContentPreviewDefaultOn'));
        mw.Tag='ContentPreview';
        mw.RowSpan=[row,row];
        mw.ColSpan=[1,nCols];

        items=[items,{mw}];
        row=row+1;
    end




    coach.Type='checkbox';
    coach.Name=DAStudio.message('Simulink:prefs:SmartEditing');
    coach.Enabled=true;
    coach.ToolTip=...
    DAStudio.message('Simulink:prefs:SmartEditingToolTip');
    coach.Value=i_ison(get_param(0,'EditorSmartEditing'));
    coach.Tag='EditorSmartEditing';
    coach.RowSpan=[row,row];
    coach.ColSpan=[1,nCols];

    items=[items,{coach}];
    row=row+1;



    hptab.Type='text';
    hptab.Name='   ';
    hptab.Tag='HotParamTab';
    hptab.RowSpan=[1,1];
    hptab.ColSpan=[1,1];

    hpbutton.Type='checkbox';
    hpbutton.Name=DAStudio.message('Simulink:prefs:SmartEditingHotParam');
    hpbutton.ToolTip=DAStudio.message('Simulink:prefs:SmartEditingHotParamToolTip');
    hpbutton.Enabled=i_ison(get_param(0,'EditorSmartEditing'));
    hpbutton.Value=i_ison(get_param(0,'EditorSmartEditingHotParam'));
    hpbutton.Tag='EditorSmartEditingHotParam';
    hpbutton.RowSpan=[1,1];
    hpbutton.ColSpan=[2,2];

    hppanel.Type='panel';
    hppanel.RowSpan=[row,row];
    hppanel.ColSpan=[1,1];
    hppanel.LayoutGrid=[1,2];
    hppanel.ColStretch=[0,1];
    hppanel.Items={hptab,hpbutton};

    items=[items,{hppanel}];
    row=row+1;



    if slfeature('DockedDiagnosticViewer')~=0
        dv.Type='checkbox';
        dv.Name=DAStudio.message('Simulink:prefs:DockedDVPref');
        dv.Enabled=true;
        dv.ToolTip=...
        DAStudio.message('Simulink:prefs:DockedDVPrefToolTip');
        dv.Value=i_ison(get_param(0,'DiagnosticViewerPreference'));
        dv.Tag='DiagnosticViewerPreference';
        dv.RowSpan=[row,row];
        dv.ColSpan=[1,nCols];

        items=[items,{dv}];
        row=row+1;
    end

    if slfeature('ShowParameterValue')~=0
        inPlaceValue.Type='checkbox';
        inPlaceValue.Name=DAStudio.message('Simulink:prefs:InPlaceValueDisplayPref');
        inPlaceValue.Enabled=true;
        inPlaceValue.Value=dastudio_util.GLPreferences.getBoolPref('DAStudio DDG','DDGInPlaceEvaluation',true);
        inPlaceValue.Tag='InPlaceValueEvaluationPreference';
        inPlaceValue.RowSpan=[row,row];
        inPlaceValue.ColSpan=[1,nCols];

        items=[items,{inPlaceValue}];
        row=row+1;
    end



    dlgstruct.DialogTitle=dialog_title;
    dlgstruct.LayoutGrid=[row,nCols];
    stretch=zeros(1,row);
    stretch(row)=1;
    dlgstruct.RowStretch=stretch;
    dlgstruct.Items=items;


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={'mapkey:Simulink.EditorPrefs','help_button','CSHelpWindow'};

    dlgstruct.PostApplyMethod='dlgCallback';
    dlgstruct.PostApplyArgs={'%dialog','Apply'};
    dlgstruct.PostApplyArgsDT={'handle','string'};

    dlgstruct.CloseMethod='dlgCallback';
    dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
    dlgstruct.CloseMethodArgsDT={'handle','string'};




    function b=i_ison(s)

        b=strcmp(s,'on');
        assert(b||strcmp(s,'off'));


