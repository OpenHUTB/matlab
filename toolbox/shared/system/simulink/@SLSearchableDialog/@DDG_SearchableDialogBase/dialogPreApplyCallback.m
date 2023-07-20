function[status,errmsg]=dialogPreApplyCallback(this,dlg)






    block=this.getBlock();%#ok<NASGU>


    updateParamsList=find(this.DialogData.ChangeList);
    numChanges=size(updateParamsList,2);

    set_param_cmd='';
    restore_param_cmd='';

    if numChanges>0
        set_param_cmd=['set_param(block.Handle'];
        restore_param_cmd=['set_param(block.Handle'];
        for i=1:numChanges
            set_param_cmd=[set_param_cmd,', ''',this.DialogData.ListParams{updateParamsList(i)},''', '];%#ok<AGROW>
            restore_param_cmd=[restore_param_cmd,', ''',this.DialogData.ListParams{updateParamsList(i)},''', '];%#ok<AGROW>
            if ischar(this.DialogData.ListValue{updateParamsList(i)})

                escaped_new_value=regexprep(this.DialogData.ListValue{updateParamsList(i)},'('')','''$1');
                escaped_old_value=regexprep(this.DialogData.ListOldValue{updateParamsList(i)},'('')','''$1');
                set_param_cmd=[set_param_cmd,'''',escaped_new_value,''''];%#ok<AGROW>
                restore_param_cmd=[restore_param_cmd,'''',escaped_old_value,''''];%#ok<AGROW>
            else
                set_param_cmd=[set_param_cmd,num2str(this.DialogData.ListValue{updateParamsList(i)})];%#ok<AGROW>
                restore_param_cmd=[restore_param_cmd,num2str(this.DialogData.ListOldValue{updateParamsList(i)})];%#ok<AGROW>
            end
        end

        set_param_cmd=[set_param_cmd,')'];
        restore_param_cmd=[restore_param_cmd,')'];
    end

    try

        eval(set_param_cmd);


        [status,errmsg]=this.preApplyCallback(dlg);
        if(status==0)
            me=MException('SearchableDialog:InvalidSetting',errmsg);
            throw(me);
        end;


        this.DialogData.ChangeList(updateParamsList)=zeros(1,numChanges);
        this.DialogData.ListOldValue(updateParamsList)=this.DialogData.ListValue(updateParamsList);
    catch ex
        status=0;
        errmsg=ex.message;


        try
            eval(restore_param_cmd);
        catch
        end
    end
