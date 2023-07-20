function[status,errmsg]=PreApplyCallback(this,~)






    block=this.getBlock;

    paramFeatureOn=(slfeature('ForEachSubsystemParameterization')==1);
    inputOverlappingFeatureOn=(slfeature('ForEachSubsystemInputOverlapping')==1);


    updateParams=fieldnames(block.IntrinsicDialogParameters);
    for i=length(updateParams):-1:1
        switch updateParams{i}
        case{'IterateInput',...
            'InputIterationDimension',...
            'InputIterationStepSize',...
            'InputIterationStepOffset',...
            'ConcatenateOutput',...
            'OutputConcatDimension',...
            'IterateSubsysMaskParameter',...
            'SubsysMaskParameterIterationDimension',...
            'SubsysMaskParameterIterationStepSize',...
            'InportBlockPtrsArray',...
            'InportBlockNamesArray',...
            'InputPartition',...
            'InputPartitionDimension',...
            'InputPartitionWidth',...
            'InputPartitionOffset',...
            'OutportBlockPtrsArray',...
            'OutportBlockNamesArray',...
            'OutputConcatenation',...
            'OutputConcatenationDimension',...
            'SubsysMaskParameterPtrsArray',...
            'SubsysMaskParameterNamesArray',...
            'SubsysMaskParameterIsPartitionableArray',...
            'SubsysMaskParameterPartition',...
            'SubsysMaskParameterPartitionDimension',...
            'SubsysMaskParameterPartitionWidth'}

            updateParams={updateParams{1:i-1},updateParams{i+1:end}}';
        end
    end

    if inputOverlappingFeatureOn
        temp_mxArrayParams1={'InputPartitionOffset'};
    else
        temp_mxArrayParams1={};
    end
    if paramFeatureOn
        temp_mxArrayParams2={'SubsysMaskParameterPartition',...
        'SubsysMaskParameterPartitionDimension',...
        'SubsysMaskParameterPartitionWidth'};
    else
        temp_mxArrayParams2={};
    end
    mxArrayParams=[{'InputPartition',...
    'InputPartitionDimension',...
    'InputPartitionWidth'},...
    temp_mxArrayParams1,...
    {'OutputConcatenation',...
    'OutputConcatenationDimension'},...
    temp_mxArrayParams2];


    set_param_cmd=['set_param(block.Handle'];
    restore_param_cmd=['set_param(block.Handle'];
    numChanges=0;


    for i=1:length(updateParams)
        if~isequal(this.DialogData.(updateParams{i}),block.(updateParams{i}))
            set_param_cmd=[set_param_cmd,',''',updateParams{i},''',''',this.DialogData.(updateParams{i}),''''];%#ok<AGROW>
            restore_param_cmd=[restore_param_cmd,',''',updateParams{i},''',''',block.(updateParams{i}),''''];%#ok<AGROW>
            numChanges=numChanges+1;
        end
    end


    oldMxArrays={};
    for i=1:length(mxArrayParams)
        if~isequal(this.DialogData.(mxArrayParams{i}),block.(mxArrayParams{i}))
            set_param_cmd=[set_param_cmd,',''',mxArrayParams{i},''', this.DialogData.',mxArrayParams{i}];%#ok<AGROW>
            oldMxArrays{i}=block.(mxArrayParams{i});%#ok<AGROW>
            restore_param_cmd=[restore_param_cmd,',''',mxArrayParams{i},''', oldMxArrays{',int2str(i),'}'];%#ok<AGROW>
            numChanges=numChanges+1;
        end
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
