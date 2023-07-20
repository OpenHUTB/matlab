function searchable_params_container=createSearchableParamsContainer(this,varargin)







    if nargin<2
        container_type='panel';
    else
        container_type=varargin{1};
    end


    this.setupSearchableDialogData();




    filter_edit.Type='edit';
    filter_edit.Name='Search parameter:';
    filter_edit.ToolTip='Filter by name or description';
    filter_edit.ObjectMethod='applyFilter';
    filter_edit.MethodArgs={'%dialog','%value'};
    filter_edit.ArgDataTypes={'handle','mxArray'};
    filter_edit.RowSpan=[1,1];
    filter_edit.ColSpan=[1,2];
    filter_edit.Graphical=true;
    filter_edit.RespondsToTextChanged=true;
    filter_edit.PlaceholderText='Filter by name or description';
    filter_edit.Clearable=true;


    case_option.Type='checkbox';
    case_option.Name='Case sensitive';
    case_option.Value=this.DialogData.CaseSensitive;
    case_option.Tag='case_option_tag';
    case_option.ObjectMethod='dialogCallback';
    case_option.MethodArgs={'%dialog','%tag','%value'};
    case_option.ArgDataTypes={'handle','string','mxArray'};
    case_option.RowSpan=[2,2];
    case_option.ColSpan=[1,1];
    case_option.Graphical=true;


    regexp_option.Type='checkbox';
    regexp_option.Name='Regular expression support';
    regexp_option.Value=this.DialogData.RegexpSupport;
    regexp_option.Tag='regexp_option_tag';
    regexp_option.ObjectMethod='dialogCallback';
    regexp_option.MethodArgs={'%dialog','%tag','%value'};
    regexp_option.ArgDataTypes={'handle','string','mxArray'};
    regexp_option.RowSpan=[2,2];
    regexp_option.ColSpan=[2,2];
    regexp_option.Graphical=true;


    if this.DialogData.NumItemTotal==0
        search_result.Name='No such parameters found';
    else
        search_result.Name=[num2str(this.DialogData.NumItemTotal),' parameter(s) found'];
    end
    search_result.Type='text';
    search_result.Bold=true;
    search_result.WordWrap=true;
    search_result.RowSpan=[3,3];
    search_result.ColSpan=[1,2];


    if this.DialogData.NumItemAllowed<this.DialogData.NumItemTotal
        num_shown=this.DialogData.NumItemAllowed;
    else
        num_shown=this.DialogData.NumItemTotal;
    end
    num_column=2;
    tblData=cell(num_shown,num_column);


    isTableWitdhFixed=1;
    if isTableWitdhFixed
        width_params=24;
        width_value=24;
    else
        total_width=48;%#ok<UNRCH>
        min_width=8;
        max_width=total_width-min_width;
        promptLength=this.DialogData.PromptLength(this.DialogData.ShowList);
        promptLengthMax=max(promptLength(1:num_shown));
        width_params=ceil(promptLengthMax/1.3);
        valueLength=this.DialogData.ValueLength(this.DialogData.ShowList);
        valueLengthMax=max(valueLength(1:num_shown));
        width_value=ceil(valueLengthMax/1.3);
        if width_params<min_width
            width_params=min_width;
        end
        if width_value<min_width
            width_value=min_width;
        end
        if(width_params+width_value)>total_width
            width_params=ceil(promptLengthMax/(promptLengthMax+valueLengthMax)*total_width);
            if width_params<min_width
                width_params=min_width;
            elseif width_params>max_width
                width_params=max_width;
            end
            width_value=total_width-width_params;
        end
    end


    for i=1:num_shown
        index=this.DialogData.ShowListIndex(i);
        tblData{i,1}.Name=this.DialogData.ListPrompt{index};
        tblData{i,1}.Type='text';
        tblData{i,1}.WordWrap=true;
        tblData{i,1}.Enabled=(this.DialogData.ListEnabled(index))&&(~this.DialogData.ListReadOnly(index));

        tblData{i,2}.Type=this.DialogData.ListType{index};
        tblData{i,2}.Entries=this.DialogData.ListEnum{index}';
        tblData{i,2}.Value=this.DialogData.ListValue{index};
        tblData{i,2}.Enabled=tblData{i,1}.Enabled;
    end

    mask_params.Type='table';
    mask_params.Tag='mask_param_table';
    mask_params.RowSpan=[4,4];
    mask_params.ColSpan=[1,2];
    mask_params.Size=[num_shown,num_column];
    mask_params.HeaderVisibility=[0,1];
    mask_params.ColHeader={'Parameter','Value'};
    mask_params.ColumnCharacterWidth=[width_params,width_value];
    mask_params.Data=tblData;
    mask_params.Editable=true;
    mask_params.ValueChangedCallback=@dialogTableCallback;
    mask_params.MinimumSize=[600,300];


    show_complete.Name='Show All Matching Parameters';
    show_complete.Type='pushbutton';
    show_complete.ObjectMethod='showCompleteList';
    show_complete.DialogRefresh=true;
    if this.DialogData.NumItemAllowed<this.DialogData.NumItemTotal
        show_complete.Visible=true;
    else
        show_complete.Visible=false;
    end
    show_complete.RowSpan=[5,5];
    show_complete.ColSpan=[1,2];



    switch container_type
    case 'group'
        searchable_params_container.Type='group';
        searchable_params_container.Name='Parameters';
    otherwise
        searchable_params_container.Type='panel';
    end
    searchable_params_container.LayoutGrid=[5,2];
    searchable_params_container.Items={filter_edit,case_option,regexp_option,search_result,mask_params,show_complete};



end


function dialogTableCallback(dlg,row,~,value)



    source=dlg.getDialogSource;


    index=source.DialogData.ShowListIndex(row+1);


    source.DialogData.ChangeList(index)=1;


    source.DialogData.ListValue{index}=value;

end
