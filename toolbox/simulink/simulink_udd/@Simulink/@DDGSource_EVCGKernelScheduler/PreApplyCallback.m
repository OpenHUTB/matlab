function[status,errmsg]=PreApplyCallback(this,~)





    block=this.getBlock;


    updateParams=fieldnames(block.IntrinsicDialogParameters);
    for i=length(updateParams):-1:1
        switch updateParams{i}
        case{'InportNeighborhood'}

            updateParams={updateParams{1:i-1},updateParams{i+1:end}}';
        end
    end
    updateParams{end+1}='InportNeighborhood';
    this.DialogData.InportNeighborhood=jsonencode(table2struct(this.DialogData.StencilTable));


    set_param_cmd=['set_param(block.Handle'];
    restore_param_cmd=['set_param(block.Handle'];
    numChanges=0;


    for i=1:length(updateParams)
        prm=updateParams{i};
        skipUpdate=isequal(this.DialogData.(prm),block.(prm));
        if~skipUpdate&&strcmp(prm,'InportNeighborhood')&&~isempty(block.(prm))
            diagStruct=jsondecode(this.DialogData.InportNeighborhood);
            blkStruct=jsondecode(block.InportNeighborhood);
            skipUpdate=isequal(blkStruct,diagStruct);
        end
        if skipUpdate
            continue;
        end
        set_param_cmd=[set_param_cmd,',''',prm,''',''',this.DialogData.(prm),''''];%#ok<AGROW>
        restore_param_cmd=[restore_param_cmd,',''',prm,''',''',block.(prm),''''];%#ok<AGROW>
        numChanges=numChanges+1;
    end










    set_param_cmd=[set_param_cmd,')'];
    restore_param_cmd=[restore_param_cmd,')'];

    status=1;
    errmsg='';
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
