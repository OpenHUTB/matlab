function[out1,out2]=create_widget(source,h,propName,...
    layoutRow,layoutPrompt,layoutValue)














    if nargout==1

        prompt='out1';
        value='out1';
    else

        prompt='out1';
        value='out2';
        temp.out1.Type='text';
    end

    temp.(value).ObjectProperty=propName;
    temp.(value).Tag=temp.(value).ObjectProperty;

    temp.(prompt).Name=h.IntrinsicDialogParameters.(propName).Prompt;

    switch lower(h.IntrinsicDialogParameters.(propName).Type)
    case{'enum','dynamic enum'}
        temp.(value).Type='combobox';
        temp.(value).Entries=h.getPropAllowedValues(propName,true)';
        temp.(value).MatlabMethod='handleComboSelectionEvent';
        temp.(value).Editable=0;
    case 'radiobutton'
        temp.(value).Type='radiobutton';
        temp.(value).Entries=h.getPropAllowedValues(propName,true)';
        temp.(value).MatlabMethod='handleRadioButtonSelectionEvent';
        temp.(value).Editable=0;
    case 'boolean'
        temp.(value).Type='checkbox';
        temp.(value).MatlabMethod='handleCheckEvent';
    otherwise
        temp.(value).Type='edit';
        temp.(value).MatlabMethod='handleEditEvent';
    end

    temp.(value).MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};

    if~h.isTunableProperty(propName)
        temp.(value).Enabled=~source.isHierarchySimulating;
    end

    out1=temp.out1;
    out1.RowSpan=[layoutRow,layoutRow];

    if nargout>1
        out2=temp.out2;
        out2.RowSpan=[layoutRow,layoutRow];
        out1.ColSpan=[1,layoutPrompt];
        out2.ColSpan=[(layoutPrompt+1),(layoutPrompt+layoutValue)];
        out1.Tag=[out2.ObjectProperty,'_Prompt_Tag'];
        out1.Buddy=out2.Tag;
    else
        out1.ColSpan=[1,(layoutPrompt+layoutValue)];
    end

