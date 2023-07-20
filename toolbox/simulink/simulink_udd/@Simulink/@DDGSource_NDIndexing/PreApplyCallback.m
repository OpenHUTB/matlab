function[status,errmsg]=PreApplyCallback(this,dlg)






    block=this.getBlock;


    updateParams=fieldnames(block.IntrinsicDialogParameters);
    for i=length(updateParams):-1:1
        switch updateParams{i}
        case{'NumberOfDimensions','IndexOptions','Indices','OutputSizes','IndexParamArray','IndexOptionArray','OutputSizeArray'}

            updateParams={updateParams{1:i-1},updateParams{i+1:end}}';
        end
    end

    mxArrayParams={'IndexOptionArray','IndexParamArray','OutputSizeArray'};


    set_param_cmd=['set_param(block.Handle'];
    restore_param_cmd=['set_param(block.Handle'];
    numChanges=0;



    strNumDims=dlg.getWidgetValue('_Number_Of_Dimensions_');
    if~isequal(block.NumberOfDimensions,strNumDims)
        set_param_cmd=[set_param_cmd,',''NumberOfDimensions'',''',strNumDims,''''];
        restore_param_cmd=[restore_param_cmd,',''NumberOfDimensions'',''',block.NumberOfDimensions,''''];
        numChanges=numChanges+1;
    else
        numDims=str2double(strNumDims);
        if isnan(numDims)||length(numDims)~=1||numDims<=0||floor(numDims)~=numDims
            set_param_cmd=[set_param_cmd,',''NumberOfDimensions'',''',strNumDims,''''];
            restore_param_cmd=[restore_param_cmd,',''NumberOfDimensions'',''',block.NumberOfDimensions,''''];
            numChanges=numChanges+1;
        end
    end


    for i=1:length(updateParams)
        if~isequal(this.DialogData.(updateParams{i}),block.(updateParams{i}))
            set_param_cmd=[set_param_cmd,',''',updateParams{i},''',''',this.DialogData.(updateParams{i}),''''];%#ok<AGROW>
            restore_param_cmd=[restore_param_cmd,',''',updateParams{i},''',''',block.(updateParams{i}),''''];%#ok<AGROW>
            numChanges=numChanges+1;
        end
    end

    numDims=this.getNumDims;


    oldMxArrays={};
    for i=1:length(mxArrayParams)
        if~isequal(this.DialogData.(mxArrayParams{i})(1:numDims),block.(mxArrayParams{i}))
            set_param_cmd=[set_param_cmd,',''',mxArrayParams{i},''', this.DialogData.',mxArrayParams{i},'(1:',int2str(numDims),')'];%#ok<AGROW>
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
