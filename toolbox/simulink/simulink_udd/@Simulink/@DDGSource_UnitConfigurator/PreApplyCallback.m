function[status,errmsg]=PreApplyCallback(this,dlg)







    block=this.getBlock;


    updateParams=fieldnames(block.IntrinsicDialogParameters);
    for i=length(updateParams):-1:1
        switch updateParams{i}
        case{'UnitSystems'}

            updateParams={updateParams{1:i-1},updateParams{i+1:end}}';
        end
    end

    mxArrayParams={'UnitSystems'};
    mxArrayEmptyErrIds={'Simulink:Unit:AllowedUnitSystemsCannotBeEmpty'};


    set_param_cmd=['set_param(block.Handle'];
    restore_param_cmd=['set_param(block.Handle'];
    numChanges=0;
    status=1;
    errmsg='';


    for i=1:length(updateParams)
        if~isequal(this.DialogData.(updateParams{i}),block.(updateParams{i}))
            set_param_cmd=[set_param_cmd,',''',updateParams{i},''',''',this.DialogData.(updateParams{i}),''''];%#ok<AGROW>
            restore_param_cmd=[restore_param_cmd,',''',updateParams{i},''',''',block.(updateParams{i}),''''];%#ok<AGROW>
            numChanges=numChanges+1;
        end
    end


    oldMxArrays={};
    for i=1:length(mxArrayParams)
        if isempty(this.DialogData.(mxArrayParams{i}))
            status=0;
            DAStudio.slerror(mxArrayEmptyErrIds{i},block.Handle,block.Name);
        elseif~isequal(this.DialogData.(mxArrayParams{i}),block.(mxArrayParams{i}))
            set_param_cmd=[set_param_cmd,',''',mxArrayParams{i},''', this.DialogData.',mxArrayParams{i}];%#ok<AGROW>
            oldMxArrays{i}=block.(mxArrayParams{i});%#ok<AGROW>
            restore_param_cmd=[restore_param_cmd,',''',mxArrayParams{i},''', oldMxArrays{',int2str(i),'}'];%#ok<AGROW>
            numChanges=numChanges+1;
        end
    end

    set_param_cmd=[set_param_cmd,')'];
    restore_param_cmd=[restore_param_cmd,')'];

    if numChanges>0
        try

            eval(set_param_cmd);
        catch
            err=sllasterror;
            status=0;
            errmsg=err.Message;


            try
                eval(restore_param_cmd);
            catch
            end
        end
    end
end
