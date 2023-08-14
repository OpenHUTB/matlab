function dlgstruct=getDialogSchema(obj,name)%#ok (name unused)














    if isempty(obj.DialogData)
        obj.getFromSimulink;
    end

    bdname=get_param(obj.SimulinkHandle,'Name');

    label.Type='text';
    label.Name=DAStudio.message('Simulink:prefs:FontDialogLabel',bdname);
    label.RowSpan=[1,1];
    label.ColSpan=[1,2];

    prefsB=i_fontpicker(obj,'Block');
    prefsB.RowSpan=[2,2];
    prefsB.ColSpan=[1,2];

    prefsL=i_fontpicker(obj,'Line');
    prefsL.RowSpan=[3,3];
    prefsL.ColSpan=[1,2];

    prefsA=i_fontpicker(obj,'Annotation');
    prefsA.RowSpan=[4,4];
    prefsA.ColSpan=[1,2];

    blankSpace.Type='text';
    blankSpace.Name='';
    blankSpace.RowSpan=[5,5];
    blankSpace.ColSpan=[1,2];

    dlgstruct.DialogTitle=DAStudio.message('Simulink:prefs:FontDialogTitle');
    dlgstruct.LayoutGrid=[5,2];
    dlgstruct.Items={label,prefsB,prefsL,prefsA,blankSpace};
    dlgstruct.RowStretch=[0,0,0,0,1];

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={'mapkey:Simulink.FontPrefs','help_button','CSHelpWindow'};

    dlgstruct.PostApplyMethod='dlgCallback';
    dlgstruct.PostApplyArgs={'%dialog','Apply'};
    dlgstruct.PostApplyArgsDT={'handle','string'};

    dlgstruct.CloseMethod='dlgCallback';
    dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
    dlgstruct.CloseMethodArgsDT={'handle','string'};



    dlgstruct.Sticky=true;
    dlgstruct.DialogTag='default_model_font';



    dlgstruct.EmbeddedButtonSet={'Help','Apply'};


    function picker=i_fontpicker(obj,tag)


        [available_faces,available_sizes,nsizes]=obj.allowedValues;
        data=obj.DialogData.(tag);

        is_bold=strcmp(data.FontWeight,'bold');
        is_italic=strcmp(data.FontAngle,'italic');

        [fontname,faceindex]=obj.findMatchingFont(data.FontName);
        faceindex=faceindex-1;

        sizeindex=find(data.FontSize==nsizes);
        if isempty(sizeindex)

            [~,sizeindex]=min(abs(nsizes-data.FontSize));
            data.FontSize=nsizes(sizeindex);
        end
        sizeindex=sizeindex-1;

        faces.Type='combobox';
        faces.Entries=available_faces;

        faces.Value=faceindex;
        faces.Tag=[tag,'FontName'];
        faces.RowSpan=[1,1];
        faces.ColSpan=[1,1];
        faces=i_control_callback(faces);

        styles.Type='combobox';
        styles.Entries={DAStudio.message('Simulink:prefs:FontPlain'),...
        DAStudio.message('Simulink:prefs:FontBold'),...
        DAStudio.message('Simulink:prefs:FontItalic'),...
        DAStudio.message('Simulink:prefs:FontBoldItalic')};
        styles.Value=is_bold+2*is_italic;
        styles.RowSpan=[1,1];
        styles.ColSpan=[2,2];
        styles.Tag=[tag,'FontStyle'];
        styles=i_control_callback(styles);

        sizes.Type='combobox';
        sizes.Entries=available_sizes;

        sizes.Value=sizeindex;
        sizes.RowSpan=[1,1];
        sizes.ColSpan=[3,3];
        sizes.Tag=[tag,'FontSize'];
        sizes=i_control_callback(sizes);

        label.Type='text';
        label.Name=DAStudio.message('Simulink:prefs:FontDisplayString');
        label.FontFamily=fontname;
        label.FontPointSize=data.FontSize;
        label.Bold=double(is_bold);
        label.Italic=double(is_italic);

        sample.Type='group';
        sample.LayoutGrid=[1,1];
        sample.Name=DAStudio.message('Simulink:prefs:FontSample');
        sample.Items={label};
        sample.RowSpan=[2,2];
        sample.ColSpan=[1,4];

        picker.Type='group';
        picker.LayoutGrid=[2,4];
        picker.ColStretch=[0,0,0,1];
        picker.Name=DAStudio.message(['Simulink:prefs:',tag]);
        picker.Tag=tag;
        picker.Items={faces,styles,sizes,sample};


        function c=i_control_callback(c)

            c.ObjectMethod='controlCallback';
            c.MethodArgs={'%dialog'};
            c.ArgDataTypes={'handle'};


